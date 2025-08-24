class Fact {
  final String id;
  final String text;
  final DateTime createdAt;

  Fact({required this.id, required this.text, DateTime? createdAt})
    : createdAt = createdAt ?? DateTime.now();
}
