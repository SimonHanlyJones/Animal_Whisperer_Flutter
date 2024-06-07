import 'dart:async';

import 'package:Animal_Whisperer/models/message.dart';
import 'package:Animal_Whisperer/services/providers/chat_messages_provider/chat_messages_provider.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_event.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';

import 'synthesis_provider.dart';

class ConversationContext with ChangeNotifier {
  bool _isConversation = false;
  Message? _aiMessageForSynthesis;
  late SpeechToTextProvider _recognitionProvider;
  late SynthesisProvider _synthesisProvider;
  late ChatMessagesProvider _chatMessagesProvider;
  StreamSubscription<SpeechRecognitionEvent>? _recognitionSubscription;
  StreamSubscription<TtsEvent>? _synthesisSubscription;

  bool get isConversation => _isConversation;
  Message? get aiMessageForSynthesis => _aiMessageForSynthesis;

  ConversationContext();

  void updateDependencies(
      SynthesisProvider synthesisProvider,
      SpeechToTextProvider speechProvider,
      ChatMessagesProvider chatMessagesProvider) {
    _synthesisProvider = synthesisProvider;
    _recognitionProvider = speechProvider;
    _chatMessagesProvider = chatMessagesProvider;
    _subscribeToEvents();

    notifyListeners(); // Notify listeners if you want the UI to react to these changes
  }

  void _subscribeToEvents() {
    _recognitionSubscription =
        _recognitionProvider.stream.listen(_handleSpeechEvent);
    _synthesisSubscription =
        _synthesisProvider.events.listen(_handleSynthesisEvent);
  }

  Future<void> _handleSynthesisEvent(TtsEvent event) async {
    if (event.type == TtsEventType.error && event.message != null) {
      // print("Error: ${event.message}");
      stopConversation();
      // Handle error
    } else if (event.type == TtsEventType.completion) {
      // Handle completion
      if (isConversation) {
        _recognitionProvider.listen(partialResults: true, soundLevel: true);
      }
    }
  }

  Timer? _debounceTimerMessage;
  Future<void> _handleSpeechEvent(SpeechRecognitionEvent event) async {
    // Handle the error event immediately
    if (event.eventType == SpeechRecognitionEventType.errorEvent &&
        event.error != null) {
      print("Error: ${event.error}");
      stopConversation();
      // Handle error
    } else if (event.eventType ==
            SpeechRecognitionEventType.finalRecognitionEvent &&
        event.recognitionResult != null &&
        // event.recognitionResult!.recognizedWords != null &&
        event.recognitionResult!.recognizedWords.trim().isNotEmpty) {
      // If debounce is active, ignore this event
      if (_debounceTimerMessage?.isActive == true) return;

      _debounceTimerMessage = Timer(Duration(milliseconds: 300), () {});
      // Send the message

      aiMessageForSynthesis = await _chatMessagesProvider.sendMessage(
          text: event.recognitionResult!.recognizedWords);
      _checkAndSynthesizeResponse(aiMessageForSynthesis);
    }
  }

  Timer? _synthesisTimer;
  Future<void> _checkAndSynthesizeResponse(aiMessageForSynthesis) async {
    if (isConversation &&
        !_chatMessagesProvider.waitingForResponse &&
        _chatMessagesProvider.messages.last.role == 'assistant' &&
        aiMessageForSynthesis != null) {
      if (_synthesisTimer?.isActive == true) return;

      _synthesisTimer = Timer(Duration(milliseconds: 300), () {});
      String text = aiMessageForSynthesis!.text;
      aiMessageForSynthesis = null;
      await _synthesisProvider.speak(text);
    }
  }

  void startConversation() {
    _aiMessageForSynthesis = null;
    _isConversation = true;
    _recognitionProvider.listen(partialResults: true, soundLevel: true);
    notifyListeners();
  }

  Future<void> stopConversation() async {
    _aiMessageForSynthesis = null;
    _isConversation = false;
    if (_recognitionProvider.isListening) {
      _recognitionProvider.cancel();
    }
    if (_synthesisProvider.isSynthesizing) {
      await _synthesisProvider.stop();
    }
    notifyListeners();
  }

  set aiMessageForSynthesis(Message? message) {
    _aiMessageForSynthesis = message;
    notifyListeners(); // Notify listeners whenever the message updates
  }

  @override
  void dispose() {
    _recognitionSubscription?.cancel();
    _synthesisSubscription?.cancel();
    _synthesisTimer?.cancel();
    _debounceTimerMessage?.cancel();

    super.dispose();
  }
}
