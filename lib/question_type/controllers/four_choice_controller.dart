import 'dart:math';
import 'package:flutter/material.dart';
import 'package:superthai/core/models/models.dart';
import 'package:superthai/core/services/data_service.dart';

class FourChoiceController extends ChangeNotifier {
  WordEntry word;
  final String category;
  List<String>? initialChoices;
  String? correctAnswer;
  int? correctIndex; // Explicitly track which slot is correct

  List<WordEntry> choices = [];
  bool _answered = false;
  bool _answerCorrect = false;
  String? _selectedAnswer;
  bool _isLoading = true;

  bool get answered => _answered;
  bool get answerCorrect => _answerCorrect;
  String? get selectedAnswer => _selectedAnswer;
  bool get isLoading => _isLoading;

  FourChoiceController({
    required this.word,
    required this.category,
    this.initialChoices,
    this.correctAnswer,
  }) {
    _syncCorrectIndex();
    _generateChoices();
  }

  void _syncCorrectIndex() {
    if (initialChoices != null && correctAnswer != null) {
      final answerIndex = initialChoices!.indexOf(correctAnswer!);
      if (answerIndex != -1) {
        correctIndex = answerIndex;
      }
    }
  }

  void updateData({
    required WordEntry newWord,
    required List<String>? newChoices,
    String? newAnswer,
  }) {
    word = newWord;
    initialChoices = newChoices;
    correctAnswer = newAnswer;
    _syncCorrectIndex();
    _generateChoices();
  }

  void setCorrectIndex(int index, String text) {
    correctIndex = index;
    correctAnswer = text;
    notifyListeners();
  }

  Future<void> _generateChoices() async {
    if (initialChoices != null) {
      List<String> paddedChoices = List.from(initialChoices!);
      while (paddedChoices.length < 4) {
        paddedChoices.add("");
      }

      choices = paddedChoices.asMap().entries.map((entry) {
        final choiceIndex = entry.key;
        final choiceText = entry.value;
        return WordEntry(
          id: 'edit_choice_$choiceIndex',
          thai: choiceText,
          phonetic: '',
          english: choiceText,
          category: 'temp',
        );
      }).toList();

      _isLoading = false;
      notifyListeners();
      return;
    }

    final random = Random();
    final allWords = await DataService.instance.getWordsByCategory(category);
    final pool = List<WordEntry>.from(allWords);

    pool.removeWhere((candidateWord) => candidateWord.thai == word.thai);

    pool.shuffle();
    choices = [word, ...pool.take(3)];
    choices.shuffle(random);
    _isLoading = false;
    notifyListeners();
  }

  bool isCorrect(WordEntry choice) {
    if (correctIndex != null && initialChoices != null) {
      final choiceIndex = choices.indexOf(choice);
      return choiceIndex == correctIndex;
    }

    // Fallback for Quiz mode
    return choice.thai == word.thai || choice.english == word.english;
  }

  void selectChoice(WordEntry choice) {
    if (_answered) return;
    _answered = true;
    _answerCorrect = isCorrect(choice);
    _selectedAnswer = choice.english;
    notifyListeners();
  }
}
