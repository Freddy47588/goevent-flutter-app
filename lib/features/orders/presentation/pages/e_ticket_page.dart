import 'package:flutter/material.dart';
import '../../../events/models/event_model.dart';

class ETicketPage extends StatelessWidget {
  final EventModel event;
  const ETicketPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("E-Ticket")),
      body: Center(child: Text("E-Ticket for: ${event.title}")),
    );
  }
}
