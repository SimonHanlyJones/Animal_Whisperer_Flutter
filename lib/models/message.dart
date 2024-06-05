import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class MessageContent {
  final String type; // 'text' or 'image_url'
  final String content;

  MessageContent({required this.type, required this.content});
}

class Message {
  final DateTime time;
  final String role; // 'assistant' or 'user' or 'system'
  final List<MessageContent> content;

  Message({required this.time, required this.role, required this.content});

  Map<String, dynamic> toOpenAIAPI() {
    if (content.length == 1 && content.first.type == 'text') {
      // Text-only message
      return {
        'role': role,
        'content': content.first.content,
      };
    } else {
      // Mixed content message
      return {
        'role': role,
        'content': content.map((c) => c.toAPI()).toList(),
      };
    }
  }

  static Future<Message> fromImageFile(
      {required File imageFile, required String role}) async {
    final compressedImage = await FlutterImageCompress.compressWithFile(
      imageFile.absolute.path,
      minWidth: 512,
      minHeight: 512,
      quality: 85,
    );

    if (compressedImage == null) {
      throw Exception('Failed to compress image');
    }

    final base64Image = base64Encode(compressedImage);
    final imageUrl =
        'data:image/jpeg;base64,$base64Image'; // or your logic to store image and get URL

    return Message(
      time: DateTime.now(),
      role: role,
      content: [MessageContent(type: 'image_url', content: imageUrl)],
    );
  }
}

extension on MessageContent {
  Map<String, dynamic> toAPI() {
    return {
      'type': type,
      'content': content,
    };
  }
}
