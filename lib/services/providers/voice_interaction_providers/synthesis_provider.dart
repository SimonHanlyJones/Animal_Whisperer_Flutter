import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SynthesisProvider with ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  final StreamController<TtsEvent> _eventController =
      StreamController<TtsEvent>.broadcast();
  bool _isSynthesizing = false;
  String? _lastError;

  SynthesisProvider() {
    _initializeTTS();
  }

  Stream<TtsEvent> get events => _eventController.stream;

  Future<void> _initializeTTS() async {
    _flutterTts.setStartHandler(() {
      _isSynthesizing = true;
      notifyListeners();
    });

    _flutterTts.setCompletionHandler(() {
      _isSynthesizing = false;
      _eventController.add(TtsEvent(type: TtsEventType.completion));
      notifyListeners();
    });

    _flutterTts.setErrorHandler((msg) {
      _lastError = msg;
      _isSynthesizing = false;
      _eventController.add(TtsEvent(type: TtsEventType.error, message: msg));
      notifyListeners();
    });

    await _flutterTts
        .setVoice({"name": "en-au-x-aub-network", "locale": "en-AU"});

    // _flutterTts.setLanguage("en-AU");
    _flutterTts.setPitch(0.8);
  }

  bool get isSynthesizing => _isSynthesizing;
  String? get lastError => _lastError;

  Future speak(String text) async {
    await _flutterTts
        .setVoice({"name": "en-au-x-aub-network", "locale": "en-AU"});
    await _flutterTts.speak(text);
  }

  void stop() async {
    await _flutterTts.stop();
    _isSynthesizing = false;
    notifyListeners();
  }

  void listLanguages() async {
    var languages = await _flutterTts.getLanguages;
    print("Available languages: $languages");
  }

  void listVoices() async {
    var voices = await _flutterTts.getVoices;
    // print("Available voices: $voices");
    for (var voice in voices) {
      if (voice['locale'] != null &&
          (voice['locale'].toLowerCase() == 'en-au')) {
        print('Name: ${voice['name']}, Locale: ${voice['locale']}');
      }
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _eventController.close();
    super.dispose();
  }
}

enum TtsEventType { completion, error }

class TtsEvent {
  final TtsEventType type;
  final String? message;

  TtsEvent({required this.type, this.message});
}
