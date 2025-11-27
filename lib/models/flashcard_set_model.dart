import 'dart:convert';
import 'question_model.dart';

class FlashcardSet {
  final String id;
  final String topic;
  final DateTime createdAt;
  final List<Question> questions;

  FlashcardSet({
    required this.id,
    required this.topic,
    required this.createdAt,
    required this.questions,
  });

  factory FlashcardSet.fromMap(Map<String, dynamic> map) {
    return FlashcardSet(
      id: map['id'],
      topic: map['topic'],
      createdAt: DateTime.parse(map['created_at']),
      questions: List<Question>.from(
        map['questions']?.map((x) => Question.fromMap(x)) ?? [],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'topic': topic,
      'created_at': createdAt.toIso8601String(),
      'questions': questions.map((x) => x.toMap()).toList(),
    };
  }

  String toJson() => json.encode(toMap());

  factory FlashcardSet.fromJson(String source) =>
      FlashcardSet.fromMap(json.decode(source));
}
