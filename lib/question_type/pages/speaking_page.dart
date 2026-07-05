import 'package:flutter/material.dart';
import 'package:superthai/core/models/models.dart';
import 'package:superthai/ui/theme/app_theme.dart';
import 'package:superthai/ui/widgets/shared_widgets.dart';
import 'package:superthai/question_type/controllers/speaking_controller.dart';

class SpeakingPage extends StatefulWidget {
  final WordEntry word;
  final bool showAppBar;
  final bool isEditing;
  final Function(String field, String value)? onEdit;
  final int currentIndex;
  final int totalSteps;

  const SpeakingPage({
    super.key,
    required this.word,
    this.showAppBar = true,
    this.isEditing = false,
    this.onEdit,
    this.currentIndex = 0,
    this.totalSteps = 1,
  });

  @override
  State<SpeakingPage> createState() => _SpeakingPageState();
}

class _SpeakingPageState extends State<SpeakingPage> {
  late final SpeakingController _controller;

  // Controllers for editing mode
  late TextEditingController _thaiController;
  late TextEditingController _phoneticController;
  late TextEditingController _englishController;

  @override
  void initState() {
    super.initState();
    _controller = SpeakingController(widget.word);
    _initControllers();
  }

  void _initControllers() {
    _thaiController = TextEditingController(text: widget.word.thai);
    _phoneticController = TextEditingController(text: widget.word.phonetic);
    _englishController = TextEditingController(text: widget.word.english);
  }

  @override
  void didUpdateWidget(SpeakingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEditing) {
      if (widget.word.thai != _thaiController.text) {
        _thaiController.text = widget.word.thai;
      }
      if (widget.word.phonetic != _phoneticController.text) {
        _phoneticController.text = widget.word.phonetic;
      }
      if (widget.word.english != _englishController.text) {
        _englishController.text = widget.word.english;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _thaiController.dispose();
    _phoneticController.dispose();
    _englishController.dispose();
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
            _buildTargetCard(),
            const SizedBox(height: 40),
            _buildRecognizedTextArea(),
            const SizedBox(height: 48),
            ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                if (!_controller.answered) {
                  return _buildMicSection();
                } else {
                  return _buildFeedbackSection();
                }
              },
            ),
          ],
        ),
      ),
    );

    if (!widget.showAppBar) {
      body = SafeArea(child: body);
    }

    return Scaffold(
      appBar: widget.showAppBar ? const ThaiAppBar(title: "Speaking") : null,
      body: body,
    );
  }

  Widget _buildEditMode() {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: widget.showAppBar
          ? const ThaiAppBar(title: "⚙️ Speaking Settings")
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
                          Icons.mic_rounded,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Speaking Configuration",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Customize the word and pronunciation guide",
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
                    "THAI WORD",
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
                    icon: Icons.translate_rounded,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "PRONUNCIATION",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.disabledColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildEditableField(
                    controller: _phoneticController,
                    field: 'phonetic',
                    label: 'Phonetic Guide',
                    icon: Icons.record_voice_over_rounded,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "MEANING",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.disabledColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildEditableField(
                    controller: _englishController,
                    field: 'english',
                    label: 'English Meaning',
                    icon: Icons.info_outline_rounded,
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

  Widget _buildTargetCard() {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
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
            "SPEAK THIS WORD",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.word.thai,
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.headlineLarge?.color ?? AppTheme.textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.word.phonetic,
            style: TextStyle(
              fontSize: 24,
              color: theme.disabledColor,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSmallSpeakButton(
                icon: Icons.volume_up_rounded,
                label: "LISTEN",
                color: AppTheme.primaryColor,
                onTap: _controller.speakThaiNormal,
              ),
              const SizedBox(width: 48),
              _buildSmallSpeakButton(
                icon: Icons.slow_motion_video_rounded,
                label: "SLOW",
                color: Colors.pink.shade300,
                onTap: _controller.speakThaiSlow,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallSpeakButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecognizedTextArea() {
    if (_controller.recognizedText.isEmpty) return const SizedBox.shrink();
    final isCorrect = _controller.answerCorrect ?? false;
    final theme = Theme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: _controller.answered
                    ? (isCorrect ? Colors.green : Colors.red)
                    : AppTheme.primaryColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                const Text(
                  "YOU SAID",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _controller.recognizedText,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMicSection() {
    return Column(
      children: [
        GestureDetector(
          onLongPressStart: (_) => _controller.startListening(),
          onLongPressEnd: (_) => _controller.stopListening(),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _controller.isListening
                      ? Colors.red
                      : AppTheme.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          (_controller.isListening
                                  ? Colors.red
                                  : AppTheme.primaryColor)
                              .withValues(alpha: 0.3),
                      blurRadius: _controller.isListening ? 30 : 20,
                      spreadRadius: _controller.isListening ? 10 : 5,
                    ),
                  ],
                ),
                child: Icon(
                  _controller.isListening
                      ? Icons.mic_rounded
                      : Icons.mic_none_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _controller.isListening
                    ? "I'M LISTENING..."
                    : "HOLD BUTTON TO SPEAK",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: _controller.isListening
                      ? Colors.red
                      : AppTheme.primaryColor,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            "CAN'T SPEAK RIGHT NOW",
            style: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackSection() {
    final correct = _controller.answerCorrect!;
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
              color: correct ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: correct ? Colors.green.shade300 : Colors.red.shade300,
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
                          ? Icons.stars_rounded
                          : Icons.sentiment_very_dissatisfied_rounded,
                      color: correct
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      correct ? "EXCELLENT!" : "ALMOST THERE!",
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
                        Navigator.of(context).pop(_controller.answerCorrect),
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
