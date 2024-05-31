class ChatbotProvider {
  final String name;
  final Function(String) sendMessage;

  ChatbotProvider({required this.name, required this.sendMessage});
}
