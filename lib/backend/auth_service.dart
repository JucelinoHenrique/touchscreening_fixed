import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Registrar novo usuário
  Future<UserCredential?> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      print("Erro ao registrar: $e");
      return null;
    }
  }

  // Login com email e senha
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      print("Erro ao logar: $e");
      return null;
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Verificar se usuário está logado
  User? get currentUser => _auth.currentUser;
}
