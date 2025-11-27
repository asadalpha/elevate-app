import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileController extends GetxController {
  final supa = Supabase.instance.client;
  final emailOrId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _updateUser();
    supa.auth.onAuthStateChange.listen((event) {
      _updateUser();
    });
  }

  void _updateUser() {
    final u = supa.auth.currentUser;
    emailOrId.value = u?.email ?? (u?.id ?? 'Anonymous');
  }
}
