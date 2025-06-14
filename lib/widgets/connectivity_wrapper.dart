// Arquivo: lib/widgets/connectivity_wrapper.dart

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../screens/no_connection_screen.dart'; // Mantive o nome do seu arquivo

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  const ConnectivityWrapper({super.key, required this.child});

  @override
  _ConnectivityWrapperState createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  // A StreamSubscription volta a ser necessária para ouvir a perda de conexão.
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  // O estado continua representando o resultado da conexão.
  List<ConnectivityResult>? _connectionStatus;

  @override
  void initState() {
    super.initState();
    // Inicia a verificação inicial.
    _checkInitialConnection();
    // Começa a ouvir as mudanças na rede.
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  // Verifica a conexão uma única vez.
  Future<void> _checkInitialConnection() async {
    final result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
  }

  // Esta função agora é chamada automaticamente pelo listener.
  void _updateConnectionStatus(List<ConnectivityResult> result) {
    // Se a conexão for perdida, pausamos o listener para que ele não
    // tente reconectar automaticamente.
    final hasConnection = !result.contains(ConnectivityResult.none);
    if (!hasConnection) {
      if (!_connectivitySubscription.isPaused) {
        _connectivitySubscription.pause();
      }
    }

    // Atualiza a UI com o novo status.
    setState(() {
      _connectionStatus = result;
    });
  }

  // O botão "Tentar Novamente" agora faz uma verificação manual
  // e, se a conexão voltar, reativa o listener.
  Future<void> _retryConnectionCheck() async {
    // Mostra o loading para o usuário.
    if (mounted) {
      setState(() {
        _connectionStatus = null;
      });
    }
    await Future.delayed(const Duration(milliseconds: 500));

    // Faz a verificação manual.
    final result = await Connectivity().checkConnectivity();
    final hasConnectionNow = !result.contains(ConnectivityResult.none);

    // Se a conexão voltou, reativa o listener para o futuro.
    if (hasConnectionNow) {
      if (_connectivitySubscription.isPaused) {
        _connectivitySubscription.resume();
      }
    }

    // Atualiza a UI com o resultado da verificação manual.
    if (mounted) {
      setState(() {
        _connectionStatus = result;
      });
    }
  }

  @override
  void dispose() {
    // Cancela o listener ao sair do widget para evitar vazamentos de memória.
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Se o status é nulo, estamos verificando a conexão.
    if (_connectionStatus == null) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFF6C00),
            ),
          ),
        ),
      );
    }

    // 2. Após a verificação, determinamos se há conexão.
    final hasConnection = !_connectionStatus!.contains(ConnectivityResult.none);

    if (hasConnection) {
      // 3. Se tiver conexão, mostra o aplicativo.
      return widget.child;
    } else {
      // 4. Se não tiver, mostra a tela de erro com o botão que chama a verificação manual.
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: NoConnectionScreen(onRefresh: _retryConnectionCheck),
      );
    }
  }
}
