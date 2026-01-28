import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/services/auth_service.dart';
import '../../routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/gradient_button.dart';

class SelectFavouritePage extends StatefulWidget {
  const SelectFavouritePage({super.key});

  @override
  State<SelectFavouritePage> createState() => _SelectFavouritePageState();
}

class _SelectFavouritePageState extends State<SelectFavouritePage> {
  final Set<String> _selected = {};
  bool _saving = false;

  // ✅ KATEGORI FIX
  static const kCategories = <String>[
    'Music',
    'Education',
    'Film',
    'Sports',
    'Art',
  ];

  Future<void> _finish() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih minimal 1 kategori')));
      return;
    }

    setState(() => _saving = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    await AuthService().saveFavouritesAndFinish(uid, _selected.toList());

    if (!mounted) return;
    setState(() => _saving = false);

    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose your favorite event',
                style: AppTextStyles.h2.copyWith(color: textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                'Get personalized event recommendations.',
                style: AppTextStyles.body.copyWith(color: textSecondary),
              ),

              const SizedBox(height: 24),

              /// ✅ CHIP GRID
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: kCategories.map((label) {
                  final selected = _selected.contains(label);
                  return _CategoryChip(
                    label: label,
                    selected: selected,
                    surface: surface,
                    border: border,
                    primary: primary,
                    textPrimary: textPrimary,
                    onTap: () {
                      setState(() {
                        selected
                            ? _selected.remove(label)
                            : _selected.add(label);
                      });
                    },
                  );
                }).toList(),
              ),

              const Spacer(),

              /// ✅ BUTTON PAKAI GRADIENT THEME
              GradientButton(
                text: _saving ? 'Saving...' : 'Finish',
                onPressed: _saving ? null : _finish,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color surface;
  final Color border;
  final Color primary;
  final Color textPrimary;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.surface,
    required this.border,
    required this.primary,
    required this.textPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? primary.withOpacity(0.12) : surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: selected ? primary : border, width: 1.2),
        ),
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: selected ? primary : textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
