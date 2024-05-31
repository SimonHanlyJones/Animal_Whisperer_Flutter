class Message {
  final DateTime time;
  final String role; // 'assistant' or 'user' or 'system'
  final String message;

  Message({required this.time, required this.role, required this.message});
  Map<String, dynamic> toAPI() {
    return {
      'role': role,
      'content': message,
    };
  }
}
