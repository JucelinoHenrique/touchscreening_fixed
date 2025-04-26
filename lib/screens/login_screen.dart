import 'package:flutter/material.dart';
import 'package:touchscreening_fixed/backend/database_helper.dart';
import 'package:flutter_tts/flutter_tts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DatabaseHelper dbHelper = DatabaseHelper();
  final FlutterTts _tts = FlutterTts();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Narra mensagem de introdução ao carregar a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speak(
          'Bem-vindo à tela de login. Por favor, insira seu usuário e senha.');
    });
  }

  Future<void> _speak(String text) async {
    await _tts.setLanguage('pt-BR');
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
    await _tts.speak(text);
  }

  Future<void> _login() async {
    final String user = _userController.text.trim();
    final String password = _passwordController.text.trim();

    if (user.isEmpty || password.isEmpty) {
      _showSnackBar('Por favor, preencha todos os campos.');
      _speak('Por favor, preencha todos os campos.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Verifica se o usuário existe no banco de dados
      final userData = await dbHelper.verifyUser(user, password);

      if (userData != null) {
        // Salva o usuário logado nos SharedPreferences
        await dbHelper.saveLoggedUser(user);

        // Narra mensagem de sucesso
        _speak('Login realizado com sucesso.');
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/welcome');
        }
      } else {
        _showSnackBar('Usuário ou senha incorretos.');
        _speak('Usuário ou senha incorretos.');
      }
    } catch (e) {
      _showSnackBar('Erro ao fazer login: $e');
      _speak('Ocorreu um erro ao tentar realizar o login.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6C00),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color(0xFFFF6C00),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(27.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'lib/assets/images/LOGO4.png',
              height: 120.0,
            ),
            const Text(
              'Login',
              style: TextStyle(
                fontSize: 23.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              cursorColor: const Color(0xFFFFFFFF),
              controller: _userController,
              decoration: const InputDecoration(
                labelText: 'Usuário',
                labelStyle: TextStyle(color: Color(0xFFFFFFFF)),
                enabledBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromARGB(255, 255, 255, 255)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFFFFFF)),
                ),
              ),
              style: const TextStyle(color: Color(0xFFFFFFFF)),
              onChanged: (value) {
                _speak('Campo usuário preenchido: $value');
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              cursorColor: const Color(0xFFFFFFFF),
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha',
                labelStyle: TextStyle(color: Color(0xFFFFFFFF)),
                enabledBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromARGB(255, 255, 255, 255)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFFFFFF)),
                ),
              ),
              style: const TextStyle(color: Color(0xFFFFFFFF)),
              onChanged: (value) {
                _speak('Campo senha preenchido.');
              },
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      _speak('Tentando realizar login.');
                      _login();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF6C00),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Entrar'),
                  ),
            TextButton(
              onPressed: () {
                _speak('Navegando para a tela de cadastro.');
                Navigator.pushNamed(context, '/cadastro');
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              child: RichText(
                text: const TextSpan(
                  text: 'Não possui uma conta? ',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16.0,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Crie uma!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
