import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import '../models/tech_news_model.dart';

class TechNewsController extends GetxController {
  final loading = false.obs;
  final newsList = <TechNews>[].obs;
  final error = ''.obs;
  final logger = Logger();

  @override
  void onInit() {
    super.onInit();
    fetchNews();
  }

  Future<void> fetchNews() async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      error.value = 'GEMINI_API_KEY is missing';
      return;
    }

    loading.value = true;
    error.value = '';

    try {
      // Using the same model as ai_flashcard_controller
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);

      final prompt = '''
        Fetch the latest technology news headlines and summaries from the web.
        Focus on AI, gadgets, software, and major tech industry updates.
        Return ONLY a valid JSON array. Each object in the array must have:
        - "title": The headline.
        - "description": A short summary (2-3 sentences).
        - "category": e.g., "AI", "Mobile", "Software", "Hardware".
        - "source": The potential source or "Tech News".
        
        Generate at least 10 items.
        Do not include any markdown formatting like ```json or ```. Just the raw JSON string.
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      final text = response.text;
      if (text == null) throw 'No response from Gemini';

      logger.d(
        'Gemini response: ${text.substring(0, text.length > 100 ? 100 : text.length)}...',
      );

      var cleanText = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      if (cleanText.startsWith('json'))
        cleanText = cleanText.substring(4).trim();

      final List<dynamic> jsonList = jsonDecode(cleanText);

      newsList.assignAll(jsonList.map((e) => TechNews.fromJson(e)).toList());
    } catch (e) {
      logger.e('Error fetching news', error: e);
      error.value = 'Failed to fetch news: $e';
    } finally {
      loading.value = false;
    }
  }
}
