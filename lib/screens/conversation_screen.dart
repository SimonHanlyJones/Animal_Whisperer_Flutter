import 'dart:async';

import 'package:Animal_Whisperer/models/message.dart';
import 'package:Animal_Whisperer/services/providers/voice_interaction_providers/synthesis_provider.dart';
import 'package:Animal_Whisperer/services/providers/voice_interaction_providers/voice_conversation_context_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_event.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';
// import '../components/conversationComponents/voice_recognition_use_for_micLevels.dart';
import '../components/conversationComponents/recognition_provider_example_widget.dart';
import '../services/providers/chat_messages_provider/chat_messages_provider.dart';

class ConversationScreen extends StatefulWidget {
  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  late ConversationContext conversationContext;
  late ChatMessagesProvider chatMessagesProvider;
  late SynthesisProvider synthesisProvider;

  StreamSubscription<SpeechRecognitionEvent>? _recognitionSubscription;
  late SpeechToTextProvider recognitionProvider;
  StreamSubscription<TtsEvent>? _synthesisSubscription;

  @override
  void initState() {
    super.initState();
    conversationContext =
        Provider.of<ConversationContext>(context, listen: false);
    recognitionProvider =
        Provider.of<SpeechToTextProvider>(context, listen: false);
    synthesisProvider = Provider.of<SynthesisProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      conversationContext.startConversation();
    });
    _recognitionSubscription =
        recognitionProvider.stream.listen(_handleSpeechEvent);
    _synthesisSubscription =
        synthesisProvider.events.listen(_handleSynthesisEvent);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    chatMessagesProvider = Provider.of<ChatMessagesProvider>(context);

    conversationContext = Provider.of<ConversationContext>(context);

    synthesisProvider = Provider.of<SynthesisProvider>(context);

    chatMessagesProvider.addListener(_checkAndSynthesizeResponse);
    conversationContext.addListener(_checkAndSynthesizeResponse);

    // conversationContext.addListener(_handleConversationChange);
  }

  Future<void> _handleSynthesisEvent(TtsEvent event) async {
    if (event.type == TtsEventType.error && event.message != null) {
      // print("Error: ${event.message}");
      conversationContext.stopConversation();
      // Handle error
    } else if (event.type == TtsEventType.completion) {
      // Handle completion
      if (conversationContext.isConversation) {
        recognitionProvider.listen(partialResults: true, soundLevel: true);
      }
    }
  }

// Timer variable
  Timer? _debounceTimerMessage;

  Future<void> _handleSpeechEvent(SpeechRecognitionEvent event) async {
    // Handle the error event immediately
    if (event.eventType == SpeechRecognitionEventType.errorEvent &&
        event.error != null) {
      print("Error: ${event.error}");
      conversationContext.stopConversation();
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

      conversationContext.aiMessageForSynthesis = await chatMessagesProvider
          .sendMessage(event.recognitionResult!.recognizedWords);
    }
  }

  Timer? _synthesisTimer;
  Future<void> _checkAndSynthesizeResponse() async {
    if (conversationContext.isConversation &&
        !chatMessagesProvider.waitingForResponse &&
        chatMessagesProvider.messages.last.role == 'assistant' &&
        !synthesisProvider.isSynthesizing &&
        !recognitionProvider.isListening &&
        conversationContext.aiMessageForSynthesis != null) {
      if (_synthesisTimer?.isActive == true) return;

      _synthesisTimer = Timer(Duration(milliseconds: 300), () {});
      String text = conversationContext.aiMessageForSynthesis!.message;
      conversationContext.aiMessageForSynthesis = null;
      await synthesisProvider.speak(text);
    }
  }

  @override
  void dispose() {
    conversationContext.stopConversation();
    chatMessagesProvider.removeListener(_checkAndSynthesizeResponse);
    conversationContext.removeListener(_checkAndSynthesizeResponse);

    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversation'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                final speechProvider =
                    Provider.of<SpeechToTextProvider>(context, listen: false);
                if (!speechProvider.isListening) {
                  speechProvider.listen(partialResults: true, soundLevel: true);
                }
              },
              child: Text('Start Listening'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                final conversationContext =
                    Provider.of<ConversationContext>(context, listen: false);
                if (conversationContext.isConversation) {
                  conversationContext.stopConversation();
                } else {
                  conversationContext.startConversation();
                }
              },
              child: Text(
                Provider.of<ConversationContext>(context).isConversation
                    ? 'Stop Conversation'
                    : 'Start Conversation',
              ),
            ),
          ),
          Expanded(
            child: SpeechProviderExampleWidget(),
          ),
        ],
      ),
    );
  }
}
