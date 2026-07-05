import 'package:flutter/material.dart';
import 'package:superthai/core/models/models.dart';
import 'package:superthai/ui/theme/app_theme.dart';
import 'package:superthai/ui/widgets/shared_widgets.dart';
import 'package:superthai/question_type/controllers/sentence_order_controller.dart';

class SentenceOrderPage extends StatefulWidget {
  final WordEntry word;
  final List<String> choices;
  final String? correctAnswer;
  final String category;
  final bool showAppBar;
  final bool isEditing;
  final Function(String field, dynamic value)? onEdit;
  final int currentIndex;
  final int totalSteps;

  const SentenceOrderPage({
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
  State<SentenceOrderPage> createState() => _SentenceOrderPageState();
}

class _SentenceOrderPageState extends State<SentenceOrderPage> {
  late final SentenceOrderController _controller;
  late final TextEditingController _sentenceController;
  late final TextEditingController _englishController;
  final List<TextEditingController> _tokenControllers = [];
  int? _lastAddedIndex;

  @override
  void initState() {
    super.initState();
    _controller = SentenceOrderController(
      word: widget.word,
      initialChoices: widget.choices,
      correctAnswer: widget.correctAnswer,
    );
    _sentenceController = TextEditingController(
      text: widget.correctAnswer ?? widget.word.thai,
    );
    _englishController = TextEditingController(text: widget.word.english);
    _syncTextFields();
  }

  void _syncTextFields() {
    final targetSentence = widget.correctAnswer ?? widget.word.thai;
    if (_sentenceController.text != targetSentence) {
      _sentenceController.text = targetSentence;
    }

    if (_englishController.text != widget.word.english) {
      _englishController.text = widget.word.english;
    }

    // Sync controllers list length
    while (_tokenControllers.length < widget.choices.length) {
      _tokenControllers.add(TextEditingController());
    }
    while (_tokenControllers.length > widget.choices.length) {
      _tokenControllers.removeLast().dispose();
    }

    // Update text without losing cursor position
    for (int i = 0; i < widget.choices.length; i++) {
      if (_tokenControllers[i].text != widget.choices[i]) {
        _tokenControllers[i].text = widget.choices[i];
      }
    }
  }

  @override
  void didUpdateWidget(SentenceOrderPage oldWidget) {
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
    _sentenceController.dispose();
    _englishController.dispose();
    for (var c in _tokenControllers) {
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
        final progress =
            (widget.currentIndex + 1) /
            (widget.totalSteps > 0 ? widget.totalSteps : 1);

        Widget body = _controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                            const Center(
                              child: Text(
                                "ARRANGE THE SENTENCE",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: Text(
                                widget.word.english,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Selected Tokens Area
                            Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(minHeight: 100),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _controller.selectedTokens
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                      return _buildToken(
                                        entry.value,
                                        () => _controller.deselectToken(
                                          entry.key,
                                        ),
                                        isSelected: true,
                                      );
                                    })
                                    .toList(),
                              ),
                            ),
                            const SizedBox(height: 40),
                            // Available Tokens Area
                            Center(
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 12,
                                alignment: WrapAlignment.center,
                                children: _controller.availableTokens
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                      return _buildToken(
                                        entry.value,
                                        () =>
                                            _controller.selectToken(entry.key),
                                      );
                                    })
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_controller.answered)
                    _buildFeedbackArea()
                  else
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ThaiButton(
                          text: "CHECK",
                          onPressed: _controller.selectedTokens.isEmpty
                              ? null
                              : () => _controller.checkAnswer(),
                        ),
                      ),
                    ),
                ],
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

  Widget _buildToken(
    String text,
    VoidCallback onTap, {
    bool isSelected = false,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: _controller.answered ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackArea() {
    final theme = Theme.of(context);
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
                  ? (theme.brightness == Brightness.light
                        ? Colors.green.shade50
                        : Colors.green.withValues(alpha: 0.1))
                  : (theme.brightness == Brightness.light
                        ? Colors.red.shade50
                        : Colors.red.withValues(alpha: 0.1)),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                        "Correct Answer: ${widget.correctAnswer ?? widget.word.thai}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ThaiButton(
                      text: "CONTINUE",
                      color: correct ? Colors.green : Colors.red,
                      onPressed: () =>
                          Navigator.pop(context, _controller.answerCorrect),
                    ),
                  ),
                ],
              ),
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
          ? const ThaiAppBar(title: "⚙️ Sentence Settings")
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
                          Icons.sort_rounded,
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
                    "Split the sentence into words for the user to arrange.",
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
                    "FULL SENTENCE (THAI)",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.disabledColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildEditableCard(
                    controller: _sentenceController,
                    field: 'answer',
                    label: 'Target Sentence',
                    icon: Icons.text_fields_rounded,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "MEANING (ENGLISH)",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.disabledColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildEditableCard(
                    controller: _englishController,
                    field: 'english',
                    label: 'English Translation',
                    icon: Icons.translate_rounded,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "WORDS / TOKENS",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.disabledColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            final newList = _tokenControllers
                                .map((e) => e.text)
                                .toList();
                            newList.add("");
                            _lastAddedIndex = newList.length - 1;
                            widget.onEdit?.call('choices', newList);
                          });
                        },
                        icon: const Icon(
                          Icons.add,
                          size: 18,
                          color: AppTheme.primaryColor,
                        ),
                        label: const Text(
                          "Add Word",
                          style: TextStyle(color: AppTheme.primaryColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._tokenControllers.asMap().entries.map(
                    (entry) => _buildEditableToken(entry.key),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableToken(int index) {
    final theme = Theme.of(context);
    final isNew = _lastAddedIndex == index;
    if (isNew) _lastAddedIndex = null; // Reset after use

    return Container(
      key: ValueKey('token_field_$index'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.light ? 0.05 : 0.2,
            ),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            child: Text(
              "${index + 1}",
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: _tokenControllers[index],
              autofocus: isNew,
              decoration: InputDecoration(
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
                    color: theme.colorScheme.primary,
                    width: 1.5,
                  ),
                ),
                filled: true,
                fillColor: theme.brightness == Brightness.light
                    ? Colors.grey.shade100
                    : Colors.white.withValues(alpha: 0.1),
                hintText: "Tap to type...",
                hintStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.grey,
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
              onChanged: (val) {
                widget.onEdit?.call(
                  'choices',
                  _tokenControllers.map((e) => e.text).toList(),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.remove_circle_outline,
              color: Colors.red,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                final newList = _tokenControllers.map((e) => e.text).toList();
                newList.removeAt(index);
                widget.onEdit?.call('choices', newList);
              });
            },
          ),
        ],
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
