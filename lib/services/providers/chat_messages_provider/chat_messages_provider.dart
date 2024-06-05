import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import '../../../models/message.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:firebase_core/firebase_core.dart';

class ChatMessagesProvider with ChangeNotifier {
  List<Message> _messages = [];
  bool _waitingForResponse = false;
  late final FirebaseVertexAI _vertexAI;
  late final GenerativeModel _model;
  late final ChatSession _chat;

  ChatMessagesProvider() {
    // Add initial system message
    String system_prompt =
        "You are a helpful animal expert called the Animal Whisperer. Your job is to help the user with all of their animal care questions. Do so in a funny, overenthusiastic, Australian manner like a famous Australian Crocodile Hunter.";
    MessageContent system_prompt_content =
        MessageContent(type: 'text', content: system_prompt);

    _initializeVertexAIFirebase(system_prompt = system_prompt);

    addMessage(Message(
        time: DateTime.now(),
        role: 'system',
        content: [system_prompt_content]));
  }

  Future<void> _initializeVertexAIFirebase(String system_prompt) async {
    _vertexAI = FirebaseVertexAI.instance;
    _model = _vertexAI.generativeModel(
        model: 'gemini-1.5-flash',
        systemInstruction: Content.system(system_prompt));
    _chat = _model.startChat();
  }

  List<Message> get messages => _messages;
  bool get waitingForResponse => _waitingForResponse;

  void addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  Future<Message?> sendMessage(
      {required String text, String provider = "firebaseCustom"}) async {
    if (_messages.isNotEmpty) {
      final lastMessage = _messages.last;
      final time = DateTime.now();
      final timeDifference = time.difference(lastMessage.time).inMilliseconds;

      if (timeDifference <= 300) {
        // Discard the message if it is a duplicate within 300 ms
        return null;
      }
    }
    _waitingForResponse = true;
    notifyListeners();

    addMessage(Message(
        time: DateTime.now(),
        role: 'user',
        content: [MessageContent(type: 'text', content: text)]));

    if (provider == "firebaseCustom")
      return await _ApiCallFirebaseCustom();
    else
    // (provider == "firebaseVertex")
    {
      return await _ApiCallFirebaseVertex(text);
    }
  }

  Future<Message?> _ApiCallFirebaseVertex(String text) async {
    try {
      _waitingForResponse = true;
      GenerateContentResponse result = await _chat
          .sendMessage(Content.text(text)); // Adjusted to proper constructor

      if (result.text != null && result.text!.isNotEmpty) {
        final aiResponse = Message(
          time: DateTime.now(),
          role: 'assistant',
          content: [MessageContent(type: 'text', content: result.text!)],
        );

        addMessage(aiResponse);
        return aiResponse;
      }
      return null; // Return null if no text is found
    } catch (e) {
      print("An error occurred: $e"); // Log or handle the error as needed
      return null; // Optionally handle the error by returning a default message or null
    } finally {
      _waitingForResponse = false;
      notifyListeners(); // Notify listeners to update UI or state
    }
  }

  Future<Message?> _ApiCallFirebaseCustom() async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('animalChat')
          .call(
              {"messages": _messages.map((msg) => msg.toOpenAIAPI()).toList()});
      print("MESSAGES OUTPUT");
      print(_messages.map((msg) => msg.toOpenAIAPI()).toList());

      final aiReponse = Message(
        time: DateTime.now(),
        role: 'assistant',
        content: [MessageContent(type: 'text', content: result.data)],
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
