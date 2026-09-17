import 'package:flutter/material.dart';
import 'package:superthai/core/models/models.dart';
import 'package:superthai/core/services/data_service.dart';
import 'package:superthai/core/services/progress_service.dart';

enum LessonType {
  flashcard,
  multipleChoice,
  listening,
  speaking,
  completeSentense,
  meaning,
  sentenceOrder,
  vowelFill,
  listeningChoice,
  info,
  conversation,
  sentenceExample,
}

class LessonStep {
  final WordEntry? word;
  final ExampleSentence? sentence;
  final LessonType type;
  final LessonStepData? rawData;
  final int originalIndex;

  LessonStep({
    this.word,
    this.sentence,
    required this.type,
    this.rawData,
    this.originalIndex = 0,
  });
}

class LessonViewModel extends ChangeNotifier {
  final String? lessonId;
  final String category;

  LessonPlan? _currentPlan;
  String? _resolvedId;
  List<LessonStep> _steps = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  int _sessionCorrectCount = 0;
  final List<LessonStep> _failedSteps = [];
  bool _hasAutoMigrated = false;

  List<LessonStep> get steps => _steps;
  int get currentIndex => _currentIndex;
  bool get isCompleted =>
      !_isLoading && _steps.isNotEmpty && _currentIndex >= _steps.length;
  bool get isLoading => _isLoading;
  int get sessionCorrectCount => _sessionCorrectCount;
  List<LessonStep> get failedSteps => _failedSteps;

  LessonPlan? get currentPlan => _currentPlan; // [TEMPORARY] for admin migration

  LessonViewModel({this.lessonId, required this.category}) {
    _generateSteps();
  }

  Future<void> _generateSteps() async {
    LessonPlan? plan;
    if (lessonId != null) {
      final allPlans = await DataService.instance.getAllLessonPlans();
      plan = allPlans.where((p) => p.id == lessonId).firstOrNull;
    }

    plan ??= await DataService.instance.getLessonPlanByCategory(category);

    if (plan != null) {
      _currentPlan = plan;
      _resolvedId = plan.id;
      for (int i = 0; i < plan.steps.length; i++) {
        var stepData = plan.steps[i];
        if (stepData.thai.isNotEmpty ||
            stepData.english.isNotEmpty ||
            stepData.question.isNotEmpty ||
            stepData.answer.isNotEmpty ||
            (stepData.conversation != null && stepData.conversation!.isNotEmpty)) {
          _steps.add(
            LessonStep(
              word: stepData.toWordEntry(),
              type: _mapType(stepData.type),
              sentence: stepData.toExampleSentence(),
              rawData: stepData,
              originalIndex: i,
            ),
          );
        }
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  LessonType _mapType(String type) {
    switch (type) {
      case "Flashcard":
      case "flashcard":
        return LessonType.flashcard;
      case "Four Choice":
      case "multipleChoice":
        return LessonType.multipleChoice;
      case "Listening":
      case "listening":
        return LessonType.listening;
      case "Speaking":
      case "speaking":
        return LessonType.speaking;
      case "Complete Sentense":
      case "completeSentense":
      case "Fill Blank":
      case "fillBlank":
        return LessonType.completeSentense;
      case "Meaning":
      case "meaning":
      case "English Meaning":
      case "englishMeaning":
        return LessonType.meaning;
      case "Sentence Order":
      case "sentenceOrder":
        return LessonType.sentenceOrder;
      case "Vowel Fill":
      case "vowelFill":
        return LessonType.vowelFill;
      case "Listening Choice":
      case "listeningChoice":
        return LessonType.listeningChoice;
      case "Info":
      case "info":
      case "Info Note":
      case "Culture Note":
        return LessonType.info;
      case "Conversation":
      case "conversation":
        return LessonType.conversation;
      case "Sentence Example":
      case "sentenceExample":
        return LessonType.sentenceExample;
      default:
        return LessonType.flashcard;
    }
  }

  void nextStep(bool wasCorrect) {
    if (_currentIndex < _steps.length) {
      final currentStep = _steps[_currentIndex];

      // [TEMPORARY] Auto-Migration logic
      if (!_hasAutoMigrated &&
          _currentPlan != null &&
          (currentStep.rawData?.wasConverted ?? false)) {
        _hasAutoMigrated = true;
        DataService.instance.addLessonPlan(_currentPlan!);
      }

      if (wasCorrect) {
        _sessionCorrectCount++;
        final idToSave = lessonId ?? _resolvedId;
        if (idToSave != null) {
          ProgressService.instance.markStepAsCompleted(
            idToSave,
            currentStep.originalIndex,
          );
        }
      } else {
        _failedSteps.add(currentStep);
      }

      _currentIndex++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  void jumpToStep(int index) {
    if (index >= 0 && index < _steps.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void startReviewMistakes() {
    if (_failedSteps.isEmpty) return;

    _steps = List.from(_failedSteps);
    _failedSteps.clear();
    _currentIndex = 0;
    _sessionCorrectCount = 0;
    notifyListeners();
  }
}
