import 'package:flutter/material.dart';
import 'package:superthai/core/models/models.dart';
import 'package:superthai/ui/theme/app_theme.dart';
import 'package:superthai/ui/widgets/shared_widgets.dart';
import 'package:superthai/question_type/controllers/vowel_fill_controller.dart';

class VowelFillPage extends StatefulWidget {
  final WordEntry word;
  final String question; // E.g., "...ก..."
  final String answer; // E.g., "แ-ะ"
  final List<String> choices;
  final bool showAppBar;
  final bool isEditing;
  final Function(String field, dynamic value)? onEdit;
  final int currentIndex;
  final int totalSteps;

  const VowelFillPage({
    super.key,
    required this.word,
    required this.question,
    required this.answer,
    required this.choices,
    this.showAppBar = true,
    this.isEditing = false,
    this.onEdit,
    this.currentIndex = 0,
    this.totalSteps = 1,
  });

  @override
  State<VowelFillPage> createState() => _VowelFillPageState();
}

class _VowelFillPageState extends State<VowelFillPage> {
  late final VowelFillController _controller;
  late final TextEditingController _questionController;
  late final TextEditingController _answerController;
  late final TextEditingController _thaiController;
  final List<TextEditingController> _choiceControllers = [];

  @override
  void initState() {
    super.initState();
    _controller = VowelFillController(widget.word);
    _questionController = TextEditingController(text: widget.question);
    _answerController = TextEditingController(text: widget.answer);
    _thaiController = TextEditingController(text: widget.word.thai);

    for (int i = 0; i < 4; i++) {
      _choiceControllers.add(
        TextEditingController(
          text: widget.choices.length > i ? widget.choices[i] : "",
        ),
      );
    }

    if (!widget.isEditing) {
      _controller.init();
    }
  }

  void _syncTextFields() {
    if (_questionController.text != widget.question) {
      _questionController.text = widget.question;
    }
    if (_answerController.text != widget.answer) {
      _answerController.text = widget.answer;
    }
    if (_thaiController.text != widget.word.thai) {
      _thaiController.text = widget.word.thai;
    }

    for (int i = 0; i < 4; i++) {
      String text = widget.choices.length > i ? widget.choices[i] : "";
      if (_choiceControllers[i].text != text) _choiceControllers[i].text = text;
    }
  }

  @override
  void didUpdateWidget(VowelFillPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.updateWord(widget.word);
    _syncTextFields();
  }

  @override
  void dispose() {
    _controller.dispose();
    _questionController.dispose();
    _answerController.dispose();
    _thaiController.dispose();
    for (var c in _choiceControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing) return _buildEditMode();

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final progress =
            (widget.currentIndex + 1) /
            (widget.totalSteps > 0 ? widget.totalSteps : 1);

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
                ThaiCard(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Text(
                        "FILL THE VOWEL",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        widget.question,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSpeakIconButton(
                            Icons.volume_up_rounded,
                            "NORMAL",
                            AppTheme.primaryColor,
                            _controller.speakThaiNormal,
                          ),
                          const SizedBox(width: 40),
                          _buildSpeakIconButton(
                            Icons.slow_motion_video_rounded,
                            "SLOW",
                            Colors.pink.shade300,
                            _controller.speakThaiSlow,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 2.5,
                  children: widget.choices
                      .map((choice) => _buildChoiceButton(choice))
                      .toList(),
                ),
                const SizedBox(height: 32),
                if (_controller.answered) _buildFeedbackArea(),
              ],
            ),
          ),
        );

        if (!widget.showAppBar) body = SafeArea(child: body);

        return Scaffold(
          appBar: widget.showAppBar ? const ThaiAppBar(title: "Quiz") : null,
          body: body,
        );
      },
    );
  }

  Widget _buildSpeakIconButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceButton(String choice) {
    if (choice.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isSelected = _controller.selectedAnswer == choice;
    final isCorrect = choice == widget.answer;

    Color background = theme.cardColor;
    Color borderColor = theme.dividerColor.withValues(alpha: 0.2);
    Color textColor = theme.textTheme.bodyLarge?.color ?? AppTheme.textColor;

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

    return GestureDetector(
      onTap: _controller.answered
          ? null
          : () => _controller.selectChoice(choice, widget.answer),
      child: Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Center(
          child: Text(
            choice,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
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
                          : Icons.cancel_rounded,
                      color: correct
                          ? (theme.brightness == Brightness.light
                                ? Colors.green.shade700
                                : Colors.green.shade400)
                          : (theme.brightness == Brightness.light
                                ? Colors.red.shade700
                                : Colors.red.shade400),
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      correct ? "EXCELLENT!" : "NOT QUITE...",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: correct
                            ? (theme.brightness == Brightness.light
                                  ? Colors.green.shade800
                                  : Colors.green.shade200)
                            : (theme.brightness == Brightness.light
                                  ? Colors.red.shade800
                                  : Colors.red.shade200),
                      ),
                    ),
                  ],
                ),
                if (!correct)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      "Correct Vowel: ${widget.answer}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                ThaiButton(
                  text: "CONTINUE",
                  color: correct ? Colors.green : Colors.red,
                  onPressed: () =>
                      Navigator.pop(context, _controller.isCorrect),
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
    int correctIndex = -1;
    for (int i = 0; i < widget.choices.length; i++) {
      if (widget.choices[i] == widget.answer && widget.answer.isNotEmpty) {
        correctIndex = i;
        break;
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: widget.showAppBar
          ? const ThaiAppBar(title: "⚙️ Vowel Fill Settings")
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
                          Icons.spellcheck_rounded,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Vowel Configuration",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Create a word with a missing vowel for users to fill.",
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
                    "FULL WORD (FOR AUDIO)",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.disabledColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildEditableField(
                    controller: _thaiController,
                    field: 'thai',
                    label: 'Full Thai word (e.g., แกะ)',
                    icon: Icons.record_voice_over_rounded,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "QUESTION CONTENT",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildEditableField(
                    controller: _questionController,
                    field: 'question',
                    label: 'Word with gap (e.g., ...ก...)',
                    icon: Icons.text_fields_rounded,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "ANSWER CHOICES",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Tap the switch to mark a vowel as correct.",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(
                    4,
                    (index) => _buildEditableChoice(index, correctIndex),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableChoice(int index, int correctIndex) {
    final theme = Theme.of(context);
    bool isCorrect = correctIndex == index;
    String choiceText = _choiceControllers[index].text;

    return Container(
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
                        widget.onEdit?.call('answer', choiceText);
                      }
                    },
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
