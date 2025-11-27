import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dashboard_page.dart';
import 'saved_page.dart';
import 'ai_flashcard_page.dart';
import 'profile_page.dart';
import '../controllers/saved_controller.dart';

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int idx = 0;
  final pages = const [
    DashboardPage(),
    SavedPage(),
    AiFlashcardPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: idx, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'AI Mode',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onDestinationSelected: (i) {
          setState(() => idx = i);
          if (i == 1) {
            try {
              Get.find<SavedController>().fetchSaved();
            } catch (e) {
              // Controller might not be initialized yet, which is fine
              // as it will fetch on init.
            }
          }
        },
      ),
    );
  }
}
