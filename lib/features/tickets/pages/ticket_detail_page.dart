import 'package:flutter/material.dart';

import 'package:goevent_app/features/tickets/models/order_model.dart';
import 'package:goevent_app/features/orders/presentation/pages/view_ticket_page.dart';

class TicketDetailPage extends StatelessWidget {
  final OrderModel order;
  const TicketDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return ViewTicketPage(orderId: order.id);
  }
}
