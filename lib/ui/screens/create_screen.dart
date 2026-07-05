import 'package:flutter/material.dart';
import 'package:superthai/core/models/models.dart';
import 'package:superthai/core/services/auth_service.dart';
import 'package:superthai/ui/theme/app_theme.dart';
import 'package:superthai/question_type/pages/flashcard_page.dart';
import 'package:superthai/question_type/pages/four_choice_page.dart';
import 'package:superthai/question_type/pages/fill_blank_page.dart';
import 'package:superthai/question_type/pages/sentence_order_page.dart';
import 'package:superthai/question_type/pages/vowel_fill_page.dart';
import 'package:superthai/question_type/pages/speaking_page.dart';
import 'package:superthai/question_type/pages/listening_page.dart';
import 'package:superthai/question_type/pages/listening_choice_page.dart';
import 'package:superthai/ui/screens/lesson_details_screen.dart';
import 'package:superthai/ui/screens/main_container.dart';
import 'package:superthai/ui/widgets/shared_widgets.dart';
import 'package:superthai/ui/screens/login_screen.dart';
import 'package:uuid/uuid.dart';

class CreateScreen extends StatefulWidget {
  final LessonPlan? existingPlan;
  const CreateScreen({super.key, this.existingPlan});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  String _lessonTitle = 'My New Lesson';
  String _lessonCategory = 'General';
  String _categoryEmoji = '🎯';
  String _lessonEmoji = '📚';
  String? _existingId;

