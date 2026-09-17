import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  static AuthService get instance => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? _role;
  String? get role => _role;
  bool get isAdmin => _role == 'admin';

  StreamSubscription? _roleSubscription;

  AuthService._internal() {
    _auth.authStateChanges().listen((user) {
      _roleSubscription?.cancel();
      if (user != null) {
        _listenToUserRole(user.uid);
      } else {
        _role = null;
        notifyListeners();
      }
    });
  }

  void _listenToUserRole(String uid) {
    _roleSubscription = _db.collection('users').doc(uid).snapshots().listen((doc) {
      String newRole = 'member';
      if (doc.exists) {
        newRole = doc.data()?['role'] ?? 'member';
      }
      
      if (_role != newRole) {
        _role = newRole;
        notifyListeners();
      }
    });
  }

  Stream<User?> get userChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signup(String email, String password) async {
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (cred.user != null) {
      await _db.collection('users').doc(cred.user!.uid).set({
        'email': email,
        'role': 'member',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> makeAdmin(String email) async {
    final query = await _db
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw "User not found";
    }

    final userDoc = query.docs.first;
    await userDoc.reference.update({'role': 'admin'});
  }

  Future<void> updateProfileName(String name) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(name);

      await _db.collection('users').doc(user.uid).set({
        'displayName': name,
        'email': user.email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await user.reload();
      notifyListeners();
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return;

    AuthCredential credential = EmailAuthProvider.credential(
      email: user.email!,
      password: oldPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }
}

final authService = AuthService.instance;
