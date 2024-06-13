import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';

class Recognition_ProviderSetup extends StatefulWidget {
  final Widget child;
  const Recognition_ProviderSetup({super.key, required this.child});

  @override
  State<Recognition_ProviderSetup> createState() =>
      _Recognition_ProviderSetupState();
}

class _Recognition_ProviderSetupState extends State<Recognition_ProviderSetup> {
  final SpeechToText speech = SpeechToText();
  late SpeechToTextProvider speechProvider;

  @override
  void initState() {
    super.initState();
    speechProvider = SpeechToTextProvider(speech);
    initSpeechState();
  }

  Future<void> initSpeechState() async {
    await speechProvider.initialize();
    await speech.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SpeechToTextProvider>.value(
      value: speechProvider,
      child: widget.child,
    );
  }
}
