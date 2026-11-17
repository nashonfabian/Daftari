class PageEntry {
  const PageEntry({
    this.id,
    required this.title,
    required this.body,
    required this.date,
  });

  final int? id;
  final String title;
  final String body;
  final DateTime date;

  Map<String, Object?> toMap() => {
        'title': title,
        'body': body,
        'page_date': date.toIso8601String().substring(0, 10),
        'updated_at': DateTime.now().toIso8601String(),
      };

  factory PageEntry.fromMap(Map<String, Object?> map) => PageEntry(
        id: map['id'] as int,
        title: map['title'] as String,
        body: map['body'] as String,
        date: DateTime.parse(map['page_date'] as String),
      );
}
