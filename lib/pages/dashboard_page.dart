import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/session_controller.dart';
import '../widgets/topic_tile.dart';
import 'session_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dash = Get.put(DashboardController());
    final session = Get.put(SessionController());

    return SafeArea(
      child: Obx(() {
        if (dash.loading.value) return const Center(child: CircularProgressIndicator());
        return CustomScrollView(
          slivers: [
            const SliverAppBar(title: Text('Dashboard'), floating: true),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid.builder(
                itemCount: dash.topics.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.2,
                ),
                itemBuilder: (_, i) {
                  final t = dash.topics[i];
                  return TopicTile(
                    name: t.name,
                    difficulty: t.difficulty,
                    onTap: () {
                      session.start(t.id);
                      Get.to(() => const SessionPage(), transition: Transition.rightToLeft);
                    },
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
