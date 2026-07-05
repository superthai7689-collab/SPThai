import 'package:flutter/material.dart';
import 'package:superthai/core/models/models.dart';
import 'package:superthai/ui/theme/app_theme.dart';
import 'package:superthai/ui/widgets/shared_widgets.dart';
import 'package:superthai/question_type/controllers/fill_blank_controller.dart';

class FillBlankPage extends StatefulWidget {
  final ExampleSentence sentence;
  final bool showAppBar;
  final bool isEditing;
  final Function(String field, String value)? onEdit;
  final int currentIndex;
  final int totalSteps;

  const FillBlankPage({
    super.key,
    required this.sentence,
    this.showAppBar = true,
    this.isEditing = false,
    this.onEdit,
    this.currentIndex = 0,
    this.totalSteps = 1,
  });

  @override
  State<FillBlankPage> createState() => _FillBlankPageState();
}

class _FillBlankPageState extends State<FillBlankPage> {
  late final FillBlankController _controller;

  // Controllers for editing mode
  late TextEditingController _questionController;
  late TextEditingController _answerController;

  @override
  void initState() {
    super.initState();
    _controller = FillBlankController(widget.sentence);
    _questionController = TextEditingController(text: widget.sentence.sentence);
    _answerController = TextEditingController(text: widget.sentence.gapAnswer);
  }

  @override
  void didUpdateWidget(FillBlankPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEditing) {
      if (widget.sentence.sentence != _questionController.text) {
        _questionController.text = widget.sentence.sentence;
      }
      if (widget.sentence.gapAnswer != _answerController.text) {
        _answerController.text = widget.sentence.gapAnswer;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing) {
      return _buildEditMode();
    }

    final progress =
        (widget.currentIndex + 1) /
        (widget.totalSteps > 0 ? widget.totalSteps : 1);

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final theme = Theme.of(context);
        Widget body = SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "COMPLETE THE SENTENCE",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        widget.sentence.sentence,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).textTheme.titleLarge?.color ??
                              AppTheme.textColor,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: TextField(
                    controller: _controller.textController,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    decoration: InputDecoration(
                      hintText: "Tap to type...",
                      hintStyle: TextStyle(
                        color: theme.disabledColor,
                        fontWeight: FontWeight.normal,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                if (!_controller.checked)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _controller.textController.text.isEmpty
                            ? Colors.grey.shade300
                            : AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 0,
                      ),
                      onPressed: _controller.textController.text.isEmpty
                          ? null
                          : _controller.checkAnswer,
                      child: const Text(
                        "CHECK ANSWER",
                        style: TextStyle(letterSpacing: 1.2),
                      ),
                    ),
                  )
                else
                  _buildFeedbackArea(),
              ],
            ),
          ),
        );

        if (!widget.showAppBar) {
          body = SafeArea(child: body);
        }

        return Scaffold(
          appBar: widget.showAppBar
              ? const ThaiAppBar(title: "Fill the Blank")
              : null,
          body: body,
        );
      },
    );
  }

  Widget _buildFeedbackArea() {
    final theme = Theme.of(context);
    final correct = _controller.isCorrect;
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
                  ? (theme.brightness == Brightness.light
                        ? Colors.green.shade50
                        : Colors.green.withValues(alpha: 0.1))
                  : (theme.brightness == Brightness.light
                        ? Colors.red.shade50
                        : Colors.red.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: correct
                    ? (theme.brightness == Brightness.light
                          ? Colors.green.shade300
                          : Colors.green.withValues(alpha: 0.5))
                    : (theme.brightness == Brightness.light
                          ? Colors.red.shade300
                          : Colors.red.withValues(alpha: 0.5)),
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
                          : Icons.error_outline_rounded,
                      color: correct
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      correct ? "CORRECT!" : "INCORRECT",
                      style: TextStyle(
                        fontSize: 24,
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
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Column(
                      children: [
                        Text(
                          "The correct word was:",
                          style: TextStyle(
                            color: theme.brightness == Brightness.light
                                ? Colors.red
                                : Colors.red.shade300,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.sentence.gapAnswer,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: theme.brightness == Brightness.light
                                ? Colors.red.shade900
                                : Colors.red.shade200,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: correct ? Colors.green : Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () =>
                        Navigator.of(context).pop(_controller.isCorrect),
                    child: const Text(
                      "CONTINUE",
                      style: TextStyle(letterSpacing: 1.2),
                    ),
                  ),
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
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: widget.showAppBar
          ? const ThaiAppBar(title: "⚙️ Fill Blank Settings")
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
                          Icons.edit_note_rounded,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Sentence Configuration",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Create a sentence with a missing word for users to fill.",
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
                    "SENTENCE WITH GAP",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.disabledColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildEditableField(
                    controller: _questionController,
                    field: 'question',
                    label: 'Sentence (use .... for gap)',
                    icon: Icons.short_text_rounded,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "CORRECT ANSWER",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.disabledColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildEditableField(
                    controller: _answerController,
                    field: 'answer',
                    label: 'The missing word',
                    icon: Icons.check_circle_outline_rounded,
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline_rounded,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Pro-tip: Make sure the sentence has exactly '....' where you want the blank to appear.",
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField({
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
                  TextField(
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
