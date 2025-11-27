class Question {
  final String id;
  final String topicId;
  final String questionText;
  final String answerText;
  final String difficulty;

  Question({
    required this.id,
    required this.topicId,
    required this.questionText,
    required this.answerText,
    required this.difficulty,
  });

  factory Question.fromMap(Map<String, dynamic> m) => Question(
    id: m['id'],
    topicId: m['topic_id'],
    questionText: m['question_text'],
    answerText: m['answer_text'],
    difficulty: m['difficulty'] ?? 'Medium',
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'topic_id': topicId,
    'question_text': questionText,
    'answer_text': answerText,
    'difficulty': difficulty,
  };
}
