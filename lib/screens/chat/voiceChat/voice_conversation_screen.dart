import 'dart:async';

import 'package:Animal_Whisperer/services/providers/voice_interaction_providers/synthesis_provider.dart';
import 'package:Animal_Whisperer/services/providers/voice_interaction_providers/voice_conversation_context_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_event.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';

import 'voiceConversationComponents/voice_conversationUI.dart';
import '../../../services/providers/chat_messages_provider/chat_messages_provider.dart';

class ConversationScreen extends StatefulWidget {
  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  late ConversationContext conversationContext;

  @override
  void initState() {
    super.initState();
    conversationContext =
        Provider.of<ConversationContext>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      conversationContext.startConversation();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    await conversationContext.stopConversation();
    return true; // Allows the pop to happen
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              await conversationContext.stopConversation();
              Navigator.of(context).pop();
            },
          ),
          title: Text('Lets have a chat!'),
        ),
        body: ConversationScreenUI(),
      ),
    );
  }
}
