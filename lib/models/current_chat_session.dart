import 'message.dart';

class CurrentChatSession {
  String? title;
  final DateTime created;
  final List<Message> messages;
  final String systemPrompt =
      "You are a helpful animal expert called the Animal Whisperer. Your job is to help the user with all of their animal care questions. Do so in a funny, overenthusiastic, Australian manner like a famous Australian Crocodile Hunter.";

  CurrentChatSession({
    this.title,
    DateTime? created,
    List<Message>? messages,
  })  : created = created ?? DateTime.now(),
        messages = messages ?? [] {
    // Add the system message if the messages list is empty
    if (this.messages.isEmpty) {
      addMessage(Message(role: 'system', text: systemPrompt));
    }
  }

  void addMessage(Message message) {
    messages.add(message);
  }
}
