import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superthai/core/services/auth_service.dart';
import '../models/models.dart';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class DataService {
  DataService._internal() {
    _initPrefs();
  }
  static final DataService _instance = DataService._internal();
  static DataService get instance => _instance;

  final FlutterTts tts = FlutterTts();

  SpeechToText? _stt;
  SpeechToText get stt {
    _stt ??= SpeechToText();
    return _stt!;
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  SharedPreferences? _prefs;
  static const String _localFavoritesKey = 'local_favorites';

  static const String wordsCollection = 'words';
  static const String plansCollection = 'lesson_plans';
  static const String newsCollection = 'discover';

  // In-memory cache
  List<LessonPlan>? _cachedPlans;
  final Map<String, List<WordEntry>> _cachedCategoryWords = {};

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Word Operations ---

  Future<void> addWord(WordEntry entry) async {
    await _db
        .collection(wordsCollection)
        .doc(entry.id)
        .set(entry.toMap(), SetOptions(merge: true));
    _cachedCategoryWords.remove(entry.category);
  }

  Future<List<WordEntry>> getAllWords() async {
    final snapshot = await _db.collection(wordsCollection).get();
    return snapshot.docs.map((doc) => WordEntry.fromMap(doc.data())).toList();
  }

  Future<WordEntry?> getWordById(String id) async {
    final doc = await _db.collection(wordsCollection).doc(id).get();
    if (doc.exists && doc.data() != null) {
      return WordEntry.fromMap(doc.data()!);
    }
    return null;
  }

  Future<List<LessonPlan>> getAllLessonPlans({
    bool forceRefresh = false,
  }) async {
    if (_cachedPlans != null && !forceRefresh) return _cachedPlans!;

    final snapshot = await _db.collection(plansCollection).get();
    _cachedPlans = snapshot.docs
        .map((doc) => LessonPlan.fromMap(doc.data()))
        .toList();

    // Sort by createdAt to ensure consistent order (oldest first for lesson path)
    _cachedPlans!.sort((a, b) {
      if (a.createdAt == null && b.createdAt == null) return 0;
      if (a.createdAt == null) {
        return -1; // Existing items without date go to the bottom
      }
      if (b.createdAt == null) return 1;
      return a.createdAt!.compareTo(b.createdAt!);
    });

    return _cachedPlans!;
  }

  Future<List<WordEntry>> getWordsByCategory(
    String category, {
    bool forceRefresh = false,
  }) async {
    if (_cachedCategoryWords.containsKey(category) && !forceRefresh) {
      return _cachedCategoryWords[category]!;
    }

    final snapshot = await _db
        .collection(wordsCollection)
        .where('category', isEqualTo: category)
        .get();

    final words = snapshot.docs
        .map((doc) => WordEntry.fromMap(doc.data()))
        .toList();
    _cachedCategoryWords[category] = words;
    return words;
  }

  // --- Lesson Plan Operations ---

  Future<void> addLessonPlan(LessonPlan plan) async {
    final toSave = LessonPlan(
      id: plan.id,
      title: plan.title,
      category: plan.category,
      categoryEmoji: plan.categoryEmoji,
      emoji: plan.emoji,
      steps: plan.steps,
      creatorId: plan.creatorId,
      createdAt: plan.createdAt ?? DateTime.now(),
    );
    await _db
        .collection(plansCollection)
        .doc(toSave.id)
        .set(toSave.toMap(), SetOptions(merge: true));
    _cachedPlans = null; // Invalidate cache
  }

  Future<void> deleteLessonPlan(String planId) async {
    await _db.collection(plansCollection).doc(planId).delete();
    _cachedPlans = null; // Invalidate cache
  }

  Future<LessonPlan?> getLessonPlanByCategory(String category) async {
    // Try to find in cache first
    if (_cachedPlans != null) {
      try {
        return _cachedPlans!.firstWhere((p) => p.category == category);
      } catch (_) {}
    }

    final snapshot = await _db
        .collection(plansCollection)
        .where('category', isEqualTo: category)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return LessonPlan.fromMap(snapshot.docs.first.data());
    }
    return null;
  }

  Future<bool> isDatabaseEmpty() async {
    final snapshot = await _db.collection(wordsCollection).limit(1).get();
    return snapshot.docs.isEmpty;
  }

  // --- Favorite Operations ---

  Future<void> toggleFavorite(WordEntry word) async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      await _toggleLocalFavorite(word);
      return;
    }

    String docId = word.stableId;
    final docRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(docId);

    final doc = await docRef.get();
    if (doc.exists) {
      await docRef.delete();
    } else {
      await docRef.set({
        ...word.toMap(),
        'id': docId,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _toggleLocalFavorite(WordEntry word) async {
    _prefs ??= await SharedPreferences.getInstance();
    final localFavs = _prefs!.getStringList(_localFavoritesKey) ?? [];

    // Check if already in favorites (by thai/english or stableId)
    final wordMap = word.toMap();
    final wordJson = jsonEncode(wordMap);

    int index = -1;
    for (int i = 0; i < localFavs.length; i++) {
      final entry = jsonDecode(localFavs[i]);
      if (entry['thai'] == word.thai && entry['english'] == word.english) {
        index = i;
        break;
      }
    }

    if (index != -1) {
      localFavs.removeAt(index);
    } else {
      localFavs.add(wordJson);
    }
    await _prefs!.setStringList(_localFavoritesKey, localFavs);
  }

  Future<bool> isFavorite(String wordId) async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      _prefs ??= await SharedPreferences.getInstance();
      final localFavs = _prefs!.getStringList(_localFavoritesKey) ?? [];
      return localFavs.any((e) {
        final entry = jsonDecode(e);
        // wordId might be stableId or thai
        return entry['id'] == wordId || entry['thai'] == wordId;
      });
    }

    final doc = await _db
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(wordId)
        .get();
    return doc.exists;
  }

  Future<List<WordEntry>> getFavoriteWords() async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      _prefs ??= await SharedPreferences.getInstance();
      final localFavs = _prefs!.getStringList(_localFavoritesKey) ?? [];
      return localFavs.map((e) => WordEntry.fromMap(jsonDecode(e))).toList();
    }

    final snapshot = await _db
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => WordEntry.fromMap(doc.data()))
        .where((w) => w.thai.isNotEmpty && w.english.isNotEmpty)
        .toList();
  }

  Future<void> migrateFavorites(String userId) async {
    _prefs ??= await SharedPreferences.getInstance();
    final localFavs = _prefs!.getStringList(_localFavoritesKey);
    if (localFavs == null || localFavs.isEmpty) return;

    final batch = _db.batch();
    for (var favJson in localFavs) {
      final wordMap = jsonDecode(favJson);
      final word = WordEntry.fromMap(wordMap);
      final docRef = _db
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(word.stableId);

      batch.set(docRef, {
        ...word.toMap(),
        'addedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
    await _prefs!.remove(_localFavoritesKey);
  }

  // --- Discover Operations ---

  Future<void> addDiscoverItem(DiscoverItem item) async {
    await _db.collection(newsCollection).doc(item.id).set(item.toMap());
  }

  Future<void> deleteDiscoverItem(String id) async {
    await _db.collection(newsCollection).doc(id).delete();
  }

  Future<List<DiscoverItem>> getAllDiscoverItems() async {
    final snapshot = await _db.collection(newsCollection).get();

    final items = snapshot.docs
        .map((doc) => DiscoverItem.fromMap(doc.data()))
        .toList();

    // Sort in memory: isPinned first (true > false), then date descending
    items.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.date.compareTo(a.date);
    });

    return items;
  }
}

final dataService = DataService.instance;
