import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      body: Center(
        child: Obx(() {
          return auth.loading.value
              ? const CircularProgressIndicator()
              : ElevatedButton(
                onPressed: auth.signInWithGoogle,
                child: const Text("Sign in with Google"),
              );
        }),
      ),
    );
  }
}
