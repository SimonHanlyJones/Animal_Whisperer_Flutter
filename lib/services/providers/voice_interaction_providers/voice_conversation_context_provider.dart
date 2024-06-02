import 'package:Animal_Whisperer/models/message.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';

import 'synthesis_provider.dart';

class ConversationContext with ChangeNotifier {
  bool _isConversation = false;
  Message? _aiMessageForSynthesis;
  SpeechToTextProvider _recognitionProvider;
  SynthesisProvider _synthesisProvider;

  bool get isConversation => _isConversation;
  Message? get aiMessageForSynthesis => _aiMessageForSynthesis;

  ConversationContext({
    required SpeechToTextProvider recognitionProvider,
    required SynthesisProvider synthesisProvider,
  })  : _recognitionProvider = recognitionProvider,
        _synthesisProvider = synthesisProvider;

  void updateDependencies(SynthesisProvider synthesisProvider,
      SpeechToTextProvider speechProvider) {
    _synthesisProvider = synthesisProvider;
    _recognitionProvider = speechProvider;
    notifyListeners(); // Notify listeners if you want the UI to react to these changes
  }

  void startConversation() {
    _aiMessageForSynthesis = null;
    _isConversation = true;
    _recognitionProvider.listen(partialResults: true, soundLevel: true);
    notifyListeners();
  }

  void stopConversation() {
    _aiMessageForSynthesis = null;
    _isConversation = false;
    if (_recognitionProvider.isListening) {
      _recognitionProvider.cancel();
    }
    if (_synthesisProvider.isSynthesizing) {
      _synthesisProvider.stop();
    }
    notifyListeners();
  }

  set aiMessageForSynthesis(Message? message) {
    _aiMessageForSynthesis = message;
    notifyListeners(); // Notify listeners whenever the message updates
  }
}
