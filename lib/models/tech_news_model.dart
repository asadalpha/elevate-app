class TechNews {
  final String title;
  final String description;
  final String category;
  final String source;

  TechNews({
    required this.title,
    required this.description,
    required this.category,
    required this.source,
  });

  factory TechNews.fromJson(Map<String, dynamic> json) {
    return TechNews(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      category: json['category'] ?? 'Tech',
      source: json['source'] ?? 'AI Generated',
    );
  }
}
