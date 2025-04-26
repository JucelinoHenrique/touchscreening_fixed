import 'package:flutter/material.dart';
import '../backend//cadastro.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Object login(String user, String password) {
    if (user.isEmpty || password.isEmpty) {
      return 'Preencha todos os campos';
    }

    // ignore: unnecessary_null_comparison
    if (userDb.verifyUser(user, password) != null) {
      _isAuthenticated = true;
      notifyListeners();
      return true; 
    } else {
      return 'Usuário ou senha incorretos'; 
    }
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
      }
}
