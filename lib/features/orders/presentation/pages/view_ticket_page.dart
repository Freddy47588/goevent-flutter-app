import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class ViewTicketPage extends StatelessWidget {
  final String orderId;
  const ViewTicketPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
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

    final brand = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final docRef = FirebaseFirestore.instance.collection('orders').doc(orderId);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'View Ticket',
          style: AppTextStyles.h3.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: docRef.snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Text(
                'Gagal load ticket: ${snap.error}',
                style: AppTextStyles.body.copyWith(color: textSecondary),
              ),
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data!.data();
          if (data == null) {
            return Center(
              child: Text(
                'Ticket tidak ditemukan.',
                style: AppTextStyles.body.copyWith(color: textSecondary),
              ),
            );
          }

          // ===== 1) Event date & time =====
          final tsEvent = data['eventStartAt'];
          final eventStartAt = tsEvent is Timestamp
              ? tsEvent.toDate()
              : DateTime.now();

          final eventDateStr = DateFormat('dd MMM yyyy').format(eventStartAt);
          final eventTimeStr = DateFormat('hh:mm a').format(eventStartAt);

          // ===== 2) Ordered time realtime (server) =====
          final tsCreated = data['createdAt'];
          final createdAt = tsCreated is Timestamp ? tsCreated.toDate() : null;
          final orderedAtStr = createdAt == null
              ? 'Processing...'
              : DateFormat('dd MMM yyyy, HH:mm').format(createdAt);

          final fullName = (data['fullName'] ?? 'Guest').toString();
          final seat = (data['seat'] ?? 'A1').toString();

          final qrPayload = 'GOEVENT|orderId=$orderId';

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              children: [
                const SizedBox(height: 4),
                Text(
                  'Scan This QR',
                  style: AppTextStyles.h3.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'point this qr to the scan place',
                  style: AppTextStyles.body.copyWith(
                    color: textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.18 : 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: border),
                        ),
                        child: QrImageView(
                          data: qrPayload,
                          version: QrVersions.auto,
                          size: 210,
                          eyeStyle: QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          dataModuleStyle: QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: brand.withOpacity(0.9),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Ordered at: $orderedAtStr',
                            style: AppTextStyles.caption.copyWith(
                              color: textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      _DashedLine(color: border),
                      const SizedBox(height: 14),

                      Text(
                        _prettyCode(orderId),
                        style: AppTextStyles.h3.copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: _InfoItem(
                              label: 'Full Name',
                              value: fullName,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                            ),
                          ),
                          Expanded(
                            child: _InfoItem(
                              label: 'Hour',
                              value: eventTimeStr,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              alignEnd: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoItem(
                              label: 'Date',
                              value: eventDateStr,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                            ),
                          ),
                          Expanded(
                            child: _InfoItem(
                              label: 'Seat',
                              value: seat,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              alignEnd: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static String _prettyCode(String orderId) {
    final s = orderId.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    if (s.length < 8) return s;
    final a = s.substring(0, 3);
    final b = s.substring(3, 5);
    final c = s.substring(5, 6);
    final d = s.substring(6, 8);
    final e = s.length >= 10 ? s.substring(8, 10) : '';
    return e.isEmpty ? '$a $b $c $d' : '$a $b $c $d $e';
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final Color textPrimary;
  final Color textSecondary;
  final bool alignEnd;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.textPrimary,
    required this.textSecondary,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.body.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _DashedLine extends StatelessWidget {
  final Color color;
  const _DashedLine({required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final w = c.maxWidth;
        const dashW = 7.0;
        const dashH = 1.6;
        final count = (w / (dashW * 1.6)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (_) => Container(
              width: dashW,
              height: dashH,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        );
      },
    );
  }
}
