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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    // Brand accent GoEvent (biar tetap “biru GoEvent” di dark juga)
    final brand = AppColors.lightPrimary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'All Tickets',
          style: AppTextStyles.h3.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: userId.isEmpty
          ? _EmptyState(
              title: 'Belum Login',
              subtitle: 'Silakan login dulu untuk melihat tiket kamu.',
              icon: Icons.lock_outline,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            )
          : StreamBuilder<List<OrderModel>>(
              stream: OrdersService.instance.watchOrdersByUser(userId),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: brand));
                }
                if (snap.hasError) {
                  return _EmptyState(
                    title: 'Gagal memuat data',
                    subtitle: snap.error.toString(),
                    icon: Icons.error_outline,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
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
                      surface: surface,
                      border: border,
                      brand: brand,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: items.isEmpty
                          ? _EmptyState(
                              title: 'Kosong',
                              subtitle: 'Belum ada tiket di tab ini.',
                              icon: Icons.confirmation_num_outlined,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
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
                                  isDark: isDark,
                                  surface: surface,
                                  border: border,
                                  brand: brand,
                                  textPrimary: textPrimary,
                                  textSecondary: textSecondary,

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

  final Color surface;
  final Color border;
  final Color brand;
  final Color textSecondary;

  const _TicketSegmented({
    required this.value,
    required this.onChanged,
    required this.surface,
    required this.border,
    required this.brand,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    Widget pill(String text, TicketTab v) {
      final selected = value == v;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? brand : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: selected ? Colors.white : textSecondary,
                fontWeight: FontWeight.w800,
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
        color: surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
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

  final bool isDark;
  final Color surface;
  final Color border;
  final Color brand;
  final Color textPrimary;
  final Color textSecondary;

  final VoidCallback onCancelBooking;
  final VoidCallback onViewTicket;
  final VoidCallback onEventDetail;
  final VoidCallback onReview;

  const _TicketCardFinal({
    required this.tab,
    required this.order,
    required this.isDark,
    required this.surface,
    required this.border,
    required this.brand,
    required this.textPrimary,
    required this.textSecondary,
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

    final outlineStyle = OutlinedButton.styleFrom(
      foregroundColor: brand,
      side: BorderSide(color: border, width: 1.4),
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    final outlineNeutralStyle = OutlinedButton.styleFrom(
      foregroundColor: textPrimary,
      side: BorderSide(color: border, width: 1.4),
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    final elevatedStyle = ElevatedButton.styleFrom(
      backgroundColor: brand,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 8),
            color: Colors.black.withOpacity(isDark ? 0.22 : 0.08),
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
                    color: border.withOpacity(0.35),
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: textSecondary,
                    ),
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
                        color: textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            order.locationName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption.copyWith(
                              color: textSecondary,
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

          // ===== Buttons per tab (layout tetap) =====
          if (tab == TicketTab.upcoming) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancelBooking,
                    style: outlineNeutralStyle,
                    child: const Text('Cancel Booking'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onViewTicket,
                    style: elevatedStyle,
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
                    style: outlineStyle,
                    child: const Text('Event Detail'),
                  ),
                ),
                const SizedBox(width: 10),
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
                          backgroundColor: alreadyReviewed ? border : brand,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
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
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onEventDetail,
                style: outlineStyle,
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
  final Color base;

  const _StatusChip({required this.text, required this.base});

  factory _StatusChip.paid() =>
      const _StatusChip(text: 'Paid', base: Color(0xFFFF2DAA));

  factory _StatusChip.completed() =>
      const _StatusChip(text: 'Completed', base: Color(0xFF2E7D32));

  factory _StatusChip.cancelled() =>
      const _StatusChip(text: 'Cancelled', base: Color(0xFFD81B60));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = base.withOpacity(isDark ? 0.22 : 0.12);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: base,
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

  final Color textPrimary;
  final Color textSecondary;

  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 52, color: textSecondary),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.h3.copyWith(
                color: textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
