import 'package:flutter/material.dart';
import 'package:superthai/core/models/models.dart';

class FillBlankController extends ChangeNotifier {
  final ExampleSentence sentence;
  final TextEditingController textController = TextEditingController();

  bool _checked = false;
  bool _isCorrect = false;

  bool get checked => _checked;
  bool get isCorrect => _isCorrect;

  FillBlankController(this.sentence) {
    textController.addListener(_notify);
  }

  void _notify() => notifyListeners();

  void checkAnswer() {
    _checked = true;
    _isCorrect = textController.text.trim() == sentence.gapAnswer;
    notifyListeners();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}
