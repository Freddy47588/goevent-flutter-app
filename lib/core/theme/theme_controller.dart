import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ThemeController {
  ThemeController._();
  static final instance = ThemeController._();

  final ValueNotifier<ThemeMode> notifier = ValueNotifier<ThemeMode>(
    ThemeMode.system,
  );

  StreamSubscription<User?>? _authSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userDocSub;

  /// Panggil sekali saat app start
  void init() {
    _authSub ??= FirebaseAuth.instance.authStateChanges().listen((user) {
      _userDocSub?.cancel();
      _userDocSub = null;

      if (user == null) {
        // kalau logout, balik ke system
        notifier.value = ThemeMode.system;
        return;
      }

      // listen perubahan themeMode di users/{uid}
      _userDocSub = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((doc) {
            final data = doc.data();
            final v = (data?['themeMode'] ?? 'system').toString();
            notifier.value = _stringToMode(v);
          });
    });
  }

  /// Set theme + simpan ke Firestore users/{uid}.themeMode
  Future<void> setTheme(ThemeMode mode) async {
    notifier.value = mode;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // FIX: Gunakan update() dengan merge: true agar tidak menimpa data lain
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(
          {'themeMode': _modeToString(mode)},
          SetOptions(merge: true),
        );
  }

  String _modeToString(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
      default:
        return 'system';
    }
  }

  ThemeMode _stringToMode(String v) {
    switch (v) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  Future<void> dispose() async {
    await _userDocSub?.cancel();
    await _authSub?.cancel();
    _userDocSub = null;
    _authSub = null;
  }
}
