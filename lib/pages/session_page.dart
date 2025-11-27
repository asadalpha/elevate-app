import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/session_controller.dart';
import '../widgets/question_flip_card.dart';

class SessionPage extends StatelessWidget {
  const SessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<SessionController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text('Session ${c.idx.value + 1}/${c.questions.length}'),
        ),
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                c.isBookmarked.value ? Icons.bookmark : Icons.bookmark_border,
                color:
                    c.isBookmarked.value
                        ? Theme.of(context).colorScheme.primary
                        : null,
              ),
              onPressed: () => c.toggleBookmark(),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (c.loading.value)
          return const Center(child: CircularProgressIndicator());
        if (c.questions.isEmpty)
          return const Center(child: Text('No questions yet.'));
        final q = c.questions[c.idx.value];
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (c.idx.value + 1) / c.questions.length,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: QuestionFlipCard(
                  question: q.questionText,
                  answer: q.answerText,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.chevron_left),
                      label: const Text('Prev'),
                      onPressed: c.idx.value > 0 ? c.prev : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.chevron_right),
                      label: const Text('Next'),
                      onPressed:
                          c.idx.value < c.questions.length - 1 ? c.next : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
