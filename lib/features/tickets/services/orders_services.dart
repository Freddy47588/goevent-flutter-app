import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrdersService {
  OrdersService._();
  static final instance = OrdersService._();

  final _db = FirebaseFirestore.instance;

  Stream<List<OrderModel>> watchOrdersByUser(String userId) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((e) => OrderModel.fromDoc(e)).toList());
  }

  Future<void> cancelOrder(String orderId) async {
    await _db.collection('orders').doc(orderId).update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }
}
