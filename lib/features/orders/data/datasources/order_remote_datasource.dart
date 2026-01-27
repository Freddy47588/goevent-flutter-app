import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/order_model.dart';

class OrderRemoteDataSource {
  final FirebaseFirestore db;
  final FirebaseAuth auth;

  const OrderRemoteDataSource({required this.db, required this.auth});

  Future<String> placeOrder(OrderModel order) async {
    final user = auth.currentUser;
    if (user == null) throw Exception('User belum login.');

    // safety: userId harus match
    if (order.userId != user.uid) {
      throw Exception('userId order tidak sama dengan user login.');
    }

    final ref = await db.collection('orders').add(order.toMap());
    return ref.id;
  }
}
