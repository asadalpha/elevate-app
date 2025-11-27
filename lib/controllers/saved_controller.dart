import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question_model.dart';
import '../models/flashcard_set_model.dart';

class SavedController extends GetxController {
  final saved = <Question>[].obs;
  final flashcardSets = <FlashcardSet>[].obs;
  final loading = false.obs;
  final currentTab = 0.obs; // 0: Bookmarks, 1: AI Sets

  @override
  void onInit() {
    fetchSaved();
    fetchFlashcardSets();
    super.onInit();
  }

  Future<void> fetchSaved() async {
    loading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> savedList = prefs.getStringList('bookmarks') ?? [];

      saved.assignAll(
        savedList
            .map((e) {
              try {
                return Question.fromMap(jsonDecode(e));
              } catch (e) {
                return null;
              }
            })
            .whereType<Question>()
            .toList(),
      );
    } catch (e) {
      print('Error fetching saved bookmarks: $e');
    } finally {
      loading.value = false;
    }
  }

  Future<void> fetchFlashcardSets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> setsList = prefs.getStringList('flashcard_sets') ?? [];

      flashcardSets.assignAll(
        setsList
            .map((e) {
              try {
                return FlashcardSet.fromJson(e);
              } catch (e) {
                print('Error parsing flashcard set: $e');
                return null;
              }
            })
            .whereType<FlashcardSet>()
            .toList(),
      );
    } catch (e) {
      print('Error fetching flashcard sets: $e');
    }
  }

  Future<void> saveFlashcardSet(FlashcardSet set) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> setsList = prefs.getStringList('flashcard_sets') ?? [];

    // Check if already exists (by ID)
    if (!setsList.any((e) => FlashcardSet.fromJson(e).id == set.id)) {
      setsList.add(set.toJson());
      await prefs.setStringList('flashcard_sets', setsList);
      fetchFlashcardSets();
    }
  }

  Future<void> deleteFlashcardSet(String setId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> setsList = prefs.getStringList('flashcard_sets') ?? [];

    setsList.removeWhere((e) => FlashcardSet.fromJson(e).id == setId);
    await prefs.setStringList('flashcard_sets', setsList);

    flashcardSets.removeWhere((s) => s.id == setId);
  }

  Future<void> addBookmark(Question q) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedList = prefs.getStringList('bookmarks') ?? [];

    // Check if already exists
    if (!savedList.any((e) => Question.fromMap(jsonDecode(e)).id == q.id)) {
      savedList.add(jsonEncode(q.toMap()));
      await prefs.setStringList('bookmarks', savedList);
      fetchSaved();
    }
  }

  Future<void> deleteBookmark(String questionId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedList = prefs.getStringList('bookmarks') ?? [];

    savedList.removeWhere(
      (e) => Question.fromMap(jsonDecode(e)).id == questionId,
    );
    await prefs.setStringList('bookmarks', savedList);

    saved.removeWhere((q) => q.id == questionId);
  }

  Future<bool> isBookmarked(String questionId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedList = prefs.getStringList('bookmarks') ?? [];
    return savedList.any(
      (e) => Question.fromMap(jsonDecode(e)).id == questionId,
    );
  }
}
