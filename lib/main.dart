import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:touchscreening_fixed/screens/finished_screen.dart';
import './Auth/provider.dart';
import './screens/login_screen.dart';
import './screens/cadastro_screen.dart';
import './screens/main_screen.dart';
import './widgets/connectivity_wrapper.dart';
import './widgets/auth_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Ativa a persistência offline do Firestore
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(ChangeNotifierProvider(
    create: (context) => AuthProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ConnectivityWrapper(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TouchScreening',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          appBarTheme: const AppBarTheme(
            foregroundColor: Colors.white,
          ),
        ),
        // O `home` agora é o nosso widget que verifica a autenticação.
        // Ele decide qual tela mostrar (Login ou Main).
        home: const AuthCheck(),

        // As rotas agora são usadas para navegação SECUNDÁRIA.
        routes: {
          '/login': (context) => const LoginScreen(),
          '/cadastro': (context) => const CadastroScreen(),
          '/main': (context) => const MainScreen(),
          '/finished': (context) => const FinishedScreen(),
        },
      ),
    );
  }
}
