import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

// Base class for common styling and properties
abstract class BaseAssistantCard extends StatelessWidget {
  final Widget Function(BuildContext context) buildChild;
  final Alignment alignment;
  final double maxWidthPercentage;
  final double minWidthPercentage;

  BaseAssistantCard({
    required this.buildChild,
    this.maxWidthPercentage = 0.9, // default to 90% of screen width
    this.alignment = Alignment.centerLeft, // default alignment
    this.minWidthPercentage = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * maxWidthPercentage,
          minWidth: MediaQuery.of(context).size.width * minWidthPercentage,
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
