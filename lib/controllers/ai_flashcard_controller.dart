import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question_model.dart';
import '../models/flashcard_set_model.dart';
import 'saved_controller.dart';

class AiFlashcardController extends GetxController {
  final topicController = TextEditingController();
  final loading = false.obs;
  final generatedQuestions = <Question>[].obs;
  final history = <String>[].obs; // List of past topics
  final lastGeneratedSet = Rxn<FlashcardSet>();
  final error = ''.obs;
  final logger = Logger();

  @override
  void onInit() {
    super.onInit();
    _checkApiKey();
    _loadHistory();
  }

  void _checkApiKey() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      error.value = 'GEMINI_API_KEY is missing in .env file';
      logger.e('GEMINI_API_KEY is missing');
      Get.snackbar(
        'Configuration Error',
        'Please add GEMINI_API_KEY to your .env file',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 5),
      );
    }
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    history.assignAll(prefs.getStringList('ai_history') ?? []);
  }

  Future<void> _addToHistory(String topic) async {
    if (!history.contains(topic)) {
      history.insert(0, topic);
      if (history.length > 10) history.removeLast(); // Keep last 10
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('ai_history', history);
    }
  }

  Future<void> generateFlashcards({String? topic}) async {
    final searchTopic = topic ?? topicController.text.trim();
    if (searchTopic.isEmpty) {
      Get.snackbar(
        'Input Required',
        'Please enter a topic',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange,
      );
      return;
    }

    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      _checkApiKey();
      return;
    }

    loading.value = true;
    error.value = '';
    generatedQuestions.clear();
    logger.i('Generating flashcards for topic: $searchTopic');

    try {
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);

      final prompt = '''
        Generate 5 flashcards for the topic: "$searchTopic".
        Return ONLY a valid JSON array. Each object in the array must have:
        - "question_text": The question.
        - "answer_text": The answer.
        - "difficulty": "Easy", "Medium", or "Hard".
        Do not include any markdown formatting like ```json or ```. Just the raw JSON string.
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      final text = response.text;
      if (text == null) throw 'No response from Gemini';

      logger.d(
        'Gemini response received: ${text.substring(0, text.length > 100 ? 100 : text.length)}...',
      );

      // Clean up potential markdown if Gemini adds it despite instructions
      var cleanText =
          text.replaceAll('```json', '').replaceAll('```', '').trim();
      if (cleanText.startsWith('json'))
        cleanText = cleanText.substring(4).trim();

      dynamic decoded = jsonDecode(cleanText);
      if (decoded is! List) {
        // Sometimes Gemini wraps the list in an object like {"flashcards": [...]}
        if (decoded is Map && decoded.containsKey('flashcards')) {
          decoded = decoded['flashcards'];
        } else {
          throw 'Invalid JSON format received from Gemini';
        }
      }

      final List<dynamic> jsonList = decoded as List;

      final newSet = FlashcardSet(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        topic: searchTopic,
        createdAt: DateTime.now(),
        questions:
            jsonList.map((e) {
              if (e is! Map) throw 'Invalid flashcard object';
              return Question(
                id:
                    DateTime.now().millisecondsSinceEpoch.toString() +
                    e.hashCode.toString(),
                topicId: 'ai_generated',
                questionText: e['question_text']?.toString() ?? 'Error',
                answerText: e['answer_text']?.toString() ?? 'Error',
                difficulty: e['difficulty']?.toString() ?? 'Medium',
              );
            }).toList(),
      );

      // Save to local storage
      final savedController = Get.find<SavedController>();
      await savedController.saveFlashcardSet(newSet);

      lastGeneratedSet.value = newSet;

      _addToHistory(searchTopic);
      if (topic != null) topicController.text = topic;

      // Show success dialog
      Get.dialog(
        AlertDialog(
          title: const Text('Flashcards Ready!'),
          content: Text(
            'Generated ${newSet.questions.length} flashcards for "$searchTopic".\nYou can find them in your Bookmarks.',
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Close')),
            FilledButton(
              onPressed: () {
                Get.back();
                // Navigate to bookmarks tab or show the set directly?
                // For now, let's just close and maybe the user can go to bookmarks.
                // Or we could switch the tab if we had a main controller.
              },
              child: const Text('View in Bookmarks'),
            ),
          ],
        ),
      );
    } catch (e) {
      logger.e('Error generating flashcards', error: e);
      error.value = e.toString();
      Get.snackbar(
        'Generation Failed',
        'Failed to generate flashcards: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      loading.value = false;
    }
  }
}
