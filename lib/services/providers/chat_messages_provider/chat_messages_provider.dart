import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import '../../../models/chat_session_summary.dart';
import '../../../models/current_chat_session.dart';
import '../../../models/message.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:logger/logger.dart';
import '../../firestore_manager.dart';

class ChatMessagesProvider with ChangeNotifier {
  bool _waitingForResponse = false;
  bool _waitingForImages = false;
  late final GenerativeModel _model;
  late final FirebaseVertexAI _vertexAI;
  late final ChatSession _googleChatSessions;
  CurrentChatSession _currentChatSession = CurrentChatSession(messages: []);
  String currentChatSessionFirestoreId = '';
  final FirebaseManager _firestoreManager = FirebaseManager();
  final Logger _logger = Logger();

  late List<ChatSessionSummary> _chatHistory;
  List<ChatSessionSummary> get chatHistory => _chatHistory;

  ChatMessagesProvider() {
    _initializeVertexAIFirebase(_currentChatSession.systemPrompt);
    _initializeChatHistory();
  }

  Future<void> deleteChatSession(String fireStoreSessionId) async {
    final sessionIndex =
        _chatHistory.indexWhere((session) => session.id == fireStoreSessionId);
    if (sessionIndex == -1) return;

    final removedSession = _chatHistory.removeAt(sessionIndex);
    notifyListeners();

    try {
      await _firestoreManager.deleteChatSessionAndImages(fireStoreSessionId);

      // Update current chat session if necessary
      if (currentChatSessionFirestoreId == fireStoreSessionId) {
        currentChatSessionFirestoreId = '';
        _currentChatSession = CurrentChatSession(messages: []);
      }

      _chatHistory = await _firestoreManager.getChatHistory();
      notifyListeners();
    } catch (e) {
      // Restore the session in case of an error
      _chatHistory.insert(sessionIndex, removedSession);
      notifyListeners();
      _logger.e('Failed to delete chat session: $e');
    }
  }

  Future<void> _initializeChatHistory() async {
    _chatHistory = await _firestoreManager.getChatHistory();
    notifyListeners();
  }

  Future<String?> _getTitle() async {
    if (_currentChatSession.messages.length < 2 ||
        _currentChatSession.title != null ||
        currentChatSessionFirestoreId.isEmpty) {
      return null;
    }
    Message titleMessage = Message(
        role: "system",
        text:
            "You are a creative title generator. Your job is to read the following chat exchange and provide a funny title for the conversation that is no more than 5 words. Do so in a funny, overenthusiastic, Australian manner like a famous Australian Crocodile Hunter. Include any plausible animal reference and attempt to alliterate if possible. The goal is fun and humor rather than precision. Do not include additional "
            ".");
    List<Message> messagesCopy = List.from(_currentChatSession.messages);
    messagesCopy[0] = titleMessage;

    try {
      Message? title = await _ApiCallFirebaseCustom(messagesCopy);
      if (title != null) {
        _currentChatSession.title = title.text;
        _firestoreManager.updateChatSessionTitle(
            currentChatSessionFirestoreId, _currentChatSession);

        _chatHistory = await _firestoreManager.getChatHistory();
        notifyListeners();
        return title.text;
      }
    } catch (e, stacktrace) {
      _logger.e('Failed to fetch title', error: e, stackTrace: stacktrace);
    }

    return null;
  }

  startNewChat() {
    _currentChatSession = CurrentChatSession(messages: []);
    currentChatSessionFirestoreId = '';
    notifyListeners();
  }

  Future<void> loadChatFromHistory(String chatSessionId) async {
    _currentChatSession = await _firestoreManager.getChatSession(chatSessionId);
    currentChatSessionFirestoreId = chatSessionId;
    notifyListeners();
  }

  Future<void> _initializeVertexAIFirebase(String systemPrompt) async {
    final safetySettings = [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
      SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
    ];
    _vertexAI = FirebaseVertexAI.instance;
    _model = _vertexAI.generativeModel(
        model: 'gemini-1.5-pro',
        systemInstruction: Content.system(systemPrompt),
        safetySettings: safetySettings);
    _googleChatSessions = _model.startChat();
  }

  List<Message> get messages => _currentChatSession.messages;
  bool get waitingForResponse => _waitingForResponse;
  bool get waitingForImages => _waitingForImages;

  void addMessage(Message message) {
    _currentChatSession.addMessage(message);

    // only save messages after the AI has responded
    if (message.role == 'assistant') {
      _saveOrUpdateChatSession();
    }
    notifyListeners();
  }

  Future<void> _saveOrUpdateChatSession() async {
    try {
      if (currentChatSessionFirestoreId.isEmpty &&
          _currentChatSession.messages.length >= 2) {
        // Save chat session
        currentChatSessionFirestoreId =
            await _firestoreManager.saveChatSession(_currentChatSession);
        _chatHistory = await _firestoreManager.getChatHistory();
        notifyListeners();
      } else if (currentChatSessionFirestoreId.isNotEmpty &&
          _currentChatSession.messages.length >= 2) {
        // Update chat session
        await _firestoreManager.updateChatSessionMessages(
            currentChatSessionFirestoreId, _currentChatSession.messages);
      }
    } catch (e, stacktrace) {
      _logger.e('Failed to save or update chat session',
          error: e, stackTrace: stacktrace);
      // _showErrorSnackbar(
      //     context, 'Failed to save or update chat session. Please try again.');
    }

    // Update title
    _getTitle();
  }

  Future<Message?> sendMessage(
      {String? text,
      List<File>? images,
      String provider = "firebaseCustom"}) async {
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

    if (images != null && images.isNotEmpty) {
      _waitingForImages = true;
      notifyListeners();
      // needed due to old list being cleaned up
      List<File> copiedImages = List.from(images);
      try {
        for (File image in copiedImages) {
          String url = await _firestoreManager.compressUploadImage(image);

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
    Message? aiResponse =
        await _ApiCallFirebaseCustom(_currentChatSession.messages);
    if (aiResponse != null) {
      addMessage(aiResponse);
      return aiResponse;
    }
    return null;
  }

  Future<Message?> _ApiCallFirebaseVertex(String text) async {
    try {
      _waitingForResponse = true;
      notifyListeners();
      GenerateContentResponse result = await _googleChatSessions
          .sendMessage(Content.text(text)); // Adjusted to proper constructor

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

  Future<Message?> _ApiCallFirebaseCustom(messages) async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('animalChat')
          .call(
              {"messages": messages.map((msg) => msg.toOpenAIAPI()).toList()});

      final aiResponse = Message(
        time: DateTime.now(),
        role: 'assistant',
        text: result.data,
      );

      return aiResponse;
    } on FirebaseFunctionsException catch (error) {
      throw Exception('Failed to call firebase function: $error');
    } finally {
      _waitingForResponse = false;
      notifyListeners();
    }
  }
}
