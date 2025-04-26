import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import './Auth/provider.dart';
import './screens/login_screen.dart';
import './screens/cadastro_screen.dart';
import './screens/welcome_screen.dart';
import './screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ChangeNotifierProvider(
    create: (context) => AuthProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/cadastro': (context) => const CadastroScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}
