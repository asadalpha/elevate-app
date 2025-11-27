class Topic {
  final String id;
  final String name;
  final String description;
  final String difficulty;

  Topic({required this.id, required this.name, required this.description, required this.difficulty});

  factory Topic.fromMap(Map<String, dynamic> m) => Topic(
        id: m['id'],
        name: m['name'],
        description: m['description'] ?? '',
        difficulty: m['difficulty'] ?? 'Medium',
      );
}
