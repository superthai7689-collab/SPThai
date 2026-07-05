import 'package:flutter/material.dart';
import 'package:superthai/core/models/models.dart';
import 'package:superthai/ui/theme/app_theme.dart';
import 'package:superthai/ui/widgets/shared_widgets.dart';
import 'package:superthai/question_type/controllers/four_choice_controller.dart';

class FourChoicePage extends StatefulWidget {
  final WordEntry word;
  final List<String> choices;
  final String? correctAnswer;
  final String category;
  final bool showAppBar;
  final bool isEditing;
  final Function(String field, dynamic value)? onEdit;
  final int currentIndex;
  final int totalSteps;

  const FourChoicePage({
    super.key,
    required this.word,
    required this.choices,
    this.correctAnswer,
    required this.category,
    this.showAppBar = true,
    this.isEditing = false,
    this.onEdit,
    this.currentIndex = 0,
    this.totalSteps = 1,
  });

  @override
  State<FourChoicePage> createState() => _FourChoicePageState();
}

class _FourChoicePageState extends State<FourChoicePage> {
  late final FourChoiceController _controller;
  final List<TextEditingController> _choiceControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  late final TextEditingController _questionController;

  @override
  void initState() {
    super.initState();
    _controller = FourChoiceController(
      word: widget.word,
      category: widget.category,
      initialChoices: widget.choices,
      correctAnswer: widget.correctAnswer,
    );

    _questionController = TextEditingController(text: widget.word.thai);
    _syncTextFields();
  }

  void _syncTextFields() {
    if (_questionController.text != widget.word.thai) {
      _questionController.text = widget.word.thai;
    }
    for (int i = 0; i < 4; i++) {
      String text = widget.choices.length > i ? widget.choices[i] : "";
      if (_choiceControllers[i].text != text) {
        _choiceControllers[i].text = text;
      }
    }
  }

  @override
  void didUpdateWidget(FourChoicePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.updateData(
      newWord: widget.word,
      newChoices: widget.choices,
      newAnswer: widget.correctAnswer,
    );
    _syncTextFields();
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var c in _choiceControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing) {
      return _buildEditMode();
    }
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final questionText = widget.word.thai;
        final progress =
            (widget.currentIndex + 1) /
            (widget.totalSteps > 0 ? widget.totalSteps : 1);

        Widget body = _controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        minHeight: 8,
                      ),
                      const SizedBox(height: 32),
                      ThaiCard(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            const Text(
                              "CHOOSE THE CORRECT ANSWER",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              questionText.isNotEmpty ? questionText : "...",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      ..._controller.choices.map(
                        (choice) => _buildChoiceButton(choice),
                      ),
                      const SizedBox(height: 20),
                      if (_controller.answered) _buildFeedbackArea(),
                    ],
                  ),
                ),
              );

        if (!widget.showAppBar) {
          body = SafeArea(child: body);
        }

        return Scaffold(
          appBar: widget.showAppBar ? const ThaiAppBar(title: "Quiz") : null,
          body: body,
        );
      },
    );
  }

  Widget _buildChoiceButton(WordEntry choice) {
    final theme = Theme.of(context);
    final answerText = choice.english;
    final isSelected = _controller.selectedAnswer == answerText;
    final isCorrect = _controller.isCorrect(choice);

    Color background = theme.cardColor;
    Color textColor = theme.textTheme.bodyLarge?.color ?? AppTheme.textColor;
    Color borderColor = theme.dividerColor.withValues(alpha: 0.2);

    if (_controller.answered) {
      if (isCorrect) {
        background = Colors.green.withValues(alpha: 0.1);
        borderColor = Colors.green.withValues(alpha: 0.5);
        textColor = Colors.green;
      } else if (isSelected) {
        background = Colors.red.withValues(alpha: 0.1);
        borderColor = Colors.red.withValues(alpha: 0.5);
        textColor = Colors.red;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 65,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _controller.answered
                ? null
                : () => _controller.selectChoice(choice),
            borderRadius: BorderRadius.circular(18),
            child: Center(
              child: Text(
                answerText,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackArea() {
    final correct = _controller.answerCorrect;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: correct
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: correct ? Colors.green : Colors.red,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      correct
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color: correct ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      correct ? "Excellent!" : "Not quite...",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: correct
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                      ),
                    ),
                  ],
                ),
                if (!correct)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      "Correct Answer: ${_controller.correctAnswer ?? widget.word.english}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                ThaiButton(
                  text: "Continue",
                  onPressed: () =>
                      Navigator.pop(context, _controller.answerCorrect),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditMode() {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: widget.showAppBar
              ? const ThaiAppBar(title: "⚙️ Question Settings")
              : null,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  color: theme.cardColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.teal.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.quiz_rounded,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Quiz Configuration",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Customize how this question appears to users",
                        style: TextStyle(color: theme.disabledColor),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "QUESTION CONTENT",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.disabledColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildEditableCard(
                        controller: _questionController,
                        field: 'thai',
                        label: 'Question Content (Thai)',
                        icon: Icons.text_fields_rounded,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        "ANSWER CHOICES",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.disabledColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tap the switch to mark a choice as correct.",
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.disabledColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(
                        4,
                        (index) => _buildEditableChoice(index),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditableChoice(int index) {
    final theme = Theme.of(context);
    String choiceText = _choiceControllers[index].text;
    bool isCorrect = _controller.correctIndex == index;

    return Container(
      key: ValueKey('choice_container_$index'),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect ? Colors.green.shade200 : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.light ? 0.05 : 0.2,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: isCorrect
                  ? Colors.green
                  : theme.dividerColor.withValues(alpha: 0.1),
              child: Text(
                "${index + 1}",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.white : theme.disabledColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                key: ValueKey('choice_input_$index'),
                controller: _choiceControllers[index],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color,
                ),
                decoration: InputDecoration(
                  hintText: "Tap to type...",
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: theme.disabledColor,
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: theme.brightness == Brightness.light
                      ? Colors.grey.shade100
                      : Colors.white.withValues(alpha: 0.1),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.green.shade300,
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (val) {
                  if (isCorrect) {
                    widget.onEdit?.call('answer', val);
                  }
                  widget.onEdit?.call('choice_$index', val);
                },
              ),
            ),
            Switch(
              value: isCorrect,
              activeThumbColor: Colors.green,
              onChanged: choiceText.isEmpty
                  ? null
                  : (val) {
                      if (val) {
                        _controller.setCorrectIndex(index, choiceText);
                        widget.onEdit?.call('answer', choiceText);
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableCard({
    required TextEditingController controller,
    required String field,
    required String label,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.light ? 0.05 : 0.2,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.teal, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.disabledColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextFormField(
                    controller: controller,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "Tap to type...",
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: theme.disabledColor,
                        fontSize: 16,
                      ),
                      filled: true,
                      fillColor: theme.brightness == Brightness.light
                          ? Colors.grey.shade100
                          : Colors.white.withValues(alpha: 0.1),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.teal.shade300,
                          width: 1.5,
                        ),
                      ),
                    ),
                    onChanged: (val) => widget.onEdit?.call(field, val),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
