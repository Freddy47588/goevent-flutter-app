import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goevent_app/features/profile_setup/pages/profile_page.dart';
import 'package:intl/intl.dart';

import '../../core/services/location_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

import '../search/search_page.dart';

// Events
import '../events/models/event_model.dart';
import '../events/repositories/event_repository.dart';
import '../events/pages/event_detail_page.dart';
import '../events/pages/events_list_page.dart';

import '../favourites/pages/favourite_page.dart';

import '../tickets/pages/tickets_page.dart';

import '../profile_setup/pages/profile_page.dart';

import '../../routes/app_routes.dart'; // sesuaikan path file kamu

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// ============================================================================
// STATE
// ============================================================================
class _HomePageState extends State<HomePage> {
  final _searchC = TextEditingController();

  int _selectedCat = 0;
  int _bottomIndex = 0;

  // Popular carousel
  final PageController _popularCtrl = PageController(viewportFraction: 0.80);

  // Firebase repo
  final _repo = EventRepository();

  // Location
  final _loc = LocationService();
  StreamSubscription<UserLocationData>? _locSub;
  UserLocationData? _userLoc;

  // Filter state
  EventFilter _filter = const EventFilter();

  final List<_CategoryItem> _cats = const [
    _CategoryItem('All', Icons.apps),
    _CategoryItem('Music', Icons.music_note),
    _CategoryItem('Education', Icons.school),
    _CategoryItem('Film', Icons.movie),
    _CategoryItem('Sports', Icons.sports_soccer),
    _CategoryItem('Art', Icons.brush),
  ];

  @override
  void initState() {
    super.initState();

    // start location realtime
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
    _popularCtrl.dispose();

    _locSub?.cancel();
    _loc.stop();
    _loc.dispose();

    super.dispose();
  }

  // ✅ FIX: chip category -> simpan ke filter dalam bentuk lowercase (key)
  void _applyCategoryFromChip(int index) {
    setState(() {
      _selectedCat = index;
      final label = _cats[index].label.trim();
      _filter = _filter.copyWith(
        category: (label.toLowerCase() == 'all') ? '' : label.toLowerCase(),
      );
    });
  }

  Future<void> _openFilterSheet() async {
    final res = await showModalBottomSheet<EventFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _HomeFilterSheet(initial: _filter, currentCity: _userLoc?.city ?? ''),
    );

    if (res != null) {
      setState(() {
        _filter = res;

        // sync chip selection
        final catKey = _filter.category.trim().toLowerCase();
        if (catKey.isEmpty) {
          _selectedCat = 0;
        } else {
          final idx = _cats.indexWhere(
            (c) => c.label.trim().toLowerCase() == catKey,
          );
          _selectedCat = idx >= 0 ? idx : 0;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _HomeTab(
        searchC: _searchC,
        selectedCat: _selectedCat,
        onCatChanged: _applyCategoryFromChip,
        onTapSearch: () => setState(() => _bottomIndex = 1),
        onTapFilter: _openFilterSheet,
        popularCtrl: _popularCtrl,
        cats: _cats,
        repo: _repo,
        filter: _filter,
        userLoc: _userLoc,
      ),
      const SearchPage(),
      const FavouritePage(),
      const TicketsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _bottomIndex, children: pages),
      ),
      bottomNavigationBar: GoEventFlatBottomBar(
        currentIndex: _bottomIndex,
        onChanged: (i) => setState(() => _bottomIndex = i),
      ),
    );
  }
}

// ============================================================================
// HOME TAB UI
// ============================================================================
class _HomeTab extends StatelessWidget {
  final TextEditingController searchC;
  final int selectedCat;
  final ValueChanged<int> onCatChanged;
  final VoidCallback onTapSearch;
  final VoidCallback onTapFilter;

  final PageController popularCtrl;
  final List<_CategoryItem> cats;

  final EventRepository repo;
  final EventFilter filter;
  final UserLocationData? userLoc;

  const _HomeTab({
    required this.searchC,
    required this.selectedCat,
    required this.onCatChanged,
    required this.onTapSearch,
    required this.onTapFilter,
    required this.popularCtrl,
    required this.cats,
    required this.repo,
    required this.filter,
    required this.userLoc,
  });

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

