import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../services/providers/chat_messages_provider/chat_messages_provider.dart';
import 'assistant_message_card.dart';

class BlankScreenContent extends StatelessWidget {
  const BlankScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> exampleQuestions = [
      "🐱\n Why do cats purr?",
      "🐶\n Do dogs dream?",
      "🐆\n How fast can a cheetah run?",
      "🐦\n Why do birds sing?",
      "🦘\n How high do kangaroos jump?",
      "🐠\n How do fish breathe underwater?",
      "🐘\n Why do elephants have big ears?",
    ];

    return Expanded(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: exampleQuestions.map((question) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ExampleQuestionCard(question: question),
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ExampleQuestionCard extends BaseAssistantCard {
  final String question;

  ExampleQuestionCard({super.key, required this.question})
      : super(
            buildChild: (context) {
              final chatMessagesProvider =
                  Provider.of<ChatMessagesProvider>(context, listen: false);
              return GestureDetector(
                onTap: () {
                  chatMessagesProvider.sendMessage(text: question);
                },
                child: Text(
                  question,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onTertiary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
            fixedWidth: true,
            alignment: Alignment.center);
}

class MessageList extends StatelessWidget {
  final List<String> messages;

  const MessageList({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(messages[index]),
        );
      },
    );
  }
}
