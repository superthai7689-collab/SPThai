import 'package:flutter/material.dart';
import 'package:superthai/core/viewmodels/lesson_view_model.dart';
import 'package:superthai/question_type/pages/listening_page.dart';
import 'package:superthai/question_type/pages/listening_choice_page.dart';
import 'package:superthai/question_type/pages/speaking_page.dart';
import 'package:superthai/question_type/pages/fill_blank_page.dart';
import 'package:superthai/question_type/pages/four_choice_page.dart';
import 'package:superthai/question_type/pages/sentence_order_page.dart';
import 'package:superthai/question_type/pages/vowel_fill_page.dart';
import 'package:superthai/question_type/pages/flashcard_page.dart';
import 'package:superthai/ui/widgets/lesson_completion_widget.dart';
import 'package:superthai/ui/theme/app_theme.dart';

class LessonScreen extends StatefulWidget {
  final String category;
  final String? lessonId;

  const LessonScreen({super.key, required this.category, this.lessonId});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late final LessonViewModel _viewModel;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _viewModel = LessonViewModel(
      category: widget.category,
      lessonId: widget.lessonId,
    );
    _viewModel.addListener(_onViewModelUpdate);
  }

  void _onViewModelUpdate() {
    if (!_viewModel.isLoading &&
        !_isNavigating &&
        !_viewModel.isCompleted &&
        _viewModel.steps.isNotEmpty) {
      _openCurrentStep();
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelUpdate);
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _openCurrentStep() async {
    if (_viewModel.isCompleted || _isNavigating || _viewModel.isLoading) return;

    _isNavigating = true;
    final step = _viewModel.steps[_viewModel.currentIndex];
    final Widget page = _mapStepToPage(step);

    final dynamic result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => page));

    if (!mounted) return;

    _isNavigating = false;

    if (result == null) {
      Navigator.of(context).pop();
      return;
    }

    _viewModel.nextStep(result == true);
  }

  Widget _mapStepToPage(LessonStep step) {
    // Pass current index and total steps to ALL pages
    final int index = _viewModel.currentIndex;
    final int total = _viewModel.steps.length;

    switch (step.type) {
      case LessonType.flashcard:
        return FlashcardPage(
          word: step.word!,
          showAppBar: false,
          currentIndex: index,
          totalSteps: total,
        );
      case LessonType.multipleChoice:
        return FourChoicePage(
          word: step.word!,
          choices: step.rawData?.choices ?? [],
          correctAnswer: step.rawData?.answer,
          category: widget.category,
          showAppBar: false,
          currentIndex: index,
          totalSteps: total,
        );
      case LessonType.listening:
        return ListeningPage(
          word: step.word!,
          showAppBar: false,
          currentIndex: index,
          totalSteps: total,
        );
      case LessonType.listeningChoice:
        return ListeningChoicePage(
          word: step.word!,
          choices: step.rawData?.choices ?? [],
          correctAnswer: step.rawData?.answer,
          showAppBar: false,
          currentIndex: index,
          totalSteps: total,
        );
      case LessonType.speaking:
        return SpeakingPage(
          word: step.word!,
          showAppBar: false,
          currentIndex: index,
          totalSteps: total,
        );
      case LessonType.fillBlank:
        return FillBlankPage(
          sentence: step.sentence!,
          showAppBar: false,
          currentIndex: index,
          totalSteps: total,
        );
      case LessonType.sentenceOrder:
        return SentenceOrderPage(
          word: step.word!,
          choices: step.rawData?.choices ?? [],
          correctAnswer: step.rawData?.answer,
          category: widget.category,
          showAppBar: false,
          currentIndex: index,
          totalSteps: total,
        );
      case LessonType.vowelFill:
        return VowelFillPage(
          word: step.word!,
          question: step.rawData?.question ?? "",
          answer: step.rawData?.answer ?? "",
          choices: step.rawData?.choices ?? [],
          showAppBar: false,
          currentIndex: index,
          totalSteps: total,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          body: _viewModel.isCompleted
              ? _buildCompletionScreen()
              : _buildLoadingScreen(),
        );
      },
    );
  }

  Widget _buildCompletionScreen() {
    return LessonCompletionWidget(
      viewModel: _viewModel,
      category: widget.category,
    );
  }

  Widget _buildLoadingScreen() {
    if (!_viewModel.isLoading && _viewModel.steps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              "No content found for this lesson.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Go Back"),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppTheme.primaryColor),
          const SizedBox(height: 30),
          const Text(
            "Get Ready...",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _viewModel.isLoading
                ? "Loading content..."
                : "Question ${_viewModel.currentIndex + 1} / ${_viewModel.steps.length}",
            style: const TextStyle(
              fontSize: 18,
              color: AppTheme.lightTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
