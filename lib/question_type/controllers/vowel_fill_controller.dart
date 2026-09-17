import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:superthai/core/models/models.dart';
import 'package:superthai/core/services/sound_service.dart';

class VowelFillController extends ChangeNotifier {
  WordEntry word;
  final FlutterTts _tts = FlutterTts();

  String? _selectedAnswer;
  bool _answered = false;
  bool _isCorrect = false;

  String? get selectedAnswer => _selectedAnswer;
  bool get answered => _answered;
  bool get isCorrect => _isCorrect;

  VowelFillController(this.word);

  void init() {
    Future.delayed(const Duration(milliseconds: 500), () {
      speakThaiNormal();
    });
  }

  void updateWord(WordEntry newWord) {
    word = newWord;
  }

  Future<void> speakThaiNormal() async {
    if (word.thai.isEmpty) return;
    await _tts.setLanguage("th-TH");
    await _tts.setSpeechRate(0.5);
    await _tts.speak(word.thai);
  }

  Future<void> speakThaiSlow() async {
    if (word.thai.isEmpty) return;
    await _tts.setLanguage("th-TH");
    await _tts.setSpeechRate(0.2);
    await _tts.speak(word.thai);
  }

  void selectChoice(String choice, String correctAnswer) {
    if (_answered) return;
    _selectedAnswer = choice;
    _answered = true;
    _isCorrect = choice.trim().toLowerCase() == correctAnswer.trim().toLowerCase();

    if (_isCorrect) {
      SoundService.instance.playCorrect();
    } else {
      SoundService.instance.playWrong();
    }

    notifyListeners();
  }

  void reset() {
    _selectedAnswer = null;
    _answered = false;
    _isCorrect = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
