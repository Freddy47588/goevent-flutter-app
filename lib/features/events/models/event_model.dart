import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String eventId;
  final String title;
  final String category; // tampilan asli
  final String categoryKey; // hasil normalisasi untuk filter
  final DateTime startAt;
  final String locationName;
  final int price;
  final bool isGlobal;
  final String imageAsset; // bisa URL / asset path
  final String about;
  final OrganizerModel organizer;
  final double lat;
  final double lng;
  final bool ticketAvailable;
  double get mapLat => (lat as num).toDouble();
  double get mapLng => (lng as num).toDouble();

  const EventModel({
    required this.eventId,
    required this.title,
    required this.category,
    required this.categoryKey,
    required this.startAt,
    required this.locationName,
    required this.price,
    required this.isGlobal,
    required this.imageAsset,
    required this.about,
    required this.organizer,
    required this.lat,
    required this.lng,
    required this.ticketAvailable,
  });

  static String _key(dynamic v) {
    // normalisasi aman: trim + lowercase
    return (v ?? '').toString().trim().toLowerCase();
  }

  static DateTime _parseStartAt(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }

  factory EventModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final org = (d['organizer'] as Map?)?.cast<String, dynamic>() ?? {};
    final map = (d['map'] as Map?)?.cast<String, dynamic>() ?? {};

    final rawCategory = (d['category'] ?? '').toString();

    return EventModel(
      eventId: (d['eventId'] ?? doc.id).toString(),
      title: (d['title'] ?? '').toString(),
      category: rawCategory,
      categoryKey: _key(rawCategory), // ✅ key untuk filter
      startAt: _parseStartAt(d['startAt']),
      locationName: (d['locationName'] ?? '').toString(),
      price: (d['price'] is int)
          ? d['price']
          : int.tryParse('${d['price']}') ?? 0,
      isGlobal: (d['isGlobal'] ?? false) == true,
      imageAsset: (d['imageAsset'] ?? '').toString(),
      about: (d['about'] ?? '').toString(),
      organizer: OrganizerModel(
        name: (org['name'] ?? '').toString(),
        avatar: (org['avatar'] ?? '').toString(),
      ),
      lat: (map['lat'] is num) ? (map['lat'] as num).toDouble() : 0.0,
      lng: (map['lng'] is num) ? (map['lng'] as num).toDouble() : 0.0,
      ticketAvailable: (d['ticketAvailable'] ?? false) == true,
    );
  }
}

class OrganizerModel {
  final String name;
  final String avatar;
  const OrganizerModel({required this.name, required this.avatar});
}
