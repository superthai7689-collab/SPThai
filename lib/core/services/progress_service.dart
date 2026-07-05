import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'data_service.dart';

class ProgressService extends ChangeNotifier {
  static final ProgressService _instance = ProgressService._internal();
  factory ProgressService() => _instance;

  static ProgressService get instance => _instance;

  SharedPreferences? _prefs;
  final Set<String> _triedLessonIds = {};
  static const String _triedLessonsKey = 'tried_lessons';
  static const String _localProgressKey = 'local_progress';

  ProgressService._internal() {
    _initPrefs();
    AuthService.instance.userChanges.listen((user) {
      if (user != null) {
        _migrateLocalProgressToFirestore(user.uid);
        DataService.instance.migrateFavorites(user.uid);
        _loadProgressFromFirestore();
      } else {
        _completedStepIndices.clear();
        _loadLocalProgress();
        notifyListeners();
      }
    });
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadLocalProgress();
  }

  void _loadLocalProgress() {
    if (_prefs == null) return;

    // Load tried lessons
    final tried = _prefs!.getStringList(_triedLessonsKey);
    if (tried != null) {
      _triedLessonIds.clear();
      _triedLessonIds.addAll(tried);
    }

    // Load streak
    _streakCount = _prefs!.getInt('streak_count') ?? 0;
    final lastDateStr = _prefs!.getString('last_activity_date');
    if (lastDateStr != null) {
      _lastActivityDate = DateTime.parse(lastDateStr);
      _checkStreakExpiry();
    }

    // Load progress if guest
    if (AuthService.instance.currentUser == null) {
      final localProg = _prefs!.getString(_localProgressKey);
      if (localProg != null) {
        try {
          final Map<String, dynamic> decoded = jsonDecode(localProg);
          fromMap(decoded);
        } catch (e) {
          debugPrint("Error decoding local progress: $e");
        }
      }
    }
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Map<String, Set<int>> _completedStepIndices = {};
  int _streakCount = 0;
  DateTime? _lastActivityDate;

  int get streakCount => _streakCount;

  static const String usersCollection = 'users';

  bool get isTrialLimitReached => _triedLessonIds.length >= 3;
  int get triedLessonsCount => _triedLessonIds.length;

  bool canTryLesson(String lessonId) {
    if (AuthService.instance.currentUser != null) return true;
    if (_triedLessonIds.contains(lessonId)) return true;
    return _triedLessonIds.length < 3;
  }

  void markStepAsCompleted(String lessonId, int stepIndex) {
    _completedStepIndices.putIfAbsent(lessonId, () => {});
    if (!_completedStepIndices[lessonId]!.contains(stepIndex)) {
      _completedStepIndices[lessonId]!.add(stepIndex);

      _updateStreak();

      if (AuthService.instance.currentUser != null) {
        _saveProgressToFirestore();
      } else {
        _triedLessonIds.add(lessonId);
        _saveLocalProgress();
      }
      // บังคับให้ UI อัปเดตทันที
      notifyListeners();
    }
  }

  void _updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_lastActivityDate == null) {
      _streakCount = 1;
    } else {
      final lastDate = DateTime(
        _lastActivityDate!.year,
        _lastActivityDate!.month,
        _lastActivityDate!.day,
      );
      final difference = today.difference(lastDate).inDays;

      if (difference == 1) {
        _streakCount++;
      } else if (difference > 1) {
        _streakCount = 1;
      }
      // if difference == 0, keep current streak
    }
    _lastActivityDate = today;
  }

  void _checkStreakExpiry() {
    if (_lastActivityDate == null) return;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(
      _lastActivityDate!.year,
      _lastActivityDate!.month,
      _lastActivityDate!.day,
    );
    final difference = today.difference(lastDate).inDays;

    if (difference > 1) {
      _streakCount = 0;
      Future.microtask(() => notifyListeners());
    }
  }

  Future<void> _saveLocalProgress() async {
    if (_prefs == null) return;
    await _prefs!.setStringList(_triedLessonsKey, _triedLessonIds.toList());
    await _prefs!.setString(_localProgressKey, jsonEncode(toMap()));
    if (_lastActivityDate != null) {
      await _prefs!.setString(
        'last_activity_date',
        _lastActivityDate!.toIso8601String(),
      );
      await _prefs!.setInt('streak_count', _streakCount);
    }
  }

  Future<void> _migrateLocalProgressToFirestore(String userId) async {
    if (_completedStepIndices.isEmpty) return;

    try {
      // First, fetch existing progress from Firestore to merge?
      // For now, let's just set it.
      // If the user already had progress, we might want to merge it.
      final doc = await _db.collection(usersCollection).doc(userId).get();
      Map<String, dynamic> mergedProgress = toMap();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['progress'] != null) {
          final firestoreProg = Map<String, dynamic>.from(data['progress']);
          // Merge: combine local and firestore
          firestoreProg.forEach((key, value) {
            final list = (value as List).map((e) => e as int).toSet();
            if (mergedProgress.containsKey(key)) {
              final localList = (mergedProgress[key] as List)
                  .map((e) => e as int)
                  .toSet();
              localList.addAll(list);
              mergedProgress[key] = localList.toList();
            } else {
              mergedProgress[key] = list.toList();
            }
          });
        }
      }

      await _db.collection(usersCollection).doc(userId).set({
        'progress': mergedProgress,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Clear local after migration
      _triedLessonIds.clear();
      if (_prefs != null) {
        await _prefs!.remove(_triedLessonsKey);
        await _prefs!.remove(_localProgressKey);
      }
    } catch (e) {
      debugPrint("Error migrating progress: $e");
    }
  }

  int getCompleted(String lessonId) {
    return _completedStepIndices[lessonId]?.length ?? 0;
  }

  Future<int> getTotalSteps(String lessonId) async {
    final plans = await DataService.instance.getAllLessonPlans();
    final plan = plans.where((p) => p.id == lessonId).firstOrNull;
    return plan?.steps.length ?? 0;
  }

  void resetProgress(String lessonId) {
    if (_completedStepIndices.containsKey(lessonId)) {
      _completedStepIndices.remove(lessonId);
      if (AuthService.instance.currentUser != null) {
        _saveProgressToFirestore();
      } else {
        _saveLocalProgress();
      }
      notifyListeners();
    }
  }

  // --- Firestore Sync ---

  Future<void> _saveProgressToFirestore() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    try {
      await _db.collection(usersCollection).doc(user.uid).set({
        'progress': toMap(),
        'streakCount': _streakCount,
        'lastActivityDate': _lastActivityDate != null
            ? Timestamp.fromDate(_lastActivityDate!)
            : null,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error saving progress: $e");
    }
  }

  Future<void> _loadProgressFromFirestore() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await _db.collection(usersCollection).doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['progress'] != null) {
          fromMap(Map<String, dynamic>.from(data['progress']));
        }
        _streakCount = data['streakCount'] ?? 0;
        if (data['lastActivityDate'] != null) {
          _lastActivityDate = (data['lastActivityDate'] as Timestamp).toDate();
          _checkStreakExpiry();
        }
      }
    } catch (e) {
      debugPrint("Error loading progress: $e");
    }
  }

  Map<String, dynamic> toMap() {
    return _completedStepIndices.map(
      (key, value) => MapEntry(key, value.toList()),
    );
  }

  void fromMap(Map<String, dynamic> map) {
    map.forEach((key, value) {
      _completedStepIndices[key] = (value as List).map((e) => e as int).toSet();
    });
    notifyListeners();
  }
}

final progressService = ProgressService.instance;
