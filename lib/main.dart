import 'package:elevate/controllers/auth_controller.dart';
import 'package:elevate/controllers/saved_controller.dart';
import 'package:elevate/pages/login_page.dart';
import 'package:elevate/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:elevate/pages/shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Initialize controllers for dependency injection
  Get.put(AuthController(), permanent: true);
  Get.put(SavedController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Elevate',
      debugShowCheckedModeBanner: false,
      // theme defined in AppTheme
      theme: AppTheme().themeData,
      home: Obx(() {
        final auth = Get.find<AuthController>();
        return auth.session.value != null ? const Shell() : const LoginPage();
      }),
    );
  }
}
