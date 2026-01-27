import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../events/models/event_model.dart';
import '../../events/pages/event_detail_page.dart';

class FavouritePage extends StatelessWidget {
  const FavouritePage({super.key});

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

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ===== Header (judul Favourite) =====
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                8,
              ),
              child: Center(
                child: Text(
                  'Favourite',
                  style: AppTextStyles.h3.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),

            // ===== Content =====
            Expanded(
              child: user == null
                  ? Center(
                      child: Text(
                        'Kamu belum login.',
                        style: AppTextStyles.body.copyWith(
                          color: textSecondary,
                        ),
                      ),
                    )
                  : _FavouriteBody(
                      userId: user.uid,
                      bg: bg,
                      surface: surface,
                      border: border,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final String pathOrUrl;
  const _Thumb({required this.pathOrUrl});

  @override
  Widget build(BuildContext context) {
    const w = 64.0;
    const h = 64.0;

    if (pathOrUrl.startsWith('http')) {
      return Image.network(pathOrUrl, width: w, height: h, fit: BoxFit.cover);
    }
    if (pathOrUrl.isEmpty) {
      return Container(width: w, height: h, color: Colors.grey.shade300);
    }
    return Image.asset(pathOrUrl, width: w, height: h, fit: BoxFit.cover);
  }
}

class _PricePill extends StatelessWidget {
  final int price;
  const _PricePill({required this.price});

  @override
  Widget build(BuildContext context) {
    final isFree = price <= 0;

    final label = isFree
        ? 'Free'
        : NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 0,
          ).format(price);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isFree ? const Color(0xFFE8FFF3) : const Color(0xFFFFEDF4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: isFree ? const Color(0xFF1F9254) : const Color(0xFFD81B60),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Color textPrimary;
  final Color textSecondary;
  final String? subtitle;

  const _EmptyState({
    required this.textPrimary,
    required this.textSecondary,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 48, color: textSecondary),
            const SizedBox(height: 12),
            Text(
              'Belum ada Favourite',
              style: AppTextStyles.h3.copyWith(
                color: textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle ?? 'Tambahkan kategori favorit agar muncul di sini.',
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

class _FavouriteBody extends StatelessWidget {
  final String userId;
  final Color bg;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;

  const _FavouriteBody({
    required this.userId,
    required this.bg,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, userSnap) {
        if (userSnap.hasError) {
          return Center(
            child: Text(
              'Gagal load user: ${userSnap.error}',
              style: AppTextStyles.body.copyWith(color: textSecondary),
            ),
          );
        }
        if (!userSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = userSnap.data!.data() ?? {};
        final favList = (userData['favourites'] as List?) ?? const [];

        final categories = favList
            .map((e) => (e ?? '').toString().trim())
            .where((s) => s.isNotEmpty)
            .toList();

        if (categories.isEmpty) {
          return _EmptyState(
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          );
        }

        final catsLimited = categories.take(10).toList();

        // ✅ versi tanpa orderBy (biar ga perlu index), lalu sorting di client
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('events')
              .where('category', whereIn: catsLimited)
              .snapshots(),
          builder: (context, evSnap) {
            if (evSnap.hasError) {
              return Center(
                child: Text(
                  'Gagal load favourites: ${evSnap.error}',
                  style: AppTextStyles.body.copyWith(color: textSecondary),
                ),
              );
            }
            if (!evSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = evSnap.data!.docs;
            if (docs.isEmpty) {
              return _EmptyState(
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                subtitle: 'Tidak ada event untuk favourites kamu.',
              );
            }

            final events = docs.map((d) => EventModel.fromDoc(d)).toList()
              ..sort((a, b) => a.startAt.compareTo(b.startAt));

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                6,
                AppSpacing.md,
                110,
              ),
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final e = events[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventDetailPage(event: e),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: border),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: _Thumb(pathOrUrl: e.imageAsset),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.title,
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
                                    Icons.place,
                                    size: 16,
                                    color: textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      e.locationName,
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
                        const SizedBox(width: 10),
                        _PricePill(price: e.price),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
