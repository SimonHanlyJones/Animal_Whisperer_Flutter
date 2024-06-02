import 'package:flutter/material.dart';

import '../chatUIcomponents/assistant_message_card.dart';

class AssistantVoiceConversationInfoCard extends BaseAssistantCard {
  final String text;

  AssistantVoiceConversationInfoCard({
    required this.text,
    double maxWidthPercentage = 0.9,
    double minWidthPercentage = 0.9,
    Alignment alignment = Alignment.center,
  }) : super(
          buildChild: (context) => Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiary,
              fontSize: 16,
            ),
          ),
          maxWidthPercentage: maxWidthPercentage,
          alignment: alignment,
        );
}

class ConditionalAssistantCard extends StatelessWidget {
  final bool isConversationActive;
  final bool isListening;
  final bool isWaitingForResponse;

  const ConditionalAssistantCard({
    Key? key,
    required this.isConversationActive,
    required this.isListening,
    required this.isWaitingForResponse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String text = _determineText();
    return AssistantVoiceConversationInfoCard(text: text);
  }

  String _determineText() {
    if (!isConversationActive) {
      return "I'm all ears and ready to listen mate, press the button to have a chat";
    } else if (isListening) {
      return "I'm listening to what you're saying mate\n";
    } else if (isWaitingForResponse) {
      return "Hmm, just give me a sec to think about that\n";
    }
    return ""; // Return empty string if no conditions are met
  }
}
