import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String? orderId;

  final String userId;
  final String fullName; // ✅ auto dari users/{uid}.name

  final String eventId;
  final String eventTitle;
  final String eventImage;
  final DateTime eventStartAt;
  final String locationName;

  final int qty;
  final int ticketPrice;
  final int subtotal;
  final int fees;
  final int total;

  final String paymentMethod; // card/paypal
  final String status; // success/pending

  final String seat; // optional, kita isi otomatis
  final DateTime? createdAt; // server timestamp (dibaca di view)

  const OrderModel({
    this.orderId,
    required this.userId,
    required this.fullName,
    required this.eventId,
    required this.eventTitle,
    required this.eventImage,
    required this.eventStartAt,
    required this.locationName,
    required this.qty,
    required this.ticketPrice,
    required this.subtotal,
    required this.fees,
    required this.total,
    required this.paymentMethod,
    required this.status,
    required this.seat,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fullName': fullName,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'eventImage': eventImage,
      'eventStartAt': Timestamp.fromDate(eventStartAt),
      'locationName': locationName,
      'qty': qty,
      'ticketPrice': ticketPrice,
      'subtotal': subtotal,
      'fees': fees,
      'total': total,
      'paymentMethod': paymentMethod,
      'status': status,
      'seat': seat,
      'createdAt': FieldValue.serverTimestamp(), // ✅ realtime server
    };
  }

  factory OrderModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final tsEvent = d['eventStartAt'];
    final tsCreated = d['createdAt'];

    return OrderModel(
      orderId: doc.id,
      userId: (d['userId'] ?? '').toString(),
      fullName: (d['fullName'] ?? 'Guest').toString(),
      eventId: (d['eventId'] ?? '').toString(),
      eventTitle: (d['eventTitle'] ?? '').toString(),
      eventImage: (d['eventImage'] ?? '').toString(),
      eventStartAt: tsEvent is Timestamp ? tsEvent.toDate() : DateTime.now(),
      locationName: (d['locationName'] ?? '').toString(),
      qty: (d['qty'] is int) ? d['qty'] : int.tryParse('${d['qty']}') ?? 1,
      ticketPrice: (d['ticketPrice'] is int)
          ? d['ticketPrice']
          : int.tryParse('${d['ticketPrice']}') ?? 0,
      subtotal: (d['subtotal'] is int)
          ? d['subtotal']
          : int.tryParse('${d['subtotal']}') ?? 0,
      fees: (d['fees'] is int) ? d['fees'] : int.tryParse('${d['fees']}') ?? 0,
      total: (d['total'] is int)
          ? d['total']
          : int.tryParse('${d['total']}') ?? 0,
      paymentMethod: (d['paymentMethod'] ?? '').toString(),
      status: (d['status'] ?? '').toString(),
      seat: (d['seat'] ?? 'A1').toString(),
      createdAt: tsCreated is Timestamp ? tsCreated.toDate() : null,
    );
  }
}
