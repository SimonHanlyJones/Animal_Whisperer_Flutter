import 'package:Animal_Whisperer/services/providers/voice_interaction_providers/synthesis_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';

import '../../services/providers/chat_messages_provider/chat_messages_provider.dart';
import '../../services/providers/voice_interaction_providers/voice_conversation_context_provider.dart';
import 'assistant_voice_conversation_card.dart';

class ConversationScreenUI extends StatefulWidget {
  @override
  State<ConversationScreenUI> createState() => _ConversationScreenUIState();
}

class _ConversationScreenUIState extends State<ConversationScreenUI>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;
  late SynthesisProvider synthesisProvider;
  late ConversationContext conversationContext;
  late ChatMessagesProvider chatMessagesProvider;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 0.08).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    synthesisProvider = Provider.of<SynthesisProvider>(context);
    conversationContext = Provider.of<ConversationContext>(context);
    chatMessagesProvider = Provider.of<ChatMessagesProvider>(context);
    // synthesisProvider.listVoices();

    if (synthesisProvider.isSynthesizing) {
      _controller?.repeat(reverse: true);
    } else {
      _controller?.stop();
      _controller?.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    var recognitionProvider = Provider.of<SpeechToTextProvider>(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomLeft,
          colors: [
            Theme.of(context).colorScheme.surfaceContainer,
            Theme.of(context).colorScheme.surfaceContainerHigh,
          ], // Customize your gradient colors here
        )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circle image at the top/middle
            Center(
              child: RotationTransition(
                turns: _animation!,
                child: CircleAvatar(
                  radius: 200.0,
                  backgroundColor: const Color.fromARGB(0, 255, 255, 255),
                  backgroundImage: AssetImage(
                      'assets/animan512.png'), // Make sure to add your image in the assets folder
                ),
              ),
            ),
            SizedBox(height: 20), // Spacing between image and mic visualizer
            // Microphone with levels visualizer
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      blurRadius: .26,
                      spreadRadius: recognitionProvider.lastLevel * 2.0,
                      color: Colors.white.withOpacity(.20))
                ],
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(50)),
              ),
              child: IconButton(
                icon: const Icon(Icons.mic),
                onPressed: () {
                  // Handle microphone button press
                },
              ),
            ),
            SizedBox(height: 80), // Spacing between mic visualizer and text
            // Conditional text
            ConditionalAssistantCard(
              isConversationActive: conversationContext.isConversation,
              isListening: recognitionProvider.isListening,
              isWaitingForResponse: chatMessagesProvider.waitingForResponse,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).colorScheme.primary,
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  // onPrimary: Theme.of(context).colorScheme.onSecondary,
                ),
                onPressed: () {
                  if (conversationContext.isConversation) {
                    conversationContext.stopConversation();
                  } else {
                    conversationContext.startConversation();
                  }
                },
                child: Text(
                    conversationContext.isConversation
                        ? 'Stop Conversation'
                        : 'Start Conversation',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                    )),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
