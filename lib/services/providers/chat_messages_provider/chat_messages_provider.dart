import 'dart:convert';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import '../../../models/current_chat_session.dart';
import '../../../models/message.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../firestore_manager.dart';

class ChatMessagesProvider with ChangeNotifier {
  // List<Message> _messages = [];
  bool _waitingForResponse = false;
  bool _waitingForImages = false;
  late final GenerativeModel _model;
  late final FirebaseVertexAI _vertexAI;
  late final ChatSession _googleChatSessions;
  CurrentChatSession _currentChatSession = CurrentChatSession(messages: []);

  ChatMessagesProvider() {
    _initializeVertexAIFirebase(_currentChatSession.systemPrompt);
  }

  Future<void> _initializeVertexAIFirebase(String system_prompt) async {
    final safetySettings = [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
    ];
    _vertexAI = FirebaseVertexAI.instance;
    _model = _vertexAI.generativeModel(
        model: 'gemini-1.5-pro',
        systemInstruction: Content.system(system_prompt),
        safetySettings: safetySettings);
    _googleChatSessions = _model.startChat();
  }

  List<Message> get messages => _currentChatSession.messages;
  bool get waitingForResponse => _waitingForResponse;
  bool get waitingForImages => _waitingForImages;

  void addMessage(Message message) {
    _currentChatSession.addMessage(message);
    notifyListeners();
  }

  Future<Message?> sendMessage(
      {String? text,
      List<File>? images,
      String provider = "firebaseCustom"}) async {
    final FirebaseManager _firebaseManager = FirebaseManager();
    if (text!.isNotEmpty || images!.isNotEmpty) {
      final lastMessage = _currentChatSession.messages.last;
      final time = DateTime.now();
      final timeDifference = time.difference(lastMessage.time).inMilliseconds;

      if (timeDifference <= 300) {
        // Discard the message if it is a duplicate within 300 ms
        return null;
      }
    }

    Message message = Message(role: 'user', text: text); // Add message

    _waitingForImages = true;
    notifyListeners();

    if (images!.isNotEmpty) {
      // needed due to old list being cleaned up
      List<File> copiedImages = List.from(images);
      try {
        for (File image in copiedImages) {
          String url = await _firebaseManager.compressUploadSaveImage(image);

          message.addImageUrl(url);
        }
      } catch (error) {
        throw Exception(
            'Failed to compress, upload, and save image all images: $error');
      } finally {
        _waitingForImages = false;
        notifyListeners();
      }
    }

    _waitingForResponse = true;
    notifyListeners();
    addMessage(message);

    if (provider == "firebaseVertex") {
      // TODO get working?
      // return await _ApiCallFirebaseVertex(message.text);
    }
    return await _ApiCallFirebaseCustom();
    // (provider == "firebaseVertex")
  }

  Future<Message?> _ApiCallFirebaseVertex(String text) async {
    try {
      _waitingForResponse = true;
      notifyListeners();
      GenerateContentResponse result = await _googleChatSessions
          .sendMessage(Content.text(text)); // Adjusted to proper constructor

      // // Read the local image file

      // final imageFile = File('assets/animan512.png');
      // final imageBytes = await imageFile.readAsBytes();
      // // final base64Image = base64Encode(imageBytes);
      // final imagePart = DataPart('image/png', imageBytes);

      // GenerateContentResponse result = await _googleChatSessions.sendMessage(Content.multi(
      //     [TextPart(text), imagePart])); // Adjusted to proper constructor

      if (result.text != null && result.text!.isNotEmpty) {
        final aiResponse = Message(
          time: DateTime.now(),
          role: 'assistant',
          text: result.text!,
        );

        addMessage(aiResponse);
        return aiResponse;
      }
      return null; // Return null if no text is found
    } catch (e) {
      throw Exception('Failed to get ai response: $e');
    } finally {
      _waitingForResponse = false;
      notifyListeners(); // Notify listeners to update UI or state
    }
  }

  Future<Message?> _ApiCallFirebaseCustom() async {
    // NOT WORKING FOR IMAGES, API ONLY ACCEPTS URLs
    try {
      final result =
          await FirebaseFunctions.instance.httpsCallable('animalChat').call({
        "messages": _currentChatSession.messages
            .map((msg) => msg.toOpenAIAPI())
            .toList()
      });

      final aiReponse = Message(
        time: DateTime.now(),
        role: 'assistant',
        text: result.data,
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
