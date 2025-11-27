class SummaryCard {
  final String title;
  final String summary;
  SummaryCard({required this.title, required this.summary});

  factory SummaryCard.fromMap(Map<String, dynamic> m) =>
      SummaryCard(title: m['title'] ?? '', summary: m['summary'] ?? '');
}
