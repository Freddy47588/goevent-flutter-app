import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../orders/presentation/pages/order_detail_page.dart';
import '../models/event_model.dart';

class EventDetailPage extends StatelessWidget {
  final EventModel event;
  const EventDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? Colors.black : Colors.white;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final brand = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final dateStr = DateFormat(
      'EEE, dd MMM yyyy • HH:mm',
      'id_ID',
    ).format(event.startAt);

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 260,
            backgroundColor: bg,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _BannerImage(pathOrUrl: event.imageAsset),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.15),
                          Colors.black.withOpacity(0.85),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    bottom: AppSpacing.md,
                    child: Row(
                      children: [
                        _Chip(
                          text: event.category,
                          bg: brand.withOpacity(0.15),
                          fg: Colors.white,
                          border: brand.withOpacity(0.35),
                        ),
                        const SizedBox(width: 8),
                        _Chip(
                          text: event.isGlobal ? 'Global' : 'Local',
                          bg: Colors.white.withOpacity(0.12),
                          fg: Colors.white,
                          border: Colors.white.withOpacity(0.18),
                        ),
                        const Spacer(),
                        _Chip(
                          text: event.ticketAvailable ? 'Tickets' : 'No Ticket',
                          bg: event.ticketAvailable
                              ? Colors.green.withOpacity(0.22)
                              : Colors.red.withOpacity(0.22),
                          fg: Colors.white,
                          border: Colors.white.withOpacity(0.18),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: AppTextStyles.h2.copyWith(
                      color: textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),

                  _InfoRow(
                    icon: Icons.calendar_month,
                    title: dateStr,
                    subtitle: 'Mulai',
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    brand: brand,
                  ),
                  const SizedBox(height: 10),

                  _InfoRow(
                    icon: Icons.place,
                    title: event.locationName,
                    subtitle: 'Lokasi',
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    brand: brand,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: brand.withOpacity(0.15),
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Organizer',
                                style: AppTextStyles.caption.copyWith(
                                  color: textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                event.organizer.name.isEmpty
                                    ? '-'
                                    : event.organizer.name,
                                style: AppTextStyles.body.copyWith(
                                  color: textPrimary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.verified, color: brand),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  Text(
                    'About',
                    style: AppTextStyles.h3.copyWith(
                      color: textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    event.about.isEmpty ? '-' : event.about,
                    style: AppTextStyles.body.copyWith(
                      color: textSecondary,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            10,
            AppSpacing.md,
            12,
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.payments_outlined, color: brand),
                      const SizedBox(width: 10),
                      Text(
                        event.price <= 0 ? 'Free' : 'Rp ${event.price}',
                        style: AppTextStyles.body.copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 54,
                width: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brand,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  onPressed: event.ticketAvailable
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderDetailPage(event: event),
                            ),
                          );
                        }
                      : null,
                  child: Text(
                    event.ticketAvailable ? 'Buy Ticket' : 'Sold / N/A',
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
    );
  }
}

class _BannerImage extends StatelessWidget {
  final String pathOrUrl;
  const _BannerImage({required this.pathOrUrl});

  @override
  Widget build(BuildContext context) {
    if (pathOrUrl.startsWith('http')) {
      return Image.network(pathOrUrl, fit: BoxFit.cover);
    }
    if (pathOrUrl.isEmpty) {
      return Container(color: Colors.grey.shade900);
    }
    return Image.asset(pathOrUrl, fit: BoxFit.cover);
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  final Color border;
  const _Chip({
    required this.text,
    required this.bg,
    required this.fg,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 12,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color textPrimary;
  final Color textSecondary;
  final Color brand;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.textPrimary,
    required this.textSecondary,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: brand.withOpacity(0.14),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: brand),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  color: textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                style: AppTextStyles.body.copyWith(
                  color: textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
