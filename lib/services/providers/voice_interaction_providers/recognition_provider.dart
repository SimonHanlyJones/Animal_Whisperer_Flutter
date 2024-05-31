import 'dart:async';

import 'package:Animal_Whisperer/screens/conversation_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';

import '../../../components/conversationComponents/recognition_provider_example_widget.dart';

class Recognition_ProviderSetup extends StatefulWidget {
  final Widget child;
  const Recognition_ProviderSetup({Key? key, required this.child})
      : super(key: key);

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
