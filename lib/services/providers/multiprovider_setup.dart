import 'package:Animal_Whisperer/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';
import 'authentication_provider.dart';
import 'chat_messages_provider/chat_messages_provider.dart';
import 'voice_interaction_providers/recognition_provider.dart';
import 'voice_interaction_providers/voice_conversation_context_provider.dart';
import 'voice_interaction_providers/synthesis_provider.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Recognition_ProviderSetup(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthenticationProvider>(
            create: (_) => AuthenticationProvider(),
          ),
          ChangeNotifierProvider<ChatMessagesProvider>(
            create: (_) => ChatMessagesProvider(),
          ),
          ChangeNotifierProvider<SynthesisProvider>(
              create: (_) => SynthesisProvider()),
          ChangeNotifierProxyProvider3<SynthesisProvider, SpeechToTextProvider,
              ChatMessagesProvider, ConversationContext>(
            create: (context) => ConversationContext(),
            update: (context, synthesisProvider, recognitionProvider,
                    chatMessagesProvider, conversationContext) =>
                conversationContext!
                  ..updateDependencies(synthesisProvider, recognitionProvider,
                      chatMessagesProvider),
          ),
        ],
        child: MyApp(),
      ),
    );
  }
}
