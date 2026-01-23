import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingSlide extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;

  const OnboardingSlide({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        const SizedBox(height: AppSpacing.lg),

        // ===== IMAGE (besar, seperti template) =====
        Expanded(
          child: Center(child: Image.asset(imagePath, fit: BoxFit.contain)),
        ),

        const SizedBox(height: AppSpacing.lg),

        // ===== TITLE =====
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.h2.copyWith(
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // ===== SUBTITLE =====
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              height: 1.5,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
