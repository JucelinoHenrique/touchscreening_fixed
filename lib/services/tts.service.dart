import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;

  TTSService._internal();

  final FlutterTts _tts = FlutterTts();

  Future<void> speak(String text) async {
    await _tts.setLanguage('pt-BR'); // Define o idioma para Português
    await _tts.setPitch(1.0); // Define o tom da voz
    await _tts.setSpeechRate(0.5); // Define a velocidade da fala
    await _tts.speak(text); // Fala o texto
  }

  Future<void> stop() async {
    await _tts.stop(); // Para qualquer fala em andamento
  }
}
