import 'dart:io';
import 'package:Animal_Whisperer/services/providers/authentication_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

class FirebaseManager {
  // AuthenticationProvider authenticationProvider =
  //       Provider.of<AuthenticationProvider>(context, listen: false);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<void> saveImageUrl(String imageUrl) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('images')
          .add({
        'url': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save image URL: $e');
    }
  }

  Future<String> compressUploadSaveImage(File imageFile) async {
    try {
      // Compress the image
      final File compressedImage = await compressImage(imageFile);

      // Upload the compressed image
      final String imageUrl = await uploadImage(compressedImage);

      // Save the image URL to Firestore
      // await saveImageUrl(imageUrl);

      return imageUrl;
    } catch (e) {
      throw Exception('Failed to compress, upload, and save image: $e');
    }
  }

  Future<void> saveChatMessage(
      String chatId, String role, String text, List<String> imageUrls) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'role': role,
        'text': text,
        'imageUrls': imageUrls,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save chat message: $e');
    }
  }

  Future<void> saveChatSession(
      String chatId, DateTime secondMessageTimestamp) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('chats')
          .doc(chatId)
          .set({
        'timestamp': secondMessageTimestamp,
      });
    } catch (e) {
      throw Exception('Failed to save chat session: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchChatHistory() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('chats')
          .orderBy('timestamp', descending: false)
          .get();

      List<Map<String, dynamic>> chatHistory = [];
      for (var doc in querySnapshot.docs) {
        final messagesSnapshot = await doc.reference
            .collection('messages')
            .orderBy('timestamp')
            .get();
        List<Map<String, dynamic>> messages = messagesSnapshot.docs
            .map((messageDoc) => messageDoc.data())
            .toList();
        chatHistory.add({
          'chatId': doc.id,
          'messages': messages,
        });
      }

      return chatHistory;
    } catch (e) {
      throw Exception('Failed to fetch chat history: $e');
    }
  }
}
