import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/topic_model.dart';

class DashboardController extends GetxController {
  final supa = Supabase.instance.client;
  final topics = <Topic>[].obs;
  final loading = false.obs;

  @override
  void onInit() {
    fetchTopics();
    super.onInit();
  }

  Future<void> fetchTopics() async {
    loading.value = true;
    final res = await supa.from('topics').select().order('name');
    topics.assignAll((res as List).map((e) => Topic.fromMap(e)));
    loading.value = false;
  }
}
