import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:superthai/core/models/models.dart';

import 'package:superthai/core/services/data_service.dart';

class SpeakingController extends ChangeNotifier {
  final WordEntry word;
  final FlutterTts _tts = DataService.instance.tts;
  final SpeechToText _stt = DataService.instance.stt;

  bool _isSpeechAvailable = false;
  bool _isListening = false;
  String _recognizedText = "";
  bool? _answerCorrect;
  bool _answered = false;

  bool get isListening => _isListening;
  String get recognizedText => _recognizedText;
  bool? get answerCorrect => _answerCorrect;
  bool get answered => _answered;
  bool get isSpeechAvailable => _isSpeechAvailable;

  SpeakingController(this.word) {
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _isSpeechAvailable = await _stt.initialize();
    notifyListeners();
  }

  Future<void> speakThaiNormal() async {
    await _tts.setLanguage("th-TH");
    await _tts.setSpeechRate(0.5);
    await _tts.speak(word.thai);
  }

  Future<void> speakThaiSlow() async {
    await _tts.setLanguage("th-TH");
    await _tts.setSpeechRate(0.2);
    await _tts.speak(word.thai);
  }

  void startListening() async {
    if (!_isSpeechAvailable) return;

    _isListening = true;
    _recognizedText = "";
    _answered = false;
    _answerCorrect = null;
    notifyListeners();

    await _stt.listen(
      onResult: (result) {
        _recognizedText = result.recognizedWords;
        if (result.finalResult) {
          _isListening = false;
          _checkAnswer();
        }
        notifyListeners();
      },
      listenOptions: SpeechListenOptions(localeId: "th-TH"),
    );
  }

  void stopListening() async {
    await _stt.stop();
    _isListening = false;
    _checkAnswer();
    notifyListeners();
  }

  void _checkAnswer() {
    if (_recognizedText.isEmpty) return;

    String target = word.thai
        .replaceAll(RegExp(r'[^\u0E00-\u0E7F]'), '')
        .trim();
    String recognized = _recognizedText
        .replaceAll(RegExp(r'[^\u0E00-\u0E7F]'), '')
        .trim();

    _answered = true;
    _answerCorrect =
        recognized == target ||
        recognized.contains(target) ||
        target.contains(recognized);
  }
}
