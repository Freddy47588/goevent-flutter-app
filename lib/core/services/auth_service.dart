import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<UserCredential> signup(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _db.collection('users').doc(cred.user!.uid).set({
      'uid': cred.user!.uid,
      'email': cred.user!.email,
      'isProfileComplete': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return cred;
  }

  Future<bool> isProfileComplete(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return (doc.data()?['isProfileComplete'] == true);
  }

  Future<void> saveUsername(String uid, String username) async {
    await _db.collection('users').doc(uid).set({
      'username': username,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> savePhotoUrl(String uid, String photoUrl) async {
    await _db.collection('users').doc(uid).set({
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveFavouritesAndFinish(
    String uid,
    List<String> favourites,
  ) async {
    await _db.collection('users').doc(uid).set({
      'favourites': favourites,
      'isProfileComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
