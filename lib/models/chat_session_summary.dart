class ChatSessionSummary {
  final String id;
  String? title;
  final DateTime created;

  ChatSessionSummary({
    required this.id,
    this.title,
    required this.created,
  });
}
