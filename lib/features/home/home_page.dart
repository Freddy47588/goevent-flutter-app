import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchC = TextEditingController();
  int _selectedCat = 0;
  int _bottomIndex = 0;

  // ====== Controller untuk slider Popular Now ======
  final PageController _popularCtrl = PageController(viewportFraction: 0.78);

  final List<_CategoryItem> _cats = const [
    _CategoryItem('Music', Icons.music_note),
    _CategoryItem('Education', Icons.school),
    _CategoryItem('Film', Icons.movie),
    _CategoryItem('Sports', Icons.sports_soccer),
    _CategoryItem('Art', Icons.brush),
  ];

  // NOTE: pakai placeholder gradient dulu (tanpa gambar asset) biar langsung jalan.
  final List<_UpcomingEvent> _upcoming = const [
    _UpcomingEvent('Satellite mega festival - 2023', 'New York'),
    _UpcomingEvent('Party with friends at night - 2023', 'California'),
    _UpcomingEvent('Festival event at kudasan - 2022', 'Miami'),
  ];

  final List<_PopularEvent> _popular = const [
    _PopularEvent(
      chip: 'Dance',
      title: 'Going to a Rock Concert',
      time: 'THU 26 May, 09:00 - FRI 27 May, 10:00',
      price: '\$30.00',
    ),
    _PopularEvent(
      chip: 'Music',
      title: 'Altopik Salom',
      time: 'SAT 28 May, 19:00 - SAT 28 May, 23:00',
      price: '\$25.00',
    ),
  ];

  final List<_RecommendEvent> _recommend = const [
    _RecommendEvent(
      'Dance party at the top of the town - 2022',
      'New York',
      '\$30.00',
    ),
    _RecommendEvent('Festival event at kudasan - 2022', 'California', 'Free'),
    _RecommendEvent('Party with friends at night - 2022', 'Miami', 'Free'),
    _RecommendEvent('Satellite mega festival - 2022', 'California', '\$30.00'),
  ];

  @override
  void dispose() {
    _searchC.dispose();
    _popularCtrl.dispose();
    super.dispose();
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

    return Scaffold(
      backgroundColor: bg,

      // ===== Bottom Nav (5 icon) =====
      bottomNavigationBar: _GoEventBottomBar(
        currentIndex: _bottomIndex,
        onChanged: (i) => setState(() => _bottomIndex = i),
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            110, // space untuk bottom bar
          ),
          children: [
            // =========================
            // Location + Bell
            // =========================
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location',
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
                        Text(
                          'Ahmedabad, Gujarat',
                          style: AppTextStyles.body.copyWith(
                            color: textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                _CircleIconButton(icon: Icons.notifications_none, onTap: () {}),
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
                    controller: _searchC,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
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
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: brand,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.tune, color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // =========================
            // Category chips (horizontal)
            // =========================
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _cats.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final selected = i == _selectedCat;

                  return InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => setState(() => _selectedCat = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: selected ? brand : surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: border),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _cats[i].icon,
                            size: 18,
                            color: selected ? Colors.white : textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _cats[i].label,
                            style: AppTextStyles.body.copyWith(
                              color: selected ? Colors.white : textPrimary,
                              fontWeight: FontWeight.w700,
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
            // Upcoming Events (SWIPE)
            // =========================
            _SectionHeader(title: 'Upcoming Events', onSeeAll: () {}),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _upcoming.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (context, i) {
                  return _UpcomingCard(
                    event: _upcoming[i],
                    brand: brand,
                    border: border,
                    surface: surface,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    isDark: isDark,
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // =========================
            // Popular Now (SLIDE LEFT-RIGHT)
            // =========================
            _SectionHeader(title: 'Popular Now', onSeeAll: () {}),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 260,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _popular.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (context, i) {
                  return SizedBox(
                    width: 260, // <- ukuran card, bisa kamu adjust
                    child: _PopularCard(
                      event: _popular[i],
                      brand: brand,
                      border: border,
                      surface: surface,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // =========================
            // Recommendations list
            // =========================
            _SectionHeader(title: 'Recommendations for you', onSeeAll: () {}),
            const SizedBox(height: AppSpacing.sm),
            ..._recommend.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _RecommendTile(
                  event: e,
                  brand: brand,
                  border: border,
                  surface: surface,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  isDark: isDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================
// Small components
// =========================

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

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border),
        ),
        child: Icon(icon, color: textPrimary),
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
        Text(
          title,
          style: AppTextStyles.h3.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: onSeeAll,
          child: Text(
            'See All',
            style: AppTextStyles.body.copyWith(
              color: brand,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

// =========================
// Cards
// =========================

class _UpcomingCard extends StatelessWidget {
  final _UpcomingEvent event;
  final Color brand;
  final Color border;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final bool isDark;

  const _UpcomingCard({
    required this.event,
    required this.brand,
    required this.border,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      height: 118, // ✅ naikkan sedikit biar aman
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              gradient: isDark
                  ? AppColors.darkGradient
                  : AppColors.lightGradient,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // ✅ Ganti jadi Expanded + Column rapih, TANPA Spacer
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.place_outlined, size: 14, color: textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                Align(
                  alignment: Alignment.bottomRight,
                  child: SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brand,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(
                        'Join',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PopularCard extends StatelessWidget {
  final _PopularEvent event;
  final Color brand;
  final Color border;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final bool isDark;

  const _PopularCard({
    required this.event,
    required this.brand,
    required this.border,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // image header
          Stack(
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.lg),
                    topRight: Radius.circular(AppRadius.lg),
                  ),
                  gradient: isDark
                      ? AppColors.darkGradient
                      : AppColors.lightGradient,
                ),
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
                    event.chip,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withOpacity(0.22)),
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          Padding(
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
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  event.time,
                  style: AppTextStyles.caption.copyWith(
                    color: textSecondary,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.local_activity_outlined, size: 16, color: brand),
                    const SizedBox(width: 6),
                    Text(
                      event.price,
                      style: AppTextStyles.body.copyWith(
                        color: brand,
                        fontWeight: FontWeight.w900,
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
  }
}

class _RecommendTile extends StatelessWidget {
  final _RecommendEvent event;
  final Color brand;
  final Color border;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final bool isDark;

  const _RecommendTile({
    required this.event,
    required this.brand,
    required this.border,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              gradient: isDark
                  ? AppColors.darkGradient
                  : AppColors.lightGradient,
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
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.place_outlined, size: 14, color: textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      event.location,
                      style: AppTextStyles.caption.copyWith(
                        color: textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
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
                        event.price,
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
    );
  }
}

class _GoEventBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const _GoEventBottomBar({
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final brand = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final idle = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final items = const [
      Icons.home_filled,
      Icons.search,
      Icons.favorite_border,
      Icons.confirmation_number_outlined,
      Icons.person_outline,
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: 74, // ✅ biar tebal & sesuai UI kit
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: border),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(items.length, (i) {
            final selected = i == currentIndex;

            return InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => onChanged(i),
              child: SizedBox(
                width: 54,
                height: 54,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // ✅ indikator aktif (dot kecil di bawah icon)
                    Positioned(
                      bottom: 8,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: selected ? 16 : 0,
                        height: selected ? 4 : 0,
                        decoration: BoxDecoration(
                          color: brand,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),

                    // icon
                    Icon(items[i], size: 26, color: selected ? brand : idle),
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

// =========================
// Dummy data classes
// =========================

class _CategoryItem {
  final String label;
  final IconData icon;
  const _CategoryItem(this.label, this.icon);
}

class _UpcomingEvent {
  final String title;
  final String location;
  const _UpcomingEvent(this.title, this.location);
}

class _PopularEvent {
  final String chip;
  final String title;
  final String time;
  final String price;
  const _PopularEvent({
    required this.chip,
    required this.title,
    required this.time,
    required this.price,
  });
}

class _RecommendEvent {
  final String title;
  final String location;
  final String price;
  const _RecommendEvent(this.title, this.location, this.price);
}
