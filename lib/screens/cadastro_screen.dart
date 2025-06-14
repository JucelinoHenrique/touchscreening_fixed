import 'package:flutter/material.dart';
import '../backend/auth_service.dart';
import '../backend/user_database.dart'; // Para salvar nome no Firestore

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  CadastroScreenState createState() => CadastroScreenState();
}

class CadastroScreenState extends State<CadastroScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();

  final AuthService _authService = AuthService();
  final UserDatabase _userDatabase = UserDatabase();

  bool _isLoading = false;

  Future<void> _submitData() async {
    // Validações básicas
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showSnackBar('Por favor, preencha todos os campos obrigatórios.');
      return;
    }
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmpasswordController.text.trim();

    if (password != confirmPassword) {
      _showSnackBar('As senhas não correspondem!');
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final userCredential =
          await _authService.registerWithEmailAndPassword(email, password);

      if (userCredential != null && userCredential.user != null) {
        // Atualiza o nome de exibição no Firebase Auth
        await userCredential.user!.updateDisplayName(name);
        // Salva os dados do usuário no Firestore
        await _userDatabase.saveUserData(userCredential.user!.uid, name);

        if (mounted) {
          _showSnackBar('Cadastro realizado com sucesso!');
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erro ao cadastrar: ${e.toString()}');
      }
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Cadastro', style: TextStyle(color: Colors.white)),
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
            const SizedBox(height: 20),
            _buildTextField(_nameController, 'Nome Completo'),
            _buildTextField(_emailController, 'E-mail'),
            _buildPasswordField(_passwordController, 'Senha'),
            _buildPasswordField(
                _confirmpasswordController, 'Confirme sua senha'),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : ElevatedButton(
                    onPressed: _submitData,
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
                    child: const Text('Cadastrar'),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        cursorColor: Colors.white,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        cursorColor: Colors.white,
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
