import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;

  final DateTime createdAt;
  final String eventId;
  final String eventTitle;
  final String locationName;
  final String eventImage; // bisa asset path atau url
  final DateTime eventStartAt;

  final int qty;
  final int fees;
  final int ticketPrice;
  final int subtotal;
  final int total;

  final String paymentMethod;
  final String status; // success / cancelled / etc
  final String userId;

  OrderModel({
    required this.id,
    required this.createdAt,
    required this.eventId,
    required this.eventTitle,
    required this.locationName,
    required this.eventImage,
    required this.eventStartAt,
    required this.qty,
    required this.fees,
    required this.ticketPrice,
    required this.subtotal,
    required this.total,
    required this.paymentMethod,
    required this.status,
    required this.userId,
  });

  factory OrderModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};

    DateTime toDt(dynamic v) {
      if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0);
    }

    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    return OrderModel(
      id: doc.id,
      createdAt: toDt(d['createdAt']),
      eventId: (d['eventId'] ?? '').toString(),
      eventTitle: (d['eventTitle'] ?? '').toString(),
      locationName: (d['locationName'] ?? '').toString(),
      eventImage: (d['eventImage'] ?? '').toString(),
      eventStartAt: toDt(d['eventStartAt']),
      qty: toInt(d['qty']),
      fees: toInt(d['fees']),
      ticketPrice: toInt(d['ticketPrice']),
      subtotal: toInt(d['subtotal']),
      total: toInt(d['total']),
      paymentMethod: (d['paymentMethod'] ?? '').toString(),
      status: (d['status'] ?? '').toString(),
      userId: (d['userId'] ?? '').toString(),
    );
  }
}
