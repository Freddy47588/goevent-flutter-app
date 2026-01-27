import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';

import '../models/order_model.dart';
import '../services/orders_services.dart';
import 'cancel_booking_page.dart';
import 'event_detail_loader_page.dart';
import 'review_sheet.dart';
import 'ticket_detail_page.dart';

enum TicketTab { upcoming, completed, cancelled }

class TicketsPage extends StatefulWidget {
  const TicketsPage({super.key});

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  TicketTab _tab = TicketTab.upcoming;

  bool _isUpcoming(OrderModel o) =>
      o.status == 'success' && o.eventStartAt.isAfter(DateTime.now());

  bool _isCompleted(OrderModel o) =>
      o.status == 'success' && !o.eventStartAt.isAfter(DateTime.now());

  bool _isCancelled(OrderModel o) => o.status == 'cancelled';

  List<OrderModel> _filter(List<OrderModel> all) {
    switch (_tab) {
      case TicketTab.upcoming:
        return all.where(_isUpcoming).toList();
      case TicketTab.completed:
        return all.where(_isCompleted).toList();
      case TicketTab.cancelled:
        return all.where(_isCancelled).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'All Tickets',
          style: AppTextStyles.h3.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: userId.isEmpty
          ? const _EmptyState(
              title: 'Belum Login',
              subtitle: 'Silakan login dulu untuk melihat tiket kamu.',
              icon: Icons.lock_outline,
            )
          : StreamBuilder<List<OrderModel>>(
              stream: OrdersService.instance.watchOrdersByUser(userId),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return _EmptyState(
                    title: 'Gagal memuat data',
                    subtitle: snap.error.toString(),
                    icon: Icons.error_outline,
                  );
                }

                final all = snap.data ?? [];
                final items = _filter(all);

                return Column(
                  children: [
                    const SizedBox(height: 10),
                    _TicketSegmented(
                      value: _tab,
                      onChanged: (v) => setState(() => _tab = v),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: items.isEmpty
                          ? const _EmptyState(
                              title: 'Kosong',
                              subtitle: 'Belum ada tiket di tab ini.',
                              icon: Icons.confirmation_num_outlined,
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              itemCount: items.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, i) {
                                final o = items[i];

                                return _TicketCardFinal(
                                  tab: _tab,
                                  order: o,

                                  // Upcoming
                                  onCancelBooking: () async {
                                    final ok = await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            CancelBookingPage(order: o),
                                      ),
                                    );

                                    if (ok == true && mounted) {
                                      // pindah ke Cancelled biar sesuai UX
                                      setState(
                                        () => _tab = TicketTab.cancelled,
                                      );
                                    }
                                  },
                                  onViewTicket: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            TicketDetailPage(order: o),
                                      ),
                                    );
                                  },

                                  // Completed/Cancelled
                                  onEventDetail: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EventDetailLoaderPage(
                                          eventId: o.eventId,
                                        ),
                                      ),
                                    );
                                  },

                                  // Review sheet
                                  onReview: () async {
                                    await showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => ReviewSheet(order: o),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _TicketSegmented extends StatelessWidget {
  final TicketTab value;
  final ValueChanged<TicketTab> onChanged;

  const _TicketSegmented({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget pill(String text, TicketTab v) {
      final selected = value == v;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? AppColors.lightPrimary : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          pill('Upcoming', TicketTab.upcoming),
          pill('Completed', TicketTab.completed),
          pill('Cancelled', TicketTab.cancelled),
        ],
      ),
    );
  }
}

class _TicketCardFinal extends StatelessWidget {
  final TicketTab tab;
  final OrderModel order;

  final VoidCallback onCancelBooking;
  final VoidCallback onViewTicket;
  final VoidCallback onEventDetail;
  final VoidCallback onReview;

  const _TicketCardFinal({
    required this.tab,
    required this.order,
    required this.onCancelBooking,
    required this.onViewTicket,
    required this.onEventDetail,
    required this.onReview,
  });

  ImageProvider _img() {
    final v = order.eventImage.trim();
    if (v.startsWith('http')) return NetworkImage(v);
    return AssetImage(v.isEmpty ? 'assets/images/placeholder.jpg' : v);
  }

  @override
  Widget build(BuildContext context) {
    final statusChip = switch (tab) {
      TicketTab.upcoming => _StatusChip.paid(),
      TicketTab.completed => _StatusChip.completed(),
      TicketTab.cancelled => _StatusChip.cancelled(),
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 8),
            color: Color(0x12000000),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image(
                  image: _img(),
                  width: 62,
                  height: 62,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 62,
                    height: 62,
                    alignment: Alignment.center,
                    color: const Color(0xFFEDEDED),
                    child: const Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.eventTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            order.locationName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        statusChip,
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ===== Buttons per tab (FINAL sesuai screenshot) =====
          if (tab == TicketTab.upcoming) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancelBooking,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel Booking'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onViewTicket,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('View Ticket'),
                  ),
                ),
              ],
            ),
          ] else if (tab == TicketTab.completed) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onEventDetail,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Event Detail'),
                  ),
                ),
                const SizedBox(width: 10),

                // ✅ Disable kalau sudah review
                Expanded(
                  child: FutureBuilder<bool>(
                    future: FirebaseFirestore.instance
                        .collection('orders')
                        .doc(order.id)
                        .collection('reviews')
                        .limit(1)
                        .get()
                        .then((q) => q.docs.isNotEmpty),
                    builder: (context, snap) {
                      final alreadyReviewed = snap.data == true;

                      return ElevatedButton(
                        onPressed: alreadyReviewed ? null : onReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: alreadyReviewed
                              ? Colors.grey.shade400
                              : AppColors.lightPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          alreadyReviewed ? 'Reviewed' : 'Write a Review',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ] else ...[
            // Cancelled: 1 tombol full width
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onEventDetail,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Event Detail'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;

  const _StatusChip({required this.text, required this.bg, required this.fg});

  factory _StatusChip.paid() {
    return _StatusChip(
      text: 'Paid',
      bg: const Color(0xFFFFE6F2),
      fg: const Color(0xFFFF2DAA),
    );
  }

  factory _StatusChip.completed() {
    return _StatusChip(
      text: 'Completed',
      bg: const Color(0xFFE8F7EA),
      fg: const Color(0xFF2E7D32),
    );
  }

  factory _StatusChip.cancelled() {
    return _StatusChip(
      text: 'Cancelled',
      bg: const Color(0xFFFFE6EC),
      fg: const Color(0xFFD81B60),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  const _EmptyState.icon({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 52, color: Colors.black38),
            const SizedBox(height: 12),
            Text(title, style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
