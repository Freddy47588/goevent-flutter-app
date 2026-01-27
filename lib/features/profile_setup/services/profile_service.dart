import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  ProfileService._();
  static final instance = ProfileService._();

  final _db = FirebaseFirestore.instance;

  String get uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  DocumentReference<Map<String, dynamic>> userDoc(String uid) =>
      _db.collection('users').doc(uid);

  Stream<Map<String, dynamic>?> watchMe() {
    final id = uid;
    if (id.isEmpty) return const Stream.empty();
    return userDoc(id).snapshots().map((d) => d.data());
  }

  Future<void> ensureUserDoc() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = userDoc(user.uid);
    final snap = await ref.get();
    if (snap.exists) return;

    await ref.set({
      'fullName': user.displayName ?? 'User',
      'email': user.email ?? '',
      'about': '',
      'gender': '',
      'phone': '',
      'country': '',
      'themeMode': 'system',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProfile({
    required String fullName,
    required String email,
    required String gender,
    required String phone,
    required String country,
    required String about,
  }) async {
    final id = uid;
    if (id.isEmpty) throw Exception('User belum login');

    await userDoc(id).set({
      'fullName': fullName.trim(),
      'email': email.trim(),
      'gender': gender.trim(),
      'phone': phone.trim(),
      'country': country.trim(),
      'about': about.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> setThemeMode(String mode) async {
    final id = uid;
    if (id.isEmpty) return;
    await userDoc(id).set({'themeMode': mode}, SetOptions(merge: true));
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}
