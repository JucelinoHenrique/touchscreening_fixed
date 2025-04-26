import 'package:flutter/material.dart';
import '../backend/cadastro.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CadastroScreenState createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController = TextEditingController();

  Future<void> _submitData() async {
    final String name = _nameController.text;
    final String user = _userController.text;
    final String password = _passwordController.text;
    final String confirmpassword = _confirmpasswordController.text; 

    if (password != confirmpassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não correspondem!')),
      );
      return;
    }

    final bool success = await userDb.addUser(User(name, password, user));

    if (!success) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário já existe!')),
      );
      return;
    }

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cadastro realizado com sucesso!')),
    );

    _nameController.clear();
    _userController.clear();
    _passwordController.clear();
    _confirmpasswordController.clear();
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
              'Cadastre-se',
              style: TextStyle(
                fontSize: 23.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextField(
              cursorColor: const Color(0xFFFFFFFF),
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: 'Nome',
                  labelStyle: TextStyle(color: Color(0xFFFFFFFF)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255))),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFFFFFF)))),
              style: const TextStyle(color: Color(0xFFFFFFFF)),
            ),
            TextField(
              cursorColor: const Color(0xFFFFFFFF),
              controller: _userController,
              decoration: const InputDecoration(
                  labelText: 'Usuário',
                  labelStyle: TextStyle(color: Color(0xFFFFFFFF)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255))),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFFFFFF)))),
              style: const TextStyle(color: Color(0xFFFFFFFF)),
            ),
            TextField(
              cursorColor: const Color(0xFFFFFFFF),
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'Senha',
                  labelStyle: TextStyle(color: Color(0xFFFFFFFF)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255))),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFFFFFF)))),
              style: const TextStyle(color: Color(0xFFFFFFFF)),
            ),
            TextField(
              cursorColor: const Color(0xFFFFFFFF),
              controller: _confirmpasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'Confirme sua senha',
                  labelStyle: TextStyle(color: Color(0xFFFFFFFF)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255))),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFFFFFF)))),
              style: const TextStyle(color: Color(0xFFFFFFFF)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitData,
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xFFFF6C00),
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}
