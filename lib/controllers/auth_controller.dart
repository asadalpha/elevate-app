import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class AuthController extends GetxController {
  final supabase = Supabase.instance.client;

  final session = Rxn<Session>();
  final loading = false.obs;

  @override
  void onInit() {
    session.value = supabase.auth.currentSession;

    supabase.auth.onAuthStateChange.listen((event) {
      session.value = event.session;
    });

    super.onInit();
  }

  Future<void> signInWithGoogle() async {
    try {
      loading.value = true;

      const webClientId = "YOUR_WEB_CLIENT_ID.apps.googleusercontent.com";
      const iosClientId = "YOUR_IOS_CLIENT_ID.apps.googleusercontent.com";

      final google = GoogleSignIn(
        serverClientId: webClientId,
        clientId: iosClientId,
      );

      final user = await google.signIn();
      if (user == null) return;

      final auth = await user.authentication;

      if (auth.idToken == null || auth.accessToken == null) {
        throw "Missing Google ID token or access token.";
      }

      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: auth.idToken!,
        accessToken: auth.accessToken!,
      );
    } on AuthException catch (e) {
      Get.snackbar(
        "Auth Error",
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.2),
        colorText: Colors.red,
      );
    } catch (e) {
      Get.snackbar(
        "Login Failed",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.2),
        colorText: Colors.red,
      );
    } finally {
      loading.value = false;
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    await GoogleSignIn().signOut();
  }
}
