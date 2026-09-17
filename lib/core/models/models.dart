import 'package:uuid/uuid.dart';
import 'package:superthai/core/services/temp_migration_service.dart'; // [TEMPORARY]

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
  final String imageUrl;
  final List<ExampleSentence> examples;
  final bool isCustom;
  final String? creatorId;

  WordEntry({
    required this.id,
    required this.thai,
    required this.phonetic,
    required this.english,
    required this.category,
    this.imageUrl = '',
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
        'imageUrl': imageUrl,
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
      imageUrl: map['imageUrl'] ?? '',
      examples: (map['examples'] as List? ?? [])
          .map((e) => ExampleSentence.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      isCustom: map['isCustom'] ?? false,
      creatorId: map['creatorId'],
    );
  }

  String get stableId {
    if (id.isNotEmpty && id != 'temp') return id;
    return '${thai}_$english'.hashCode.abs().toString();
  }
}

class LessonPlan {
  final String id;
  final String title;
  final String category;
  final String categoryEmoji;
  final String emoji;
  final List<LessonStepData> steps;
  final String? creatorId;
  final DateTime? createdAt;
  final int index;

  LessonPlan({
    required this.id,
    required this.title,
    required this.category,
    this.categoryEmoji = '🎯',
    this.emoji = '📚',
    required this.steps,
    this.creatorId,
    this.createdAt,
    this.index = 0,
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
        'index': index,
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
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      index: map['index'] ?? 0,
    );
  }
}

class LessonStepData {
  final String id;
  String type;
  String thai;
  String phonetic;
  String english;
  String question;
  String answer;
  String imageUrl;
  List<String> choices;
  List<ChatMessage>? conversation;
  bool wasConverted = false;

  LessonStepData({
    String? id,
    required this.type,
    this.thai = '',
    this.phonetic = '',
    this.english = '',
    this.question = '',
    this.answer = '',
    this.imageUrl = '',
    List<String>? choices,
    this.conversation,
    this.wasConverted = false,
  })  : id = id ?? const Uuid().v4(),
        choices = choices ?? [];

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'thai': thai,
        'phonetic': phonetic,
        'english': english,
        'question': question,
        'answer': answer,
        'imageUrl': imageUrl,
        'choices': choices,
        'conversation': conversation?.map((c) => c.toMap()).toList(),
      };

  factory LessonStepData.fromMap(Map<String, dynamic> map) {
    bool migrated = false;
    // [TEMPORARY] Legacy Migration logic
    String type = TempMigrationService.normalizeType(
      map['type'] ?? 'flashcard',
      (val) => migrated = val,
    );

    return LessonStepData(
      id: map['id'],
      type: type,
      thai: map['thai'] ?? '',
      phonetic: map['phonetic'] ?? '',
      english: map['english'] ?? '',
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      choices: List<String>.from(map['choices'] ?? []),
      conversation: (map['conversation'] as List?)
          ?.map((c) => ChatMessage.fromMap(Map<String, dynamic>.from(c)))
          .toList(),
      wasConverted: migrated,
    );
  }

  WordEntry toWordEntry() => WordEntry(
        id: 'temp',
        thai: thai,
        phonetic: phonetic,
        english: english,
        imageUrl: imageUrl,
        category: 'temp',
      );

  ExampleSentence toExampleSentence() =>
      ExampleSentence(sentence: question, gapAnswer: answer);
}

class ChatMessage {
  final String text;
  final String translation;
  final String phonetic;
  final bool isLeft;
  final String? audioUrl;

  ChatMessage({
    required this.text,
    required this.translation,
    this.phonetic = '',
    required this.isLeft,
    this.audioUrl,
  });

  Map<String, dynamic> toMap() => {
        'text': text,
        'translation': translation,
        'phonetic': phonetic,
        'isLeft': isLeft,
        'audioUrl': audioUrl,
      };

  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
        text: map['text'] ?? '',
        translation: map['translation'] ?? '',
        phonetic: map['phonetic'] ?? '',
        isLeft: map['isLeft'] ?? true,
        audioUrl: map['audioUrl'],
      );
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
