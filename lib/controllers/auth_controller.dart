import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  final Rxn<Session> session = Rxn<Session>();
  final RxBool loading = false.obs;

  @override
  void onInit() {
    session.value = supabase.auth.currentSession;

    supabase.auth.onAuthStateChange.listen((data) {
      session.value = data.session;
    });

    super.onInit();
  }

  Future<void> signInWithGoogle() async {
    try {
      loading.value = true;

      const scopes = ['email', 'profile'];

      final googleSignIn = GoogleSignIn.instance;

      await googleSignIn.initialize(
        // For Android, clientId is NOT required
        serverClientId: dotenv.env['WEB_CLIENT_ID'],
      );

      final googleUser =
          //await googleSignIn.signIn() ??
          await googleSignIn.authenticate();

      final authorization =
          await googleUser.authorizationClient.authorizationForScopes(scopes) ??
          await googleUser.authorizationClient.authorizeScopes(scopes);

      final idToken = googleUser.authentication.idToken;

      if (idToken == null) {
        throw const AuthException('No Google ID Token found');
      }

      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: authorization.accessToken,
      );
    } catch (e) {
      Get.snackbar(
        'Auth Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      loading.value = false;
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    await GoogleSignIn.instance.signOut();
  }

  bool get isLoggedIn => session.value != null;
}
