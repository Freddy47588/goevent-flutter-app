import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'models/search_event_model.dart';
import 'widgets/search_result_tile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchC = TextEditingController();

  final List<SearchEventModel> _data = const [
    SearchEventModel(
      title: 'Satellite mega festival - 2022',
      dateLabel: 'THU 26 May, 09:00',
      imageAsset: '',
    ),
    SearchEventModel(
      title: 'Dance party at the top of the town - 2022',
      dateLabel: 'THU 26 May, 09:00',
      imageAsset: '',
    ),
    SearchEventModel(
      title: 'Party with friends at night - 2022',
      dateLabel: 'THU 26 May, 09:00',
      imageAsset: '',
    ),
    SearchEventModel(
      title: 'Satellite mega festival - 2022',
      dateLabel: 'THU 26 May, 09:00',
      imageAsset: '',
    ),
  ];

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? Colors.black : Colors.white;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final brand = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final keyword = _searchC.text.trim().toLowerCase();
    final results = _data.where((e) {
      if (keyword.isEmpty) return true;
      return e.title.toLowerCase().contains(keyword);
    }).toList();

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // =========================
            // SEARCH BAR + FILTER ICON
            // =========================
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchC,
                    onChanged: (_) => setState(() {}),
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
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: border),
                  ),
                  child: IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Filter (dummy)')),
                      );
                    },
                    icon: Icon(Icons.tune, color: textSecondary),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // =========================
            // MY CURRENT LOCATION BUTTON
            // =========================
            InkWell(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ambil lokasi (dummy)')),
                );
              },
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
                      Icon(Icons.place, color: brand),
                      const SizedBox(width: 10),
                      Text(
                        'My Current Location',
                        style: AppTextStyles.body.copyWith(
                          color: brand,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // =========================
            // RESULTS LIST
            // =========================
            ...results.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: SearchResultTile(event: e),
              ),
            ),

            if (results.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.lg),
                child: Center(
                  child: Text(
                    'Tidak ada hasil 😅',
                    style: AppTextStyles.body.copyWith(color: textSecondary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
