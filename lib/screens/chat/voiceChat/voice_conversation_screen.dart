import 'dart:async';

import 'package:Animal_Whisperer/services/providers/voice_interaction_providers/voice_conversation_context_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'voiceConversationComponents/voice_conversationUI.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              await conversationContext.stopConversation();
              Navigator.of(context).pop();
            },
          ),
          title: const Text('Lets have a chat!'),
        ),
        body: const ConversationScreenUI(),
      ),
    );
  }
}
