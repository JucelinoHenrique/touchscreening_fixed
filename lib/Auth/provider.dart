import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  // Login normal (usuário e senha) - você já deve ter essa função
  Future<void> login(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    _isAuthenticated = true;
    notifyListeners();
  }

  // Login com Google
  Future<void> loginWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      // Cancelado
      return;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _firebaseAuth.signInWithCredential(credential);
    _isAuthenticated = true;
    notifyListeners();
  }

  void logout() async {
    await _firebaseAuth.signOut();
    _isAuthenticated = false;
    notifyListeners();
  }
}
