import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superthai/core/services/auth_service.dart';
import '../models/models.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class DataService extends ChangeNotifier {
  static final DataService _instance = DataService._internal();
  static DataService get instance => _instance;

  final FlutterTts tts = FlutterTts();
  SpeechToText? _stt;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  SharedPreferences? _prefs;

  List<LessonPlan>? _cachedPlans;

  static const String wordsCollection = 'words';
  static const String plansCollection = 'lesson_plans';
  static const String newsCollection = 'discover';
  static const String _localFavoritesKey = 'local_favorites';

  DataService._internal() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    await tts.setVolume(1.0);
    await tts.setPitch(1.0);
    await tts.setSpeechRate(0.5);
  }

  SpeechToText get stt {
    _stt ??= SpeechToText();
    return _stt!;
  }

  Future<void> addWord(WordEntry entry) async {
    await _db
        .collection(wordsCollection)
        .doc(entry.id)
        .set(entry.toMap(), SetOptions(merge: true));
  }

  Future<List<WordEntry>> getAllWords() async {
    final snapshot = await _db.collection(wordsCollection).get();
    return snapshot.docs.map((doc) => WordEntry.fromMap(doc.data())).toList();
  }

  Future<WordEntry?> getWordById(String id) async {
    final doc = await _db.collection(wordsCollection).doc(id).get();
    return doc.exists && doc.data() != null
        ? WordEntry.fromMap(doc.data()!)
        : null;
  }

  Future<List<LessonPlan>> getAllLessonPlans({bool forceRefresh = false}) async {
    if (_cachedPlans != null && !forceRefresh) {
      return _cachedPlans!;
    }

    final snapshot = await _db.collection(plansCollection).get();
    final plans =
        snapshot.docs.map((doc) => LessonPlan.fromMap(doc.data())).toList();

    plans.sort((a, b) => a.index.compareTo(b.index));
    _cachedPlans = plans;

    return plans;
  }

  Future<void> updateLessonIndices(List<LessonPlan> plans) async {
    final batch = _db.batch();
    for (int i = 0; i < plans.length; i++) {
      final docRef = _db.collection(plansCollection).doc(plans[i].id);
      batch.update(docRef, {'index': i});
    }
    await batch.commit();
    _cachedPlans = null;
    notifyListeners();
  }

  Future<List<WordEntry>> getWordsByCategory(
    String category, {
    bool forceRefresh = false,
  }) async {
    final plans = await getAllLessonPlans(forceRefresh: forceRefresh);
    final List<WordEntry> words = [];
    final Set<String> seenIds = {};

    for (var plan in plans.where((p) => p.category == category)) {
      for (var step in plan.steps) {
        final word = step.toWordEntry();
        if (word.thai.isNotEmpty && !seenIds.contains(word.stableId)) {
          words.add(word);
          seenIds.add(word.stableId);
        }
      }
    }
    return words;
  }

  Future<void> addLessonPlan(LessonPlan plan) async {
    final docRef = _db.collection(plansCollection).doc(plan.id);
    final doc = await docRef.get();

    int finalIndex = plan.index;
    DateTime finalCreatedAt = plan.createdAt ?? DateTime.now();

    if (doc.exists) {
      final oldData = doc.data() as Map<String, dynamic>;
      if (finalIndex == 0 && oldData.containsKey('index')) {
        finalIndex = oldData['index'] ?? 0;
      }
      if (oldData.containsKey('createdAt')) {
        finalCreatedAt = DateTime.tryParse(oldData['createdAt'] ?? '') ?? finalCreatedAt;
      }
    } else {
      if (finalIndex == 0) {
        final plans = await getAllLessonPlans();
        if (plans.isNotEmpty) {
          finalIndex = plans.last.index + 1;
        }
      }
    }

    final toSave = LessonPlan(
      id: plan.id,
      title: plan.title,
      category: plan.category,
      categoryEmoji: plan.categoryEmoji,
      emoji: plan.emoji,
      steps: plan.steps,
      creatorId: plan.creatorId,
      createdAt: finalCreatedAt,
      index: finalIndex,
    );

    await docRef.set(toSave.toMap(), SetOptions(merge: true));
    _cachedPlans = null;
    notifyListeners();
  }

  Future<void> deleteLessonPlan(String planId) async {
    await _db.collection(plansCollection).doc(planId).delete();
    _cachedPlans = null;
    notifyListeners();
  }

  Future<LessonPlan?> getLessonPlanByCategory(String category) async {
    final snapshot = await _db
        .collection(plansCollection)
        .where('category', isEqualTo: category)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty
        ? LessonPlan.fromMap(snapshot.docs.first.data())
        : null;
  }

  Future<bool> isDatabaseEmpty() async {
    final snapshot = await _db.collection(wordsCollection).limit(1).get();
    return snapshot.docs.isEmpty;
  }

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
      }, SetOptions(merge: true));
    }
    notifyListeners();
  }

  Future<void> _toggleLocalFavorite(WordEntry word) async {
    _prefs ??= await SharedPreferences.getInstance();
    final localFavs = _prefs!.getStringList(_localFavoritesKey) ?? [];

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
      localFavs.add(jsonEncode(word.toMap()));
    }
    await _prefs!.setStringList(_localFavoritesKey, localFavs);
    notifyListeners();
  }

  Future<bool> isFavorite(String wordId) async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      _prefs ??= await SharedPreferences.getInstance();
      final localFavs = _prefs!.getStringList(_localFavoritesKey) ?? [];
      return localFavs.any((e) {
        final entry = jsonDecode(e);
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
      final word = WordEntry.fromMap(jsonDecode(favJson));
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

  Future<void> addDiscoverItem(DiscoverItem item) async {
    await _db
        .collection(newsCollection)
        .doc(item.id)
        .set(item.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteDiscoverItem(String id) async {
    await _db.collection(newsCollection).doc(id).delete();
  }

  Future<List<DiscoverItem>> getAllDiscoverItems() async {
    final snapshot = await _db.collection(newsCollection).get();
    final items =
        snapshot.docs.map((doc) => DiscoverItem.fromMap(doc.data())).toList();

    items.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.date.compareTo(a.date);
    });

    return items;
  }
}

final dataService = DataService.instance;
