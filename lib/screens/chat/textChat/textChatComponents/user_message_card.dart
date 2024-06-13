import 'package:flutter/material.dart';
import '../../../../models/message.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

// Base class for common styling and properties
abstract class BaseUserCard extends StatelessWidget {
  final Widget Function(BuildContext context) buildChild;
  final bool fixedWidth;
  final Alignment alignment;

  BaseUserCard({
    required this.buildChild,
    this.fixedWidth = false, // By default, it behaves dynamically
    this.alignment =
        Alignment.centerRight, // default alignment for user messages
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: buildChild(context),
    );

    if (fixedWidth) {
      // Fixed width mode
      card = SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 76,
        child: card,
      );
    } else {
      // Dynamic width mode
      card = ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: card,
      );
    }

    return Align(
      alignment: alignment,
      child: card,
    );
  }
}

class UserMessageCard extends BaseUserCard {
  final Message message;

  UserMessageCard({required this.message})
      : super(
          buildChild: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.text != null && message.text!.isNotEmpty)
                Text(
                  message.text!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontSize: 16,
                  ),
                ),
              ...message.imageUrls.map((imageUrl) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Image.network(imageUrl),
                );
              }).toList(),
            ],
          ),
        );
}

class UserLoadingCard extends BaseUserCard {
  UserLoadingCard()
      : super(
          buildChild: (context) => LoadingAnimationWidget.waveDots(
            color: Theme.of(context).colorScheme.onSecondary,
            size: 24,
          ),
        );
}
