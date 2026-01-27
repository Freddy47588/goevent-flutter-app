import 'package:cloud_firestore/cloud_firestore.dart';

class EventRepository {
  final _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchEvents({int limit = 60}) {
    return _db
        .collection('events')
        .orderBy('startAt', descending: false)
        .limit(limit)
        .snapshots();
  }
}
