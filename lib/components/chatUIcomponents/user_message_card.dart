import 'dart:convert';

import 'package:flutter/material.dart';

import '../../models/message.dart';

class UserMessageCard extends StatelessWidget {
  final List<MessageContent> content;
  final Alignment alignment;
  final double maxWidthPercentage;

  UserMessageCard({
    required this.content,
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
            children: content.map((item) {
              if (item.type == 'image_url') {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Image.memory(base64Decode(item.content)),
                );
              } else if (item.type == 'text') {
                return Text(
                  item.content,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                      fontSize: 16),
                );
              } else {
                return SizedBox.shrink();
              }
            }).toList(),
          ),
        ),
      ),
    );
  }
}
