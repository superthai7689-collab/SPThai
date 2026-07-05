class ExampleSentence {
  final String sentence;
  final String gapAnswer;

  ExampleSentence({required this.sentence, required this.gapAnswer});

  Map<String, dynamic> toMap() => {
    'sentence': sentence,
    'gapAnswer': gapAnswer,
  };

  factory ExampleSentence.fromMap(Map<String, dynamic> map) => ExampleSentence(
    sentence: map['sentence'] ?? '',
    gapAnswer: map['gapAnswer'] ?? '',
  );
}

class WordEntry {
  final String id;
  final String thai;
  final String phonetic;
  final String english;
  final String category;
  final List<ExampleSentence> examples;
  final bool isCustom;
  final String? creatorId;

  WordEntry({
    required this.id,
    required this.thai,
    required this.phonetic,
    required this.english,
    required this.category,
    this.examples = const [],
    this.isCustom = false,
    this.creatorId,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'thai': thai,
    'phonetic': phonetic,
    'english': english,
    'category': category,
    'examples': examples.map((e) => e.toMap()).toList(),
    'isCustom': isCustom,
    'creatorId': creatorId,
  };

  factory WordEntry.fromMap(Map<String, dynamic> map) {
    return WordEntry(
      id: map['id'] ?? map['wordId'] ?? '',
      thai: map['thai'] ?? '',
      phonetic: map['phonetic'] ?? '',
      english: map['english'] ?? '',
      category: map['category'] ?? '',
      examples: (map['examples'] as List? ?? [])
          .map((e) => ExampleSentence.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      isCustom: map['isCustom'] ?? false,
      creatorId: map['creatorId'],
    );
  }

  // Helper to generate a stable ID based on content
  String get stableId {
    if (id.isNotEmpty && id != 'temp') return id;
    return '${thai}_$english'.hashCode.abs().toString();
  }
}

class LessonPlan {
  final String id;
  final String title;
  final String category;
  final String categoryEmoji; // เพิ่มฟิลด์อิโมจิหมวดหมู่
  final String emoji;
  final List<LessonStepData> steps;
  final String? creatorId;
  final DateTime? createdAt;

  LessonPlan({
    required this.id,
    required this.title,
    required this.category,
    this.categoryEmoji = '🎯',
    this.emoji = '📚',
    required this.steps,
    this.creatorId,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'category': category,
    'categoryEmoji': categoryEmoji,
    'emoji': emoji,
    'steps': steps.map((s) => s.toMap()).toList(),
    'creatorId': creatorId,
    'createdAt': createdAt?.toIso8601String(),
  };

  factory LessonPlan.fromMap(Map<String, dynamic> map) {
    return LessonPlan(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      categoryEmoji: map['categoryEmoji'] ?? '🎯',
      emoji: map['emoji'] ?? '📚',
      steps: (map['steps'] as List? ?? [])
          .map((s) => LessonStepData.fromMap(Map<String, dynamic>.from(s)))
          .toList(),
      creatorId: map['creatorId'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : null,
    );
  }
}

class LessonStepData {
  String type;
  String thai;
  String phonetic;
  String english;
  String question;
  String answer;
  List<String> choices;

  LessonStepData({
    required this.type,
    this.thai = '',
    this.phonetic = '',
    this.english = '',
    this.question = '',
    this.answer = '',
    List<String>? choices,
  }) : choices = choices ?? [];

  Map<String, dynamic> toMap() => {
    'type': type,
    'thai': thai,
    'phonetic': phonetic,
    'english': english,
    'question': question,
    'answer': answer,
    'choices': choices,
  };

  factory LessonStepData.fromMap(Map<String, dynamic> map) {
    return LessonStepData(
      type: map['type'] ?? 'flashcard',
      thai: map['thai'] ?? '',
      phonetic: map['phonetic'] ?? '',
      english: map['english'] ?? '',
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
      choices: List<String>.from(map['choices'] ?? []),
    );
  }

  // Helper to convert to WordEntry if needed for UI compatibility
  WordEntry toWordEntry() => WordEntry(
    id: 'temp',
    thai: thai,
    phonetic: phonetic,
    english: english,
    category: 'temp',
  );

  // Helper to convert to ExampleSentence
  ExampleSentence toExampleSentence() =>
      ExampleSentence(sentence: question, gapAnswer: answer);
}

class DiscoverItem {
  final String id;
  final String title;
  final String url;
  final String? description;
  final String? imageUrl;
  final bool isPinned;
  final DateTime date;

  DiscoverItem({
    required this.id,
    required this.title,
    required this.url,
    this.description,
    this.imageUrl,
    this.isPinned = false,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'url': url,
    'description': description,
    'imageUrl': imageUrl,
    'isPinned': isPinned,
    'date': date.toIso8601String(),
  };

  factory DiscoverItem.fromMap(Map<String, dynamic> map) => DiscoverItem(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    url: map['url'] ?? '',
    description: map['description'],
    imageUrl: map['imageUrl'],
    isPinned: map['isPinned'] ?? false,
    date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
  );
}
