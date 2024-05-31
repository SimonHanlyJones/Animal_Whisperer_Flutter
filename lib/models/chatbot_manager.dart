import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'chatbot_provider.dart';

class ChatbotManager {
  final storage = new FlutterSecureStorage();
  late ChatbotProvider _currentProvider;

  // Example method to switch providers
  void switchProvider(ChatbotProvider provider) {
    _currentProvider = provider;
  }

  // Save API Key securely
  Future<void> saveApiKey(String key) async {
    await storage.write(key: _currentProvider.name, value: key);
  }

  // Send message to the current provider
  Future<String> sendMessage(String message) async {
    String? apiKey = await storage.read(key: _currentProvider.name);
    // Use apiKey to authenticate and send message
    return _currentProvider.sendMessage(message);
  }
}
