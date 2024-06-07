import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../models/user_model.dart';

class AuthenticationProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn =
      GoogleSignIn(clientId: dotenv.env['GOOGLE_SIGN_IN_CLIENT_ID']);
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  Stream<User?> get userChanges => _firebaseAuth.authStateChanges();

  bool isUserAuthenticated() {
    return _firebaseAuth.currentUser != null;
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      _currentUser = _userFromFirebase(result.user);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );
        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        _currentUser = _userFromFirebase(userCredential.user);
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  AppUser? _userFromFirebase(User? user) {
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      photoUrl: user.photoURL,
      location: '', // Add logic to fetch location or handle it separately
    );
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    _googleSignIn.signOut(); // Ensure Google sign out is also handled
    _currentUser = null;
    notifyListeners();
  }
}
