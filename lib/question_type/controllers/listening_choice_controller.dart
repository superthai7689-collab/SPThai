import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:superthai/core/models/models.dart';
import 'package:superthai/core/services/data_service.dart';
import 'package:superthai/core/services/sound_service.dart';

class ListeningChoiceController extends ChangeNotifier {
  final WordEntry word;
  final List<String> initialChoices;
  final String? correctAnswer;
  final FlutterTts _tts = DataService.instance.tts;

  List<String> _choices = [];
  String? _selectedAnswer;
  bool _answered = false;
  bool _isLoading = true;

  List<String> get choices => _choices;
  String? get selectedAnswer => _selectedAnswer;
  bool get answered => _answered;
  bool get isLoading => _isLoading;

  ListeningChoiceController({
    required this.word,
    required this.initialChoices,
    this.correctAnswer,
  });

  void init() {
    _setupChoices();
    Future.delayed(const Duration(milliseconds: 500), () {
      speakThaiNormal();
    });
  }

  void _setupChoices() {
    _isLoading = true;
    notifyListeners();

    _choices = List.from(initialChoices);
    
    final targetAnswer = correctAnswer ?? word.thai;
    if (!_choices.contains(targetAnswer)) {
      if (_choices.length < 4) {
        _choices.add(targetAnswer);
      } else {
        _choices[0] = targetAnswer;
      }
    }
    
    _choices.shuffle();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> speakThaiNormal() async {
    await _tts.setLanguage("th-TH");
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.4);
    await _tts.speak(word.thai);
  }

  Future<void> speakThaiSlow() async {
    await _tts.setLanguage("th-TH");
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.2);
    await _tts.speak(word.thai);
  }

  void selectChoice(String choice) {
    if (_answered) return;
    _selectedAnswer = choice;
    _answered = true;

    if (answerCorrect) {
      SoundService.instance.playCorrect();
      _tts.speak(word.thai);
    } else {
      SoundService.instance.playWrong();
    }

    notifyListeners();
  }

  bool isCorrect(String choice) {
    final target = (correctAnswer ?? word.thai).trim().toLowerCase();
    return choice.trim().toLowerCase() == target;
  }

  bool get answerCorrect {
    if (_selectedAnswer == null) return false;
    return isCorrect(_selectedAnswer!);
  }

  void updateData({
    required WordEntry newWord,
    required List<String> newChoices,
    String? newAnswer,
  }) {
  }
}
