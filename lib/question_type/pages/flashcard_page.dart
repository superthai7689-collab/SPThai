import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:superthai/core/models/models.dart';
import 'package:superthai/core/services/data_service.dart';
import 'package:superthai/ui/theme/app_theme.dart';
import 'package:superthai/ui/widgets/shared_widgets.dart';

class FlashcardPage extends StatefulWidget {
  final WordEntry word;
  final bool showAppBar;
  final bool isEditing;
  final Function(String field, String value)? onEdit;
  final int currentIndex;
  final int totalSteps;

  const FlashcardPage({
    super.key,
    required this.word,
    this.showAppBar = true,
    this.isEditing = false,
    this.onEdit,
    this.currentIndex = 0,
    this.totalSteps = 1,
  });

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  final FlutterTts tts = DataService.instance.tts;
  bool _isFavorite = false;

  // Controllers for editing mode
  late TextEditingController _thaiController;
  late TextEditingController _phoneticController;
  late TextEditingController _englishController;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
    _initControllers();
  }

  void _initControllers() {
    _thaiController = TextEditingController(text: widget.word.thai);
    _phoneticController = TextEditingController(text: widget.word.phonetic);
    _englishController = TextEditingController(text: widget.word.english);
  }

  @override
  void didUpdateWidget(FlashcardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.word.id != oldWidget.word.id) {
      _checkFavoriteStatus();
    }

    // Update controllers only if values changed from outside (not from typing)
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
    _thaiController.dispose();
    _phoneticController.dispose();
    _englishController.dispose();
    super.dispose();
  }

  Future<void> _checkFavoriteStatus() async {
    final status = await DataService.instance.isFavorite(widget.word.stableId);
    if (mounted) {
      setState(() {
        _isFavorite = status;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    await DataService.instance.toggleFavorite(widget.word);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite ? "Added to favorites" : "Removed from favorites",
          ),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> speakThaiNormal() async {
    await tts.setLanguage("th-TH");
    await tts.setSpeechRate(0.5);
    await tts.speak(widget.word.thai);
  }

  Future<void> speakThaiSlow() async {
    await tts.setLanguage("th-TH");
    await tts.setSpeechRate(0.2);
    await tts.speak(widget.word.thai);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing) {
      return _buildEditMode();
    }

    final progress =
        (widget.currentIndex + 1) /
        (widget.totalSteps > 0 ? widget.totalSteps : 1);

    Widget content = SingleChildScrollView(
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
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
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
                    mainAxisSize: MainAxisSize.min,
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
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Text(
                              "NEW VOCABULARY",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Positioned(
                              right: 12,
                              child: IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                onPressed: _toggleFavorite,
                                icon: Icon(
                                  _isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_outline_rounded,
                                  color: _isFavorite
                                      ? Colors.red
                                      : Colors.grey.shade400,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Text(
                              widget.word.thai,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 72,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.headlineLarge?.color ??
                                    AppTheme.textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.word.phonetic,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.7,
                                ),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 40),
                            const Divider(height: 1),
                            const SizedBox(height: 40),
                            const Text(
                              "MEANING",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.word.english,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 48),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildSpeakButton(
                                  icon: Icons.volume_up_rounded,
                                  label: "LISTEN",
                                  color: AppTheme.primaryColor,
                                  onTap: speakThaiNormal,
                                ),
                                const SizedBox(width: 48),
                                _buildSpeakButton(
                                  icon: Icons.slow_motion_video_rounded,
                                  label: "SLOW",
                                  color: Colors.pink.shade300,
                                  onTap: speakThaiSlow,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                  shadowColor: AppTheme.primaryColor.withValues(alpha: 0.4),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "I'VE GOT IT!",
                  style: TextStyle(fontSize: 18, letterSpacing: 1.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (!widget.showAppBar) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      appBar: widget.showAppBar ? const ThaiAppBar(title: "Flashcard") : null,
      body: content,
    );
  }

  Widget _buildEditMode() {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: widget.showAppBar
          ? const ThaiAppBar(title: "⚙️ Flashcard Settings")
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
                          Icons.style_rounded,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Flashcard Configuration",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Edit the word, phonetic guide, and translation.",
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
                    "PHONETIC",
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
                    label: 'Phonetic Pronunciation',
                    icon: Icons.record_voice_over_rounded,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "ENGLISH MEANING",
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
                    label: 'Meaning in English',
                    icon: Icons.language_rounded,
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
      margin: const EdgeInsets.only(bottom: 16),
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
                        fontSize: 16,
                        color: theme.disabledColor,
                        fontWeight: FontWeight.normal,
                      ),
                      filled: true,
                      fillColor: theme.brightness == Brightness.light
                          ? Colors.grey.shade100
                          : Colors.white.withValues(alpha: 0.1),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
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

  Widget _buildSpeakButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
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
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