    final locationLabel = (userLoc == null)
        ? 'Getting location...'
        : userLoc!.city;

    final locationLine = (userLoc == null)
        ? 'Location'
        : 'Location • ${userLoc!.addressLine}';

    return Container(
      color: bg,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          130,
        ),
        children: [
          // =========================
          // Location + Bell
          // =========================
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locationLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.place, size: 18, color: brand),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            locationLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body.copyWith(
                              color: textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _CircleIconButton(
                icon: Icons.notifications_none,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.notifications),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // =========================
          // Search + Filter
          // =========================
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchC,
                  readOnly: true,
                  onTap: onTapSearch,
                  decoration: InputDecoration(
                    hintText: 'Search events, venues, artists...',
                    hintStyle: AppTextStyles.body.copyWith(
                      color: textSecondary.withOpacity(0.85),
                      fontWeight: FontWeight.w600,
                    ),
                    prefixIcon: Icon(Icons.search, color: textSecondary),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkSurface
                        : const Color(0xFFF6F7F9),
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
              SizedBox(
                width: 52,
                height: 52,
                child: Material(
                  color: brand,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    onTap: onTapFilter,
                    child: const Icon(Icons.tune, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // =========================
          // Category chips
          // =========================
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: cats.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final selected = i == selectedCat;

                return InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => onCatChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: selected ? brand : surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: border),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: brand.withOpacity(isDark ? 0.25 : 0.18),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          cats[i].icon,
                          size: 18,
                          color: selected ? Colors.white : textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          cats[i].label,
                          style: AppTextStyles.body.copyWith(
                            color: selected ? Colors.white : textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // =========================
          // FIRESTORE EVENTS
          // =========================
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: repo.watchEvents(limit: 80),
            builder: (context, snap) {
              if (snap.hasError) {
                return Text(
                  'Error: ${snap.error}',
                  style: AppTextStyles.body.copyWith(
                    color: textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                );
              }
              if (!snap.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              var events = snap.data!.docs.map(EventModel.fromDoc).toList();

              // ==========================================================
              // ✅ FILTER CLIENT-SIDE (AMAN TANPA INDEX)
              // ==========================================================

              // Category: pakai categoryKey (lowercase + trim)
              if (filter.category.trim().isNotEmpty) {
                final catKey = filter.category.trim().toLowerCase();
                events = events.where((e) => e.categoryKey == catKey).toList();
              }

              // Scope global/local
              if (filter.isGlobal != null) {
                events = events
                    .where((e) => e.isGlobal == filter.isGlobal)
                    .toList();
              }

              // Price range
              events = events
                  .where(
                    (e) =>
                        e.price >= filter.minPrice &&
                        e.price <= filter.maxPrice,
                  )
                  .toList();

              // Only tickets
              if (filter.onlyTickets) {
                events = events.where((e) => e.ticketAvailable).toList();
              }

              // Near me (by city string in locationName)
              if (filter.nearMe && (userLoc?.city ?? '').trim().isNotEmpty) {
                final city = userLoc!.city.trim().toLowerCase();
                events = events
                    .where((e) => e.locationName.toLowerCase().contains(city))
                    .toList();
              }

              // ==========================================================
              // Split sections (setelah filter)
              // ==========================================================
              final upcoming = events.take(6).toList();
              final popular = events
                  .where((e) => e.ticketAvailable)
                  .take(8)
                  .toList();
              final recommend = events.skip(2).take(10).toList();

              if (events.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Center(
                    child: Text(
                      'Event tidak ditemukan 😅\nCoba ubah kategori / filter.',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =========================
                  // Upcoming
                  // =========================
                  _SectionHeader(
                    title: 'Upcoming Events',
                    onSeeAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventsListPage(
                            title: 'Upcoming Events',
                            events: events,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 126,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: upcoming.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: AppSpacing.md),
                      itemBuilder: (context, i) {
                        final e = upcoming[i];
                        return _UpcomingCardFS(
                          event: e,
                          brand: brand,
                          border: border,
                          surface: surface,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isDark: isDark,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EventDetailPage(event: e),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // =========================
                  // Popular Now
                  // =========================
                  _SectionHeader(
                    title: 'Popular Now',
                    onSeeAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventsListPage(
                            title: 'Popular Now',
                            events: popular,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 292,
                    child: PageView.builder(
                      controller: popularCtrl,
                      itemCount: popular.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, i) {
                        final e = popular[i];
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.md),
                          child: _PopularCardFS(
                            event: e,
                            brand: brand,
                            border: border,
                            surface: surface,
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
                      },
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // =========================
                  // Recommendations
                  // =========================
                  _SectionHeader(
                    title: 'Recommendations for you',
                    onSeeAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventsListPage(
                            title: 'Recommendations',
                            events: recommend,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...recommend.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _RecommendTileFS(
                        event: e,
                        brand: brand,
                        border: border,
                        surface: surface,
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
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// UI small widgets
// ============================================================================
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    return Material(
      color: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(color: border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: textPrimary),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final brand = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.h3.copyWith(
              color: textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: onSeeAll,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Text(
              'See All',
              style: AppTextStyles.body.copyWith(
                color: brand,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Cards
// ============================================================================
class _UpcomingCardFS extends StatelessWidget {
  final EventModel event;
  final Color brand;
  final Color border;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final bool isDark;
  final VoidCallback onTap;

  const _UpcomingCardFS({
    required this.event,
    required this.brand,
    required this.border,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM • HH:mm', 'id_ID').format(event.startAt);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        width: 300,
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
                width: 78,
                height: 78,
                child: _image(event.imageAsset, brand, isDark),
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
                  const Spacer(),
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
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brand,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: Text(
                            'Open',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
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
}

class _PopularCardFS extends StatelessWidget {
  final EventModel event;
  final Color brand;
  final Color border;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final bool isDark;
  final VoidCallback onTap;

  const _PopularCardFS({
    required this.event,
    required this.brand,
    required this.border,
    required this.surface,
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
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: border),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: _image(event.imageAsset, brand, isDark),
                ),
                Positioned(
                  left: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white.withOpacity(0.22)),
                    ),
                    child: Text(
                      event.category.isEmpty ? 'Event' : event.category,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
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
                    const SizedBox(height: 8),
                    Text(
                      dateStr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: textSecondary,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.local_activity_outlined,
                          size: 16,
                          color: brand,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          priceStr,
                          style: AppTextStyles.body.copyWith(
                            color: brand,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          event.ticketAvailable
                              ? Icons.confirmation_num
                              : Icons.block,
                          color: event.ticketAvailable
                              ? Colors.green
                              : Colors.red,
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendTileFS extends StatelessWidget {
  final EventModel event;
  final Color brand;
  final Color border;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final bool isDark;
  final VoidCallback onTap;

  const _RecommendTileFS({
    required this.event,
    required this.brand,
    required this.border,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final priceStr = event.price <= 0 ? 'Free' : 'Rp ${event.price}';
    final dateStr = DateFormat(
      'dd MMM yyyy • HH:mm',
      'id_ID',
    ).format(event.startAt);

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
                width: 64,
                height: 64,
                child: _image(event.imageAsset, brand, isDark),
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
}

Widget _image(String pathOrUrl, Color brand, bool isDark) {
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

// ============================================================================
// Bottom bar
// ============================================================================
class GoEventFlatBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const GoEventFlatBottomBar({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? Colors.black : Colors.white;
    final activeColor = isDark
        ? Colors.white
        : const Color.fromRGBO(79, 172, 254, 1);
    final inactiveColor = isDark ? Colors.white54 : Colors.black54;

    final items = const [
      _FlatNavItem(Icons.home_outlined),
      _FlatNavItem(Icons.search),
      _FlatNavItem(Icons.favorite_border),
      _FlatNavItem(Icons.confirmation_number_outlined),
      _FlatNavItem(Icons.person_outline),
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: 64,
        color: bgColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final selected = index == currentIndex;

            return Expanded(
              child: InkWell(
                onTap: () => onChanged(index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: selected ? 20 : 0,
                      height: 3,
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: activeColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Icon(
                      items[index].icon,
                      size: 26,
                      color: selected ? activeColor : inactiveColor,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _FlatNavItem {
  final IconData icon;
  const _FlatNavItem(this.icon);
}

// ============================================================================
// Filter model
// ============================================================================
class EventFilter {
  final String category; // "" = all | disimpan lowercase untuk key
  final bool? isGlobal; // null = all
  final bool onlyTickets;
  final bool nearMe;
  final int minPrice;
  final int maxPrice;

  const EventFilter({
    this.category = '',
    this.isGlobal,
    this.onlyTickets = false,
    this.nearMe = false,
    this.minPrice = 0,
    this.maxPrice = 6000000,
  });

  EventFilter copyWith({
    String? category,
    bool? isGlobal,
    bool? onlyTickets,
    bool? nearMe,
    int? minPrice,
    int? maxPrice,
  }) {
    return EventFilter(
      category: category ?? this.category,
      isGlobal: isGlobal ?? this.isGlobal,
      onlyTickets: onlyTickets ?? this.onlyTickets,
      nearMe: nearMe ?? this.nearMe,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }
}

// ============================================================================
// Filter Sheet
// ============================================================================
class _HomeFilterSheet extends StatefulWidget {
  final EventFilter initial;
  final String currentCity;
  const _HomeFilterSheet({required this.initial, required this.currentCity});

  @override
  State<_HomeFilterSheet> createState() => _HomeFilterSheetState();
}

class _HomeFilterSheetState extends State<_HomeFilterSheet> {
  late EventFilter f;

  @override
  void initState() {
    super.initState();
    f = widget.initial;
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

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: textSecondary.withOpacity(0.25),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 14),

          Text(
            'Filter',
            style: AppTextStyles.h3.copyWith(
              color: textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),

          Text(
            'Scope',
            style: AppTextStyles.caption.copyWith(
              color: textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _chip(
                context,
                'All',
                f.isGlobal == null,
                () => setState(() => f = f.copyWith(isGlobal: null)),
              ),
              _chip(
                context,
                'Local',
                f.isGlobal == false,
                () => setState(() => f = f.copyWith(isGlobal: false)),
              ),
              _chip(
                context,
                'Global',
                f.isGlobal == true,
                () => setState(() => f = f.copyWith(isGlobal: true)),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            'Price',
            style: AppTextStyles.caption.copyWith(
              color: textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rp ${f.minPrice} - Rp ${f.maxPrice}',
                  style: AppTextStyles.body.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                RangeSlider(
                  min: 0,
                  max: 6000000,
                  divisions: 60,
                  values: RangeValues(
                    f.minPrice.toDouble(),
                    f.maxPrice.toDouble(),
                  ),
                  onChanged: (v) => setState(() {
                    f = f.copyWith(
                      minPrice: v.start.round(),
                      maxPrice: v.end.round(),
                    );
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          SwitchListTile(
            value: f.onlyTickets,
            onChanged: (v) => setState(() => f = f.copyWith(onlyTickets: v)),
            activeThumbColor: brand,
            title: Text(
              'Only ticket available',
              style: AppTextStyles.body.copyWith(
                color: textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            subtitle: Text(
              'Tampilkan event yang bisa dibeli',
              style: AppTextStyles.caption.copyWith(color: textSecondary),
            ),
          ),

          SwitchListTile(
            value: f.nearMe,
            onChanged: (v) => setState(() => f = f.copyWith(nearMe: v)),
            activeThumbColor: brand,
            title: Text(
              'Near me',
              style: AppTextStyles.body.copyWith(
                color: textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            subtitle: Text(
              widget.currentCity.isEmpty
                  ? 'Butuh lokasi aktif'
                  : 'Filter by city: ${widget.currentCity}',
              style: AppTextStyles.caption.copyWith(color: textSecondary),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => f = const EventFilter()),
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: brand),
                  onPressed: () => Navigator.pop(context, f),
                  child: const Text(
                    'Apply',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(
    BuildContext context,
    String text,
    bool active,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final brand = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? brand : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: active ? Colors.white : textPrimary,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Placeholder
// ============================================================================
class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    return Center(
      child: Text(
        '$title (dummy)',
        style: AppTextStyles.h3.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CategoryItem {
  final String label;
  final IconData icon;
  const _CategoryItem(this.label, this.icon);
}
