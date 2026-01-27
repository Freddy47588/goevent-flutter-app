import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'view_ticket_page.dart';
import '../../order_di.dart';
import '../../data/models/order_model.dart';

import '../../../events/models/event_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class OrderDetailPage extends StatefulWidget {
  final EventModel event;
  const OrderDetailPage({super.key, required this.event});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  int qty = 2;
  int paymentIndex = 0; // 0 = Card, 1 = PayPal

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? Colors.black : const Color(0xFFF7F7FB);
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final brand = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final dateStr = DateFormat('EEE, dd MMM yyyy').format(event.startAt);
    final timeStr = DateFormat('HH:mm').format(event.startAt);

    final ticketPrice = event.price <= 0 ? 0 : event.price;
    final subtotal = ticketPrice * qty;
    final fees = (subtotal * 0.1).round();
    final total = subtotal + fees;

    String money(int v) => NumberFormat.currency(
      locale: 'id_ID',
      symbol: v == 0 ? '' : 'Rp ',
      decimalDigits: 0,
    ).format(v);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textPrimary,
        centerTitle: true,
        title: Text(
          'Order Detail',
          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            10,
            AppSpacing.md,
            12,
          ),
          decoration: BoxDecoration(
            color: bg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 18,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _PriceMini(
                  label: 'Price',
                  value: money(total),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 54,
                width: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brand,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Kamu harus login dulu.'),
                          ),
                        );
                        return;
                      }

                      // ✅ ambil nama user dari Firestore users/{uid}
                      final userDoc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .get();
                      final fullName = (userDoc.data()?['name'] ?? 'Guest')
                          .toString();

                      final paymentMethod = paymentIndex == 0
                          ? 'card'
                          : 'paypal';

                      // seat auto sederhana: A1, A2, A3...
                      final seats = List.generate(
                        qty,
                        (i) => 'A${i + 1}',
                      ).join(', ');

                      final order = OrderModel(
                        userId: user.uid,
                        fullName: fullName,
                        eventId: event.eventId,
                        eventTitle: event.title,
                        eventImage: event.imageAsset,
                        eventStartAt: event.startAt,
                        locationName: event.locationName,
                        qty: qty,
                        ticketPrice: ticketPrice,
                        subtotal: subtotal,
                        fees: fees,
                        total: total,
                        paymentMethod: paymentMethod,
                        status: 'success',
                        seat: seats,
                      );

                      // 🔥 Firestore write via clean architecture
                      final placeOrder = OrderDI.placeOrderUseCase();
                      final orderId = await placeOrder(order);

                      // ✅ success dialog
                      await showOrderSuccessDialog(
                        context: context,
                        onViewETicket: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ViewTicketPage(orderId: orderId),
                            ),
                          );
                        },
                        onGoHome: () {
                          Navigator.pop(context);
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal membuat order: $e')),
                      );
                    }
                  },
                  child: Text(
                    'Place Order',
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          6,
          AppSpacing.md,
          120,
        ),
        children: [
          // ===== Event mini card =====
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: _ThumbImage(pathOrUrl: event.imageAsset),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: 16,
                            color: textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '$dateStr, $timeStr',
                              style: AppTextStyles.caption.copyWith(
                                color: textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.place, size: 16, color: textSecondary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              event.locationName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption.copyWith(
                                color: textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ===== Order Summary =====
          Text(
            'Order Summary',
            style: AppTextStyles.h3.copyWith(
              color: textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: border),
            ),
            child: Column(
              children: [
                _RowLine(
                  left: '${qty}x Ticket price',
                  right: money(subtotal),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                const SizedBox(height: 10),
                _RowLine(
                  left: 'Subtotal',
                  right: money(subtotal),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                const SizedBox(height: 10),
                _RowLine(
                  left: 'Fees',
                  right: money(fees),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                const SizedBox(height: 12),
                Divider(color: border),
                const SizedBox(height: 12),
                _RowTotal(
                  left: 'Total',
                  right: money(total),
                  textPrimary: textPrimary,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      'Tickets',
                      style: AppTextStyles.body.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    _QtyBtn(
                      icon: Icons.remove,
                      onTap: qty > 1 ? () => setState(() => qty--) : null,
                      border: border,
                      surface: surface,
                      textPrimary: textPrimary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$qty',
                      style: AppTextStyles.body.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _QtyBtn(
                      icon: Icons.add,
                      onTap: () => setState(() => qty++),
                      border: border,
                      surface: surface,
                      textPrimary: textPrimary,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ===== Payment Method =====
          Text(
            'Payment Method',
            style: AppTextStyles.h3.copyWith(
              color: textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: border),
            ),
            child: Column(
              children: [
                _PaymentTile(
                  title: 'Credit/Debit Card',
                  leading: _PayIcon.circle(
                    colors: const [Color(0xFFEB001B), Color(0xFFF79E1B)],
                  ),
                  selected: paymentIndex == 0,
                  onTap: () => setState(() => paymentIndex = 0),
                  brand: brand,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  border: border,
                ),
                const SizedBox(height: 10),
                _PaymentTile(
                  title: 'PayPal',
                  leading: _PayIcon.paypal(),
                  selected: paymentIndex == 1,
                  onTap: () => setState(() => paymentIndex = 1),
                  brand: brand,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  border: border,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== dialog sukses =====================

Future<void> showOrderSuccessDialog({
  required BuildContext context,
  required VoidCallback onViewETicket,
  required VoidCallback onGoHome,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final surface = isDark ? AppColors.darkSurface : Colors.white;
  final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
  final textPrimary = isDark
      ? AppColors.darkTextPrimary
      : AppColors.lightTextPrimary;
  final textSecondary = isDark
      ? AppColors.darkTextSecondary
      : AppColors.lightTextSecondary;
  final brand = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: surface.withOpacity(isDark ? 0.88 : 0.96),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.withOpacity(0.14),
                    ),
                    child: Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Congratulations!",
                    style: AppTextStyles.h3.copyWith(
                      color: textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "You have successfully placed\norder.\nEnjoy the event!",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(
                      color: textSecondary,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brand,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                      ),
                      onPressed: onViewETicket,
                      child: Text(
                        "View E-Ticket",
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: brand),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                      ),
                      onPressed: onGoHome,
                      child: Text(
                        "Go to Home",
                        style: AppTextStyles.body.copyWith(
                          color: brand,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

// ===================== components =====================

class _ThumbImage extends StatelessWidget {
  final String pathOrUrl;
  const _ThumbImage({required this.pathOrUrl});

  @override
  Widget build(BuildContext context) {
    const w = 66.0;
    const h = 66.0;

    if (pathOrUrl.startsWith('http')) {
      return Image.network(pathOrUrl, width: w, height: h, fit: BoxFit.cover);
    }
    if (pathOrUrl.isEmpty) {
      return Container(width: w, height: h, color: Colors.grey.shade300);
    }
    return Image.asset(pathOrUrl, width: w, height: h, fit: BoxFit.cover);
  }
}

class _RowLine extends StatelessWidget {
  final String left;
  final String right;
  final Color textPrimary;
  final Color textSecondary;

  const _RowLine({
    required this.left,
    required this.right,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            style: AppTextStyles.body.copyWith(
              color: textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          right,
          style: AppTextStyles.body.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _RowTotal extends StatelessWidget {
  final String left;
  final String right;
  final Color textPrimary;

  const _RowTotal({
    required this.left,
    required this.right,
    required this.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            style: AppTextStyles.body.copyWith(
              color: textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          right,
          style: AppTextStyles.body.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color border;
  final Color surface;
  final Color textPrimary;

  const _QtyBtn({
    required this.icon,
    required this.onTap,
    required this.border,
    required this.surface,
    required this.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Icon(icon, color: textPrimary, size: 18),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final String title;
  final Widget leading;
  final bool selected;
  final VoidCallback onTap;
  final Color brand;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;

  const _PaymentTile({
    required this.title,
    required this.leading,
    required this.selected,
    required this.onTap,
    required this.brand,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.body.copyWith(
                  color: textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            _RadioDot(selected: selected, brand: brand, border: border),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool selected;
  final Color brand;
  final Color border;

  const _RadioDot({
    required this.selected,
    required this.brand,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: selected ? brand : border, width: 2),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: brand, shape: BoxShape.circle),
              ),
            )
          : null,
    );
  }
}

class _PayIcon {
  static Widget circle({required List<Color> colors}) {
    return SizedBox(
      width: 36,
      height: 24,
      child: Stack(
        children: [
          Positioned(
            left: 2,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: colors[0],
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 14,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: colors[1],
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget paypal() {
    return Container(
      width: 36,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFEAF2FF),
      ),
      child: const Text(
        'P',
        style: TextStyle(color: Color(0xFF003087), fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _PriceMini extends StatelessWidget {
  final String label;
  final String value;
  final Color textPrimary;
  final Color textSecondary;

  const _PriceMini({
    required this.label,
    required this.value,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
