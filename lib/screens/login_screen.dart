import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:touchscreening_fixed/screens/cadastro_screen.dart';
import '../backend/auth_service.dart';
// ADICIONE ESTE IMPORT para a WelcomeScreen
import './welcome_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FlutterTts _tts = FlutterTts();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speak(
          'Bem-vindo à tela de login. Por favor, insira seu e-mail e senha.');
    });
  }

  Future<void> _speak(String text) async {
    await _tts.setLanguage('pt-BR');
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
    await _tts.speak(text);
  }

  Future<void> _login() async {
    final String email = _userController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Por favor, preencha todos os campos.');
      _speak('Por favor, preencha todos os campos.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential =
          await _authService.signInWithEmailAndPassword(email, password);

      if (userCredential != null) {
        _speak('Login realizado com sucesso.');
        if (mounted) {
          // CORREÇÃO AQUI: Trocado pushReplacementNamed por pushReplacement
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          );
        }
      } else {
        _showSnackBar('Usuário ou senha incorretos.');
        _speak('Usuário ou senha incorretos.');
      }
    } catch (e) {
      _showSnackBar('Erro ao fazer login: $e');
      _speak('Ocorreu um erro ao tentar realizar o login.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential != null) {
        _speak('Login com Google realizado com sucesso.');
        if (mounted) {
          // CORREÇÃO AQUI: Trocado pushReplacementNamed por pushReplacement
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          );
        }
      }
    } catch (e) {
      _showSnackBar('Erro ao fazer login com Google: $e');
      _speak('Ocorreu um erro ao tentar realizar o login com o Google.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
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
              cursorColor: Colors.white,
              controller: _userController,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                // _speak('Campo e-mail preenchido: $value'); // Comentado para não falar a cada letra
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              cursorColor: Colors.white,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                // _speak('Campo senha preenchido.'); // Comentado para não falar a cada letra
              },
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : Column(
                    children: [
                      ElevatedButton(
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
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Entrar'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          _speak('Tentando realizar login com o Google.');
                          _loginWithGoogle();
                        },
                        icon: const Icon(Icons
                            .login), // Ícone genérico, pode ser trocado por um do Google
                        label: const Text('Login com Google'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: const Color(0xFFFF6C00),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          textStyle: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                _speak('Navegando para a tela de cadastro.');
                // Usando a navegação direta aqui também por consistência
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const CadastroScreen()),
                );
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
