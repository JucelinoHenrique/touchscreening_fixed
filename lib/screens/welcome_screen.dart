import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Auth/provider.dart';
import '../backend/database_helper.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  late Future<Map<String, dynamic>?> _nurseDataFuture;

  @override
  void initState() {
    super.initState();
    _nurseDataFuture = dbHelper.getLoggedUserData(); // Busca os dados do enfermeiro logado
  }

  void _welcome() {
    Navigator.pushNamed(context, '/main');
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6C00),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color(0xFFFF6C00),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(27.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'lib/assets/images/LOGO1.png',
                height: 120.0,
              ),
              const SizedBox(height: 20),
              FutureBuilder<Map<String, dynamic>?>( 
                future: _nurseDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text(
                      'Carregando...',
                      style: TextStyle(
                        fontSize: 19.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  } else if (snapshot.hasError || snapshot.data == null) {
                    return const Text(
                      'Olá, Enf.',
                      style: TextStyle(
                        fontSize: 19.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }
                  final nurseData = snapshot.data!;
                  return Text(
                    'Olá, Enf. ${nurseData['name']}',
                    style: const TextStyle(
                      fontSize: 19.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _welcome,
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF6C00),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Entrar'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  authProvider.logout();
                  Navigator.pushReplacementNamed(context, '/');
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Entrar em uma conta diferente',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
