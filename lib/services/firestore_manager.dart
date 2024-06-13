import 'dart:io';
import 'package:Animal_Whisperer/models/current_chat_session.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../models/chat_session_summary.dart';
import '../models/message.dart';

class FirebaseManager {
  // AuthenticationProvider authenticationProvider =
  //       Provider.of<AuthenticationProvider>(context, listen: false);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> deleteChatSession(String sessionId) async {
    try {
      // Fetch the chat session
      CurrentChatSession session = await getChatSession(sessionId);

      // Extract image URLs
      List<String> imageUrls =
          session.messages.expand((message) => message.imageUrls).toList();

      // Delete images
      await _deleteImages(imageUrls);

      // Delete chat session from Firestore
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('chatSessions')
          .doc(sessionId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete chat session: $e');
    }
  }

  Future<void> _deleteImages(List<String> imageUrls) async {
    try {
      for (String url in imageUrls) {
        await _storage.refFromURL(url).delete();
      }
    } catch (e) {
      throw Exception('Failed to delete images: $e');
    }
  }

  Future<File> compressImage(File imageFile) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath =
        path.join(tempDir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');

    final compressedXFile = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      targetPath,
      quality: 60,
      minWidth: 512,
      minHeight: 512,
    );

    if (compressedXFile == null) {
      throw Exception('Failed to compress image');
    }

    return File(compressedXFile.path);
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Define the storage reference
      // Upload the image to "user/<UID>/path/to/file"
      final Reference storageRef = _storage.ref().child(
          'user/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      // Upload the image
      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot taskSnapshot = await uploadTask;

      // Check if the upload was successful
      if (taskSnapshot.state == TaskState.success) {
        final String url = await taskSnapshot.ref.getDownloadURL();
        // print("Image uploaded successfully. URL: $url");
        return url;
      } else {
        throw Exception('Image upload failed: ${taskSnapshot.state}');
      }
    } catch (e) {
      // print('Failed to upload image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<String> compressUploadImage(File imageFile) async {
    try {
      // Compress the image
      final File compressedImage = await compressImage(imageFile);

      // Upload the compressed image
      final String imageUrl = await uploadImage(compressedImage);

      return imageUrl;
    } catch (e) {
      throw Exception('Failed to compress, upload, and save image: $e');
    }
  }

  Future<String> saveChatSession(CurrentChatSession session) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final docRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('chatSessions')
          .add({
        'title': session.title,
        'created': session.created,
        'messages': session.messages
            .map((message) => {
                  'time': message.time,
                  'role': message.role,
                  'text': message.text,
                  'imageUrls': message.imageUrls,
                })
            .toList(),
        'systemPrompt': session.systemPrompt,
      });

      // Optionally return the document ID
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save chat session: $e');
    }
  }

  Future<void> updateChatSessionMessages(
      String sessionId, List<Message> messages) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('chatSessions')
          .doc(sessionId);

      await docRef.update({
        'messages': messages
            .map((message) => {
                  'time': message.time,
                  'role': message.role,
                  'text': message.text,
                  'imageUrls': message.imageUrls,
                })
            .toList(),
      });
    } catch (e) {
      throw Exception('Failed to update chat session messages: $e');
    }
  }

  Future<void> updateChatSessionTitle(
      String sessionId, CurrentChatSession chatSession) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      if (chatSession.title == null || chatSession.title!.isEmpty) {
        return;
      }

      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('chatSessions')
          .doc(sessionId);

      await docRef.update({'title': chatSession.title});
    } catch (e) {
      throw Exception('Failed to update chat session title: $e');
    }
  }

  Future<List<ChatSessionSummary>> getChatHistory() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('chatSessions')
          .orderBy('created', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        return ChatSessionSummary(
          id: doc.id,
          title: data['title'],
          created: (data['created'] as Timestamp).toDate(),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get chat session summaries: $e');
    }
  }

  Future<CurrentChatSession> getChatSession(String sessionId) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('chatSessions')
          .doc(sessionId)
          .get();

      if (!doc.exists) {
        throw Exception('Chat session not found');
      }

      final data = doc.data() as Map<String, dynamic>;

      return CurrentChatSession(
        title: data['title'],
        created: (data['created'] as Timestamp).toDate(),
        messages: (data['messages'] as List<dynamic>).map((message) {
          final messageData = message as Map<String, dynamic>;
          return Message(
            time: (messageData['time'] as Timestamp).toDate(),
            role: messageData['role'],
            text: messageData['text'],
            imageUrls: List<String>.from(messageData['imageUrls']),
          );
        }).toList(),
      );
    } catch (e) {
      throw Exception('Failed to get chat session details: $e');
    }
  }
}
