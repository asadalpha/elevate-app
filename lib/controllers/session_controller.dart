import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/question_model.dart';
import '../controllers/saved_controller.dart';

class SessionController extends GetxController {
  final supa = Supabase.instance.client;
  final topicId = ''.obs;
  final questions = <Question>[].obs;
  final idx = 0.obs;
  final isFlipped = false.obs;
  final loading = false.obs;
  final isBookmarked = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(idx, (_) => checkBookmark());
  }

  void start(String tId) {
    topicId.value = tId;
    idx.value = 0;
    isFlipped.value = false;
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    loading.value = true;
    final res = await supa
        .from('questions')
        .select()
        .eq('topic_id', topicId.value)
        .limit(10);
    questions.assignAll((res as List).map((e) => Question.fromMap(e)));
    loading.value = false;
    checkBookmark();
  }

  void next() {
    if (idx.value < questions.length - 1) {
      idx.value++;
      isFlipped.value = false;
    }
  }

  void prev() {
    if (idx.value > 0) {
      idx.value--;
      isFlipped.value = false;
    }
  }

  Future<void> checkBookmark() async {
    if (questions.isEmpty) {
      isBookmarked.value = false;
      return;
    }
    final q = questions[idx.value];
    try {
      final savedController = Get.find<SavedController>();
      isBookmarked.value = await savedController.isBookmarked(q.id);
    } catch (e) {
      // SavedController might not be ready
      isBookmarked.value = false;
    }
  }

  Future<void> toggleBookmark() async {
    if (questions.isEmpty) return;
    final q = questions[idx.value];
    final savedController = Get.find<SavedController>();

    if (isBookmarked.value) {
      await savedController.deleteBookmark(q.id);
      isBookmarked.value = false;
    } else {
      await savedController.addBookmark(q);
      isBookmarked.value = true;
    }
  }
}
