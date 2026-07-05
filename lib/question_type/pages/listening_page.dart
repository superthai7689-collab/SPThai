import 'package:flutter/material.dart';
import 'package:superthai/core/models/models.dart';
import 'package:superthai/ui/theme/app_theme.dart';
import 'package:superthai/ui/widgets/shared_widgets.dart';
import 'package:superthai/question_type/controllers/listening_controller.dart';

class ListeningPage extends StatefulWidget {
  final WordEntry word;
  final bool showAppBar;
  final bool isEditing;
  final Function(String field, String value)? onEdit;
  final int currentIndex;
  final int totalSteps;

  const ListeningPage({
    super.key,
    required this.word,
    this.showAppBar = true,
    this.isEditing = false,
    this.onEdit,
    this.currentIndex = 0,
    this.totalSteps = 1,
  });

  @override
  State<ListeningPage> createState() => _ListeningPageState();
}

class _ListeningPageState extends State<ListeningPage> {
  late final ListeningController _controller;

  // Controller for editing mode
  late TextEditingController _thaiController;

  @override
  void initState() {
    super.initState();
    _controller = ListeningController(widget.word);
    if (!widget.isEditing) {
      _controller.init();
    }
    _thaiController = TextEditingController(text: widget.word.thai);
  }

  @override
  void didUpdateWidget(ListeningPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEditing && widget.word.thai != _thaiController.text) {
      _thaiController.text = widget.word.thai;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _thaiController.dispose();
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
                    vertical: 60,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.headphones_rounded,
                        size: 80,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "LISTEN CAREFULLY",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildSpeakButtons(),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
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
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    decoration: InputDecoration(
                      hintText: "Type in Thai...",
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
                if (!_controller.answered)
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _controller.textController.text.isEmpty
                                ? theme.disabledColor
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
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          "CAN'T LISTEN RIGHT NOW",
                          style: TextStyle(
                            color: theme.disabledColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
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
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: widget.showAppBar
              ? const ThaiAppBar(title: "Listening Quiz")
              : null,
          body: body,
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
                    "Configure the word that users need to listen and type.",
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
                    "CORRECT THAI WORD",
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
                    label: 'Thai Word',
                    icon: Icons.record_voice_over_rounded,
                  ),
                  const SizedBox(height: 40),
                  Text(
                    "Note: This word will be played as audio and the user must type it exactly to pass.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: theme.disabledColor,
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
    final isCorrect = _controller.isCorrect;
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
                  ? (theme.brightness == Brightness.light
                        ? Colors.green.shade50
                        : Colors.green.withValues(alpha: 0.1))
                  : (theme.brightness == Brightness.light
                        ? Colors.red.shade50
                        : Colors.red.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isCorrect
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
                          "The correct Thai word was:",
                          style: TextStyle(
                            color: theme.brightness == Brightness.light
                                ? Colors.red
                                : Colors.red.shade300,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.word.thai,
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCorrect ? Colors.green : Colors.red,
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: color),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
