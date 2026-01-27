import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/services/location_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

import '../events/models/event_model.dart';
import '../events/models/event_filter.dart';
import '../events/repositories/event_repository.dart';
import '../events/pages/event_detail_page.dart';

import 'filter/search_filter_sheet.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchC = TextEditingController();
  final _repo = EventRepository();
  final _loc = LocationService();

  StreamSubscription<UserLocationData>? _locSub;
  UserLocationData? _userLoc;

  EventFilter _filter = const EventFilter();

  @override
  void initState() {
    super.initState();
    _loc
        .start()
        .then((_) {
          _locSub = _loc.stream.listen((d) {
            if (!mounted) return;
            setState(() => _userLoc = d);
          });
        })
        .catchError((_) {});
  }

  @override
  void dispose() {
    _searchC.dispose();
    _locSub?.cancel();
    _loc.stop();
    _loc.dispose();
    super.dispose();
  }

  bool get _hasActiveFilter {
    final f = _filter;
    return (f.category.trim().isNotEmpty) ||
        (f.isGlobal != null) ||
        f.onlyTickets ||
        f.nearMe ||
        f.minPrice > 0 ||
        f.maxPrice < 6000000;
  }

  Future<void> _openFilterSheet() async {
    final res = await showModalBottomSheet<EventFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SearchFilterSheet(
        initial: _filter,
        currentCity: _userLoc?.city ?? '',
      ),
    );

    if (res != null) {
      setState(() => _filter = res);
    }
  }

  void _applyNearMeQuick() {
    if ((_userLoc?.city ?? '').trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi belum siap. Coba tunggu sebentar…'),
        ),
      );
      return;
    }
    setState(() {
      _filter = _filter.copyWith(nearMe: true);
    });
  }

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

    final keyword = _searchC.text.trim().toLowerCase();
    final city = (_userLoc?.city ?? '').trim().toLowerCase();

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // =========================
            // SEARCH BAR + FILTER BUTTON
            // =========================
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchC,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search events, venues...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: keyword.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchC.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close),
                            ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkSurface
                          : const Color(0xFFF7F7F7),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: BorderSide(color: border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        borderSide: BorderSide(color: brand, width: 1.4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),

                // Filter button (rapi + badge kalau aktif)
                SizedBox(
                  width: 52,
                  height: 52,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Material(
                          color: surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            side: BorderSide(color: border),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            onTap: _openFilterSheet,
                            child: Icon(Icons.tune, color: textSecondary),
                          ),
                        ),
                      ),
                      if (_hasActiveFilter)
                        Positioned(
                          right: 10,
                          top: 10,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: brand,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // =========================
            // LOCATION CARD
            // =========================
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: border),
              ),
              child: Row(
                children: [
                  Icon(Icons.place, color: brand),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _userLoc == null
                          ? 'Getting your location...'
                          : '${_userLoc!.city} • ${_userLoc!.addressLine}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // =========================
            // QUICK BUTTON: MY CURRENT LOCATION
            // =========================
            InkWell(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              onTap: _applyNearMeQuick,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  gradient: LinearGradient(
                    colors: [brand.withOpacity(0.10), brand.withOpacity(0.20)],
                  ),
                  border: Border.all(color: brand.withOpacity(0.25)),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.my_location, color: brand),
                      const SizedBox(width: 10),
                      Text(
                        'My Current Location',
                        style: AppTextStyles.body.copyWith(
                          color: brand,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // =========================
            // RESULTS (FIRESTORE)
            // =========================
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _repo.watchEvents(limit: 120),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Text(
                    'Error: ${snap.error}',
                    style: AppTextStyles.body.copyWith(color: textSecondary),
                  );
                }
                if (!snap.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(28),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                var events = snap.data!.docs.map(EventModel.fromDoc).toList();

                // ===== Keyword filter =====
                if (keyword.isNotEmpty) {
                  events = events.where((e) {
                    final t = e.title.toLowerCase();
                    final l = e.locationName.toLowerCase();
                    return t.contains(keyword) || l.contains(keyword);
                  }).toList();
                }

                // ===== Category filter =====
                if (_filter.category.trim().isNotEmpty) {
                  final catKey = _filter.category.trim().toLowerCase();
                  events = events
                      .where((e) => e.categoryKey == catKey)
                      .toList();
                }

                // ===== Scope filter =====
                if (_filter.isGlobal != null) {
                  events = events
                      .where((e) => e.isGlobal == _filter.isGlobal)
                      .toList();
                }

                // ===== Price range =====
                events = events
                    .where(
                      (e) =>
                          e.price >= _filter.minPrice &&
                          e.price <= _filter.maxPrice,
                    )
                    .toList();

                // ===== Tickets only =====
                if (_filter.onlyTickets) {
                  events = events.where((e) => e.ticketAvailable).toList();
                }

                // ===== Near me =====
                if (_filter.nearMe && city.isNotEmpty) {
                  events = events
                      .where((e) => e.locationName.toLowerCase().contains(city))
                      .toList();
                }

                // Sort by soonest
                events.sort((a, b) => a.startAt.compareTo(b.startAt));

                if (events.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: Center(
                      child: Text(
                        'Tidak ada hasil 😅\nCoba ubah keyword / filter.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          color: textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: List.generate(events.length, (i) {
                    final e = events[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _SearchResultTile(
                        event: e,
                        surface: surface,
                        border: border,
                        brand: brand,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventDetailPage(event: e),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// RESULT TILE
// ============================================================================
class _SearchResultTile extends StatelessWidget {
  final EventModel event;
  final Color surface;
  final Color border;
  final Color brand;
  final Color textPrimary;
  final Color textSecondary;
  final bool isDark;
  final VoidCallback onTap;

  const _SearchResultTile({
    required this.event,
    required this.surface,
    required this.border,
    required this.brand,
    required this.textPrimary,
    required this.textSecondary,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat(
      'EEE, dd MMM • HH:mm',
      'id_ID',
    ).format(event.startAt);
    final priceStr = event.price <= 0 ? 'Free' : 'Rp ${event.price}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: SizedBox(
                width: 62,
                height: 62,
                child: _img(event.imageAsset, brand, isDark),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
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
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dateStr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 14,
                        color: textSecondary,
                      ),
                      const SizedBox(width: 4),
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
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: brand.withOpacity(isDark ? 0.18 : 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          priceStr,
                          style: AppTextStyles.caption.copyWith(
                            color: brand,
                            fontWeight: FontWeight.w900,
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
    );
  }

  Widget _img(String pathOrUrl, Color brand, bool isDark) {
    if (pathOrUrl.startsWith('http')) {
      return Image.network(pathOrUrl, fit: BoxFit.cover);
    }
    if (pathOrUrl.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkGradient : AppColors.lightGradient,
        ),
      );
    }
    return Image.asset(pathOrUrl, fit: BoxFit.cover);
  }
}