  List<LessonStepData> _lessonSteps = [
    LessonStepData(type: 'Flashcard', thai: '', phonetic: '', english: ''),
  ];
  int _activeStepIndex = 0;

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _activeStepIndex);
    if (widget.existingPlan != null) {
      _existingId = widget.existingPlan!.id;
      _lessonTitle = widget.existingPlan!.title;
      _lessonCategory = widget.existingPlan!.category;
      _categoryEmoji = widget.existingPlan!.categoryEmoji;
      _lessonEmoji = widget.existingPlan!.emoji;
      _lessonSteps = List.from(widget.existingPlan!.steps);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CreateScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.existingPlan != oldWidget.existingPlan) {
      setState(() {
        if (widget.existingPlan != null) {
          _existingId = widget.existingPlan!.id;
          _lessonTitle = widget.existingPlan!.title;
          _lessonCategory = widget.existingPlan!.category;
          _categoryEmoji = widget.existingPlan!.categoryEmoji;
          _lessonEmoji = widget.existingPlan!.emoji;
          _lessonSteps = List.from(widget.existingPlan!.steps);
        } else {
          _existingId = null;
          _lessonTitle = 'My New Lesson';
          _lessonCategory = 'General';
          _categoryEmoji = '🎯';
          _lessonEmoji = '📚';
          _lessonSteps = [
            LessonStepData(
              type: 'Flashcard',
              thai: '',
              phonetic: '',
              english: '',
            ),
          ];
        }
        _activeStepIndex = 0;
        if (_pageController.hasClients) {
          _pageController.jumpToPage(0);
        }
      });
    }
  }

  final List<Map<String, dynamic>> _questionTypeOptions = [
    {
      'name': 'Flashcard',
      'icon': Icons.amp_stories_rounded,
      'desc': 'Show word and meaning',
    },
    {
      'name': 'Four Choice',
      'icon': Icons.quiz_rounded,
      'desc': 'Multiple choice question',
    },
    {
      'name': 'Fill Blank',
      'icon': Icons.text_fields_rounded,
      'desc': 'Type the missing word',
    },
    {
      'name': 'Speaking',
      'icon': Icons.mic_rounded,
      'desc': 'Practice pronunciation',
    },
    {
      'name': 'Listening',
      'icon': Icons.headphones_rounded,
      'desc': 'Listen and identify',
    },
    {
      'name': 'Listening Choice',
      'icon': Icons.hearing_rounded,
      'desc': 'Listen and choose 4 choices',
    },
    {
      'name': 'Sentence Order',
      'icon': Icons.sort_rounded,
      'desc': 'Arrange words in order',
    },
    {
      'name': 'Vowel Fill',
      'icon': Icons.spellcheck_rounded,
      'desc': 'Fill the missing vowel',
    },
  ];

  void _addStep() {
    setState(() {
      _lessonSteps.add(
        LessonStepData(
          type: _lessonSteps.last.type,
          thai: '',
          phonetic: '',
          english: '',
        ),
      );
      _activeStepIndex = _lessonSteps.length - 1;
      _pageController.animateToPage(
        _activeStepIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  void _removeStep(int index) {
    if (_lessonSteps.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("A lesson must have at least one step!")),
      );
      return;
    }
    setState(() {
      _lessonSteps.removeAt(index);
      if (_activeStepIndex >= _lessonSteps.length) {
        _activeStepIndex = _lessonSteps.length - 1;
      }
      _pageController.jumpToPage(_activeStepIndex);
    });
  }

  void _duplicateStep(int index) {
    setState(() {
      final lessonStep = _lessonSteps[index];
      _lessonSteps.insert(
        index + 1,
        LessonStepData(
          type: lessonStep.type,
          thai: lessonStep.thai,
          phonetic: lessonStep.phonetic,
          english: lessonStep.english,
          question: lessonStep.question,
          answer: lessonStep.answer,
          choices: List.from(lessonStep.choices),
        ),
      );
      _activeStepIndex = index + 1;
      _pageController.animateToPage(
        _activeStepIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  void _showLessonSettings() {
    final titleController = TextEditingController(text: _lessonTitle);
    final categoryController = TextEditingController(text: _lessonCategory);
    final categoryEmojiController = TextEditingController(text: _categoryEmoji);
    final emojiController = TextEditingController(text: _lessonEmoji);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Lesson Settings",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Lesson Title',
                      prefixIcon: const Icon(Icons.title_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: emojiController,
                    textAlign: TextAlign.center,
                    maxLength: 2, // จำกัดความยาวสั้นๆ สำหรับอิโมจิ
                    decoration: InputDecoration(
                      labelText: 'Icon',
                      counterText: "", // ซ่อนตัวเลขบอกจำนวนตัวอักษร
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: categoryController,
                    decoration: InputDecoration(
                      labelText: 'Category Name',
                      prefixIcon: const Icon(Icons.category_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: categoryEmojiController,
                    textAlign: TextAlign.center,
                    maxLength: 2,
                    decoration: InputDecoration(
                      labelText: 'Cat Icon',
                      counterText: "",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _lessonTitle = titleController.text;
                  _lessonCategory = categoryController.text;
                  _categoryEmoji = categoryEmojiController.text;
                  _lessonEmoji = emojiController.text;
                });
                Navigator.pop(context);
              },
              child: const Text("Save Settings"),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showSignupPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Account Required 🚀"),
        content: const Text(
          "Please create an account or login to save and share your own lessons!",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Later"),
          ),
          ThaiButton(
            text: "Login / Sign Up",
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  void _saveLesson() async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      _showSignupPrompt(context);
      return;
    }

    final plan = LessonPlan(
      id: _existingId ?? const Uuid().v4(),
      title: _lessonTitle,
      category: _lessonCategory,
      categoryEmoji: _categoryEmoji.isEmpty ? '🎯' : _categoryEmoji,
      emoji: _lessonEmoji.isEmpty ? '📚' : _lessonEmoji,
      steps: _lessonSteps,
      creatorId: user.uid,
    );

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => LessonDetailsScreen(lessonPlan: plan),
      ),
    );

    if (result == true && mounted) {
      MainContainer.of(context)?.switchToLesson();
    }
  }

  Widget _buildTestPreviewForIndex(int index) {
    final selectedStep = _lessonSteps[index];
    final dummyWord = selectedStep.toWordEntry();
    final dummySentence = selectedStep.toExampleSentence();

    switch (selectedStep.type) {
      case 'Flashcard':
        return FlashcardPage(
          word: dummyWord,
          showAppBar: false,
          isEditing: true,
          onEdit: (field, value) => _updateStepForIndex(index, field, value),
        );
      case 'Four Choice':
        return FourChoicePage(
          word: dummyWord,
          choices: selectedStep.choices,
          correctAnswer: selectedStep.answer,
          category: 'Preview',
          showAppBar: false,
          isEditing: true,
          onEdit: (field, value) => _updateStepForIndex(index, field, value),
        );
      case 'Fill Blank':
        return FillBlankPage(
          sentence: dummySentence,
          showAppBar: false,
          isEditing: true,
          onEdit: (field, value) => _updateStepForIndex(index, field, value),
        );
      case 'Speaking':
        return SpeakingPage(
          word: dummyWord,
          showAppBar: false,
          isEditing: true,
          onEdit: (field, value) => _updateStepForIndex(index, field, value),
        );
      case 'Listening':
        return ListeningPage(
          word: dummyWord,
          showAppBar: false,
          isEditing: true,
          onEdit: (field, value) => _updateStepForIndex(index, field, value),
        );
      case 'Listening Choice':
        return ListeningChoicePage(
          word: dummyWord,
          choices: selectedStep.choices,
          correctAnswer: selectedStep.answer,
          showAppBar: false,
          isEditing: true,
          onEdit: (field, value) => _updateStepForIndex(index, field, value),
        );
      case 'Sentence Order':
        return SentenceOrderPage(
          word: dummyWord,
          choices: selectedStep.choices,
          correctAnswer: selectedStep.answer,
          category: 'Preview',
          showAppBar: false,
          isEditing: true,
          onEdit: (field, value) => _updateStepForIndex(index, field, value),
        );
      case 'Vowel Fill':
        return VowelFillPage(
          word: dummyWord,
          question: selectedStep.question,
          answer: selectedStep.answer,
          choices: selectedStep.choices,
          showAppBar: false,
          isEditing: true,
          onEdit: (field, value) => _updateStepForIndex(index, field, value),
        );
      default:
        return const Center(child: Text('Select a test type'));
    }
  }

  void _updateStepForIndex(int index, String field, dynamic value) {
    setState(() {
      final lessonStep = _lessonSteps[index];
      if (field.startsWith('choice_')) {
        int choiceIndex = int.parse(field.split('_')[1]);
        String oldChoiceText = lessonStep.choices.length > choiceIndex
            ? lessonStep.choices[choiceIndex]
            : "";

        if (lessonStep.choices.length <= choiceIndex) {
          lessonStep.choices.addAll(
            List.generate(
              choiceIndex - lessonStep.choices.length + 1,
              (_) => '',
            ),
          );
        }
        lessonStep.choices[choiceIndex] = value;

        if (lessonStep.answer == oldChoiceText && oldChoiceText.isNotEmpty) {
          lessonStep.answer = value;
        }
      } else {
        if (field == 'thai') {
          lessonStep.thai = value;
        } else if (field == 'phonetic') {
          lessonStep.phonetic = value;
        } else if (field == 'english') {
          lessonStep.english = value;
        } else if (field == 'question') {
          lessonStep.question = value;
        } else if (field == 'answer') {
          lessonStep.answer = value;
        } else if (field == 'choices') {
          lessonStep.choices = List<String>.from(value);
        }
      }
    });
  }

  void _showTestTypePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.only(
            top: 12,
            left: 20,
            right: 20,
            bottom: 40,
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Change Test Type',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: _questionTypeOptions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final theme = Theme.of(context);
                    final type = _questionTypeOptions[index];
                    final isCurrent =
                        _lessonSteps[_activeStepIndex].type == type['name'];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _lessonSteps[_activeStepIndex].type = type['name'];
                        });
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppTheme.primaryColor.withValues(alpha: 0.1)
                              : theme.cardColor,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isCurrent
                                ? AppTheme.primaryColor
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? AppTheme.primaryColor
                                    : theme.dividerColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                type['icon'],
                                color: isCurrent
                                    ? Colors.white
                                    : theme.iconTheme.color?.withValues(
                                        alpha: 0.6,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    type['name'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isCurrent
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      color: isCurrent
                                          ? AppTheme.primaryColor
                                          : AppTheme.textColor,
                                    ),
                                  ),
                                  Text(
                                    type['desc'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isCurrent
                                          ? AppTheme.primaryColor.withValues(
                                              alpha: 0.7,
                                            )
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isCurrent)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppTheme.primaryColor,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: ThaiAppBar(
        showProfile: false,
        centerTitle: true,
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: _showTestTypePicker,
                child: Container(
                  height: 40,
                  width: 50,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        _getIconForType(_lessonSteps[_activeStepIndex].type),
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Icon(
                          Icons.arrow_drop_down,
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.5,
                          ),
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        titleWidget: GestureDetector(
          onTap: _showLessonSettings,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Create",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                _lessonTitle,
                style: TextStyle(fontSize: 12, color: theme.disabledColor),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 4, left: 4),
            child: ElevatedButton(
              onPressed: _saveLesson,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                minimumSize: const Size(60, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Next",
                style: TextStyle(fontSize: 13, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _activeStepIndex = index;
                });
              },
              itemCount: _lessonSteps.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: theme.brightness == Brightness.light
                              ? 0.05
                              : 0.2,
                        ),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: KeyedSubtree(
                      key: ValueKey('$index-${_lessonSteps[index].type}'),
                      child: _buildTestPreviewForIndex(index),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildStepBar(),
    );
  }

  Widget _buildStepBar() {
    final theme = Theme.of(context);
    return Container(
      height: 95,
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.light ? 0.05 : 0.2,
            ),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _lessonSteps.length,
                padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
                itemBuilder: (context, index) {
                  final isActive = index == _activeStepIndex;
                  return _buildStepItem(index, isActive);
                },
              ),
            ),
            const VerticalDivider(width: 20, indent: 15, endIndent: 15),
            _buildAddButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(int index, bool isActive) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        setState(() => _activeStepIndex = index);
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      onLongPress: () => _showStepActions(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 60,
              height: 65,
              decoration: BoxDecoration(
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.dividerColor.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : theme.disabledColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Icon(
                    _getIconForType(_lessonSteps[index].type),
                    size: 20,
                    color: isActive
                        ? Colors.white
                        : theme.iconTheme.color?.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
            if (_lessonSteps.length > 1)
              Positioned(
                top: -6,
                right: -6,
                child: GestureDetector(
                  onTap: () => _removeStep(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.cardColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 8,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    final theme = Theme.of(context);
    return InkWell(
      onTap: _addStep,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 50,
        height: 50,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.primary, width: 1.5),
        ),
        child: Icon(
          Icons.add_rounded,
          color: theme.colorScheme.primary,
          size: 24,
        ),
      ),
    );
  }

  void _showStepActions(int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Step ${index + 1} Actions",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.copy_rounded, color: Colors.blue),
                title: const Text("Duplicate Step"),
                onTap: () {
                  Navigator.pop(context);
                  _duplicateStep(index);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                ),
                title: const Text(
                  "Delete Step",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _removeStep(index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconForType(String type) {
    return _questionTypeOptions.firstWhere((e) => e['name'] == type)['icon'] ??
        Icons.help_outline;
  }
}
