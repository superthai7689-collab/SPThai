import 'package:flutter/material.dart';
import 'package:superthai/core/models/models.dart';
import 'package:superthai/ui/theme/app_theme.dart';
import 'package:superthai/ui/widgets/shared_widgets.dart';
import 'package:superthai/question_type/controllers/listening_choice_controller.dart';

class ListeningChoicePage extends StatefulWidget {
  final WordEntry word;
  final List<String> choices;
  final String? correctAnswer;
  final bool showAppBar;
  final bool isEditing;
  final Function(String field, dynamic value)? onEdit;
  final int currentIndex;
  final int totalSteps;

  const ListeningChoicePage({
    super.key,
    required this.word,
    required this.choices,
    this.correctAnswer,
    this.showAppBar = true,
    this.isEditing = false,
    this.onEdit,
    this.currentIndex = 0,
    this.totalSteps = 1,
  });

  @override
  State<ListeningChoicePage> createState() => _ListeningChoicePageState();
}

class _ListeningChoicePageState extends State<ListeningChoicePage> {
  late final ListeningChoiceController _controller;
  
  // Controllers for edit mode
  final List<TextEditingController> _choiceControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  late final TextEditingController _thaiController;
  int _correctIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = ListeningChoiceController(
      word: widget.word,
      initialChoices: widget.choices,
      correctAnswer: widget.correctAnswer,
    );
    
    if (!widget.isEditing) {
      _controller.init();
    }

    _thaiController = TextEditingController(text: widget.word.thai);
    _syncEditControllers();
  }

  void _syncEditControllers() {
    _thaiController.text = widget.word.thai;
    int foundIndex = -1;

    for (int i = 0; i < 4; i++) {
      String choice = widget.choices.length > i ? widget.choices[i] : "";
      _choiceControllers[i].text = choice;

      // ตรวจสอบเฉพาะเมื่อมีข้อความเท่านั้น เพื่อป้องกันการจับคู่ค่าว่าง
      if (choice.isNotEmpty) {
        if (widget.correctAnswer != null && choice == widget.correctAnswer) {
          foundIndex = i;
        } else if (widget.correctAnswer == null &&
            widget.word.thai.isNotEmpty &&
            choice == widget.word.thai) {
          foundIndex = i;
        }
      }
    }
    setState(() {
      _correctIndex = foundIndex;
    });
  }

  @override
  void didUpdateWidget(ListeningChoicePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEditing) {
      _syncEditControllers();
    }
  }

  @override
  void dispose() {
    _thaiController.dispose();
    for (var c in _choiceControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (widget.isEditing) {
      return _buildEditMode();
    }

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
                  backgroundColor: theme.brightness == Brightness.light 
                      ? Colors.grey.shade200 
                      : Colors.grey.shade800,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  minHeight: 8,
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.05),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "LISTEN AND CHOOSE",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.headphones_rounded,
                              size: 80,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(height: 40),
                            _buildSpeakButtons(),
                          ],
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
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: widget.showAppBar
              ? const ThaiAppBar(title: "Listening Quiz")
              : null,
          body: body,
        );
      },
    );
  }

  Widget _buildChoiceButton(String choice) {
    final theme = Theme.of(context);
    final isSelected = _controller.selectedAnswer == choice;
    final isCorrect = _controller.isCorrect(choice);

    Color background = theme.cardColor;
    Color textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
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
                choice,
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

  Widget _buildSpeakButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SpeakIconButton(
          icon: Icons.volume_up_rounded,
          label: "NORMAL",
          color: AppTheme.primaryColor,
          onTap: _controller.speakThaiNormal,
        ),
        const SizedBox(width: 48),
        _SpeakIconButton(
          icon: Icons.slow_motion_video_rounded,
          label: "SLOW",
          color: Colors.pink.shade300,
          onTap: _controller.speakThaiSlow,
        ),
      ],
    );
  }

  Widget _buildFeedbackArea() {
    final theme = Theme.of(context);
    final isCorrect = _controller.answerCorrect;
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
              color: isCorrect
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isCorrect ? Colors.green : Colors.red,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isCorrect
                          ? Icons.stars_rounded
                          : Icons.sentiment_very_dissatisfied_rounded,
                      color: isCorrect
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isCorrect ? "BRILLIANT!" : "NOT QUITE",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: isCorrect
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                      ),
                    ),
                  ],
                ),
                if (!isCorrect)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Column(
                      children: [
                        Text(
                          "The correct answer was:",
                          style: TextStyle(
                            color: theme.brightness == Brightness.light
                                ? Colors.red
                                : Colors.red.shade300,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.correctAnswer ?? widget.word.thai,
                          style: TextStyle(
                            fontSize: 24,
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
                ThaiButton(
                  text: "CONTINUE",
                  onPressed: () =>
                      Navigator.of(context).pop(_controller.answerCorrect),
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
          ? const ThaiAppBar(title: "⚙️ Listening Settings")
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
                          Icons.headphones_rounded,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Listening Configuration",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Configure the audio word and the four choices.",
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
                    "AUDIO WORD (THAI)",
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
                    label: 'Word to speak (Thai)',
                    icon: Icons.record_voice_over_rounded,
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
  }

  Widget _buildEditableChoice(int index) {
    final theme = Theme.of(context);
    bool isCorrect = _correctIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: theme.dividerColor.withValues(alpha: 0.1),
              child: Text(
                "${index + 1}",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.disabledColor,
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
                  widget.onEdit?.call('choice_$index', val);
                  if (isCorrect) {
                    widget.onEdit?.call('answer', val);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: isCorrect,
              activeColor: Colors.green,
              activeTrackColor: Colors.green.withValues(alpha: 0.3),
              inactiveThumbColor: const Color(0xFF9E9E9E),
              inactiveTrackColor: theme.brightness == Brightness.light
                  ? const Color(0xFFEEEEEE)
                  : Colors.white.withValues(alpha: 0.1),
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
              onChanged: (val) {
                if (val) {
                  setState(() {
                    _correctIndex = index;
                  });
                  widget.onEdit?.call('answer', _choiceControllers[index].text);
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

class _SpeakIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SpeakIconButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: color),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            color: color, 
            fontWeight: FontWeight.bold,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
