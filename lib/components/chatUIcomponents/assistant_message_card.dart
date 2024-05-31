import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

// Base class for common styling and properties
abstract class BaseAssistantCard extends StatelessWidget {
  final Widget Function(BuildContext context) buildChild;

  BaseAssistantCard({required this.buildChild});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width *
              0.9, // Max width of 90% of the screen width
        ),
        child: Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: buildChild(context), // Use the passed child widget
        ),
      ),
    );
  }
}

class AssistantMessageCard extends BaseAssistantCard {
  final String message;

  AssistantMessageCard({required this.message})
      : super(
          buildChild: (context) => Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiary,
              fontSize: 16,
            ),
          ),
        );
}

class AssistantLoadingCard extends BaseAssistantCard {
  AssistantLoadingCard()
      : super(
          buildChild: (context) => LoadingAnimationWidget.waveDots(
            color: Theme.of(context).colorScheme.onTertiary,
            size: 24,
          ),
        );
}
