import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../events/models/event_filter.dart';

class SearchFilterSheet extends StatefulWidget {
  final EventFilter initial;
  final String currentCity;

  const SearchFilterSheet({
    super.key,
    required this.initial,
    required this.currentCity,
  });

  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  late EventFilter f;

  final _catOptions = const [
    'All',
    'Music',
    'Education',
    'Film',
    'Sports',
    'Art',
  ];

  // RangeSlider bounds
  static const double _sliderMin = 0;
  static const double _sliderMax = 6000000;

  @override
  void initState() {
    super.initState();
    f = widget.initial;
  }

  RangeValues _safeRangeValues() {
    final start = f.minPrice.clamp(_sliderMin, _sliderMax).toDouble();
    final end = f.maxPrice.clamp(_sliderMin, _sliderMax).toDouble();
    return start <= end ? RangeValues(start, end) : RangeValues(end, start);
  }

  void _applyRange(RangeValues v) {
    final a = v.start.round();
    final b = v.end.round();
    final minP = a <= b ? a : b;
    final maxP = a <= b ? b : a;

    setState(() {
      f = f.copyWith(
        minPrice: minP.clamp(_sliderMin.toInt(), _sliderMax.toInt()),
        maxPrice: maxP.clamp(_sliderMin.toInt(), _sliderMax.toInt()),
      );
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

    final safeValues = _safeRangeValues();

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

          // ===== Category =====
          Text(
            'Category',
            style: AppTextStyles.caption.copyWith(
              color: textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _catOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final label = _catOptions[i];
                final key = label.toLowerCase() == 'all'
                    ? ''
                    : label.toLowerCase();
                final active = f.category.trim().toLowerCase() == key;

                return InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => setState(() => f = f.copyWith(category: key)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: active ? brand : surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: border),
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: AppTextStyles.caption.copyWith(
                          color: active ? Colors.white : textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // ===== Scope =====
          Text(
            'Scope',
            style: AppTextStyles.caption.copyWith(
              color: textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: [
              _scopeChip(
                label: 'All',
                active: f.isGlobal == null,
                onTap: () => setState(() => f = f.copyWith(isGlobal: null)),
                brand: brand,
                border: border,
                surface: surface,
                textPrimary: textPrimary,
              ),
              _scopeChip(
                label: 'Local',
                active: f.isGlobal == false,
                onTap: () => setState(() => f = f.copyWith(isGlobal: false)),
                brand: brand,
                border: border,
                surface: surface,
                textPrimary: textPrimary,
              ),
              _scopeChip(
                label: 'Global',
                active: f.isGlobal == true,
                onTap: () => setState(() => f = f.copyWith(isGlobal: true)),
                brand: brand,
                border: border,
                surface: surface,
                textPrimary: textPrimary,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ===== Price =====
          Text(
            'Price',
            style: AppTextStyles.caption.copyWith(
              color: textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
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
                  'Rp ${safeValues.start.round()} - Rp ${safeValues.end.round()}',
                  style: AppTextStyles.body.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                RangeSlider(
                  min: _sliderMin,
                  max: _sliderMax,
                  divisions: 60,
                  values: safeValues,
                  onChanged: _applyRange,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ===== Switches =====
          Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: border),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: f.onlyTickets,
                  onChanged: (v) =>
                      setState(() => f = f.copyWith(onlyTickets: v)),
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
                Divider(height: 1, color: border),
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
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ===== Buttons =====
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => f = const EventFilter()),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: BorderSide(color: border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: Text(
                    'Reset',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, f),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brand,
                    minimumSize: const Size.fromHeight(48),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: Text(
                    'Apply',
                    style: AppTextStyles.body.copyWith(
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
    );
  }

  Widget _scopeChip({
    required String label,
    required bool active,
    required VoidCallback onTap,
    required Color brand,
    required Color border,
    required Color surface,
    required Color textPrimary,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? brand : surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: active ? Colors.white : textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
