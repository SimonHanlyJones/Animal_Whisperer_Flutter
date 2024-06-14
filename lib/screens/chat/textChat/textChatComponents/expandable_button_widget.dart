import 'dart:io';
import 'package:Animal_Whisperer/screens/chat/voiceChat/voice_conversation_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../services/providers/chat_messages_provider/chat_messages_provider.dart';

class ExpandableButtonWidget extends StatefulWidget {
  const ExpandableButtonWidget({
    super.key,
    required this.addImage,
  });
  final Function(File?) addImage;

  @override
  State<ExpandableButtonWidget> createState() => _ExpandableButtonWidgetState();
}

class _ExpandableButtonWidgetState extends State<ExpandableButtonWidget> {
  bool _isExpanded = false;

  final ImagePicker _picker = ImagePicker();

  void _captureImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      widget.addImage(File(image.path));
    }
  }

  void _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      widget.addImage(File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatMessagesProvider = Provider.of<ChatMessagesProvider>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _isExpanded ? 146 : 0,
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.photo_camera,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: _captureImage,
              ),
              IconButton(
                icon: Icon(
                  Icons.image,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: _pickImage,
              ),
              IconButton(
                icon: Icon(
                  Icons.phone,
                  color: chatMessagesProvider.waitingForResponse
                      ? Colors.grey
                      : Theme.of(context).colorScheme.secondary,
                ),
                onPressed: chatMessagesProvider.waitingForResponse ||
                        chatMessagesProvider.waitingForImages
                    ? null
                    : () {
                        Future.delayed(const Duration(milliseconds: 300), () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ConversationScreen(),
                            ),
                          );
                        });
                      },
              ),
            ],
          ),
        ),
        IconButton.filled(
          icon: Icon(_isExpanded ? Icons.cancel : Icons.add_circle),
          color: Theme.of(context).colorScheme.secondary,
          iconSize: 32,
          onPressed: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
        ),
      ],
    );
  }
}
