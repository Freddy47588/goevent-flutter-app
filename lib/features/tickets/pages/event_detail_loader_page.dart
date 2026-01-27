import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:goevent_app/features/events/models/event_model.dart';
import 'package:goevent_app/features/events/pages/event_detail_page.dart';

class EventDetailLoaderPage extends StatelessWidget {
  final String eventId;
  const EventDetailLoaderPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text('Gagal memuat event: ${snap.error}')),
          );
        }

        final doc = snap.data;
        final data = doc?.data();
        if (doc == null || !doc.exists || data == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Event tidak ditemukan')),
          );
        }

        final event = EventModel.fromDoc(doc);
        return EventDetailPage(event: event);
      },
    );
  }
}
