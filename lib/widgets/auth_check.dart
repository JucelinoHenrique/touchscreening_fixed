import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:touchscreening_fixed/screens/login_screen.dart';
import 'package:touchscreening_fixed/screens/welcome_screen.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Ouve em tempo real as mudanças no estado de autenticação do Firebase
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF6C00),
              ),
            ),
          );
        }

        // Se o snapshot tem dados, significa que o usuário está logado
        if (snapshot.hasData) {
          // Navega para a tela principal
          return const WelcomeScreen();
        }

        // Se não tem dados, o usuário não está logado
        return const LoginScreen();
      },
    );
  }
}
