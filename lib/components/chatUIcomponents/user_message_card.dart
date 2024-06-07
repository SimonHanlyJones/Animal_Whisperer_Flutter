import 'package:flutter/material.dart';
import '../../models/message.dart';

class UserMessageCard extends StatelessWidget {
  final Message message;
  final Alignment alignment;
  final double maxWidthPercentage;

  UserMessageCard({
    required this.message,
    this.maxWidthPercentage = 0.9, // default to 90% of screen width
    this.alignment = Alignment.centerRight, // default alignment
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width *
              maxWidthPercentage, // Max width of 90% of the screen width
        ),
        child: Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.text != null && message.text!.isNotEmpty)
                Text(
                  message.text!,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                      fontSize: 16),
                ),
              ...message.imageUrls.map((imageUrl) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Image.network(imageUrl),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
