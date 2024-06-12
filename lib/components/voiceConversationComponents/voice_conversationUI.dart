import 'package:Animal_Whisperer/services/providers/voice_interaction_providers/synthesis_provider.dart';
import 'package:Animal_Whisperer/theme/gradient_container.dart';
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
      body: GradientContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
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
            ConditionalAssistantCard(
              isConversationActive: conversationContext.isConversation,
              isListening: recognitionProvider.isListening,
              isWaitingForResponse: chatMessagesProvider.waitingForResponse,
            ),
            Expanded(
              child: Container(),
            ), // Spacing between mic visualizer and text
            // Conditional text
            _mic_visualiser(recognitionProvider: recognitionProvider),
            SizedBox(height: 20),

            _voice_conversation_footer(context),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _mic_visualiser extends StatelessWidget {
  const _mic_visualiser({
    super.key,
    required this.recognitionProvider,
  });

  final SpeechToTextProvider recognitionProvider;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _voice_conversation_controls extends StatelessWidget {
  const _voice_conversation_controls({
    super.key,
    required this.conversationContext,
  });

  final ConversationContext conversationContext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
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
      ],
    );
  }
}

Widget _voice_conversation_footer(BuildContext context) {
  var conversationContext = Provider.of<ConversationContext>(context);
  return Container(
    color: Theme.of(context).colorScheme.primary,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    child:
        _voice_conversation_controls(conversationContext: conversationContext),
  );
}
