import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:superthai/core/models/models.dart';
import 'package:superthai/core/services/data_service.dart';
import 'package:superthai/core/services/sound_service.dart';

class ListeningController extends ChangeNotifier {
  final WordEntry word;
  final FlutterTts _tts = DataService.instance.tts;
  final TextEditingController textController = TextEditingController();

  bool _answered = false;
  bool _isCorrect = false;

  bool get answered => _answered;
  bool get isCorrect => _isCorrect;

  ListeningController(this.word) {
    textController.addListener(_notify);
  }

  void init() {
    Future.delayed(const Duration(milliseconds: 500), () {
      speakThaiNormal();
    });
  }

  void _notify() => notifyListeners();

  Future<void> speakThaiNormal() async {
    await _tts.setLanguage("th-TH");
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.5);
    await _tts.speak(word.thai);
  }

  Future<void> speakThaiSlow() async {
    await _tts.setLanguage("th-TH");
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.2);
    await _tts.speak(word.thai);
  }

  void checkAnswer() {
    _answered = true;
    _isCorrect = textController.text.trim().toLowerCase() == word.thai.trim().toLowerCase();

    if (_isCorrect) {
      SoundService.instance.playCorrect();
    } else {
      SoundService.instance.playWrong();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}
