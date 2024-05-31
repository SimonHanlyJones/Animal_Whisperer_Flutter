import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import '../../../models/message.dart';

class ChatMessagesProvider with ChangeNotifier {
  List<Message> _messages = [];
  bool _waitingForResponse = false;

  ChatMessagesProvider() {
    // Add initial system message
    addMessage(Message(
        time: DateTime.now(),
        role: 'system',
        message:
            "You are a helpful animal expert called the Animal Whisperer. Your job is to help the user with all of their animal care questions. Do so in a funny, overenthusiastic, Australian manner like a famous Australian Crocodile Hunter."));
  }

  List<Message> get messages => _messages;
  bool get waitingForResponse => _waitingForResponse;

  void addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  void addMessages(List<Message> messages) {
    _messages.addAll(messages);
    notifyListeners();
  }

  Future<Message?> sendMessage(String text) async {
    _waitingForResponse = true;
    notifyListeners();

    addMessage(Message(time: DateTime.now(), role: 'user', message: text));

    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('animalChat')
          .call({"messages": _messages.map((msg) => msg.toAPI()).toList()});

      final aiReponse = Message(
        time: DateTime.now(),
        role: 'assistant',
        message: result.data,
      );

      addMessage(aiReponse);
      return aiReponse;
    } on FirebaseFunctionsException catch (error) {
      // TODO: logging framework
      print(error.code);
      print(error.details);
      print(error.message);
      return null;
    } finally {
      _waitingForResponse = false;
      notifyListeners();
    }
  }
}
