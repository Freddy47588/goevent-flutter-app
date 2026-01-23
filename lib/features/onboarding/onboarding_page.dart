import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/widgets/gradient_button.dart';
import '../../routes/app_routes.dart';
import 'widgets/onboarding_slide.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  final List<_OnboardData> _slides = const [
    _OnboardData(
      imagePath: 'assets/images/onboarding/onboarding_1.png',
      title: 'Temukan event seru',
      subtitle: 'Jelajahi konser, seminar, dan event komunitas yang lagi hype.',
    ),
    _OnboardData(
      imagePath: 'assets/images/onboarding/onboarding_2.png',
      title: 'Booking tiket cepat',
      subtitle: 'Pilih event, tentukan tiket, lalu bayar. Semuanya simpel.',
    ),
    _OnboardData(
      imagePath: 'assets/images/onboarding/onboarding_3.png',
      title: 'Masuk & nikmati acara',
      subtitle: 'Simpan e-ticket kamu, scan QR, dan langsung gas ke venue!',
    ),
  ];

  void _next() {
    final last = _slides.length - 1;
    if (_index < last) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              // ===== SLIDES =====
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    final s = _slides[i];
                    return OnboardingSlide(
                      imagePath: s.imagePath,
                      title: s.title,
                      subtitle: s.subtitle,
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ===== INDICATOR + SKIP =====
              Row(
                children: [
                  _Dots(count: _slides.length, index: _index),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.login,
                    ),
                    child: Text(
                      'Lewati',
                      style: AppTextStyles.body.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // ===== BUTTON NEXT / START =====
              GradientButton(
                text: _index == _slides.length - 1 ? 'Mulai' : 'Lanjut',
                onPressed: _next,
              ),

              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardData {
  final String imagePath;
  final String title;
  final String subtitle;

  const _OnboardData({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });
}

class _Dots extends StatelessWidget {
  final int count;
  final int index;

  const _Dots({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final inactive = isDark
        ? AppColors.darkTextSecondary.withOpacity(0.35)
        : AppColors.lightTextSecondary.withOpacity(0.35);

    return Row(
      children: List.generate(count, (i) {
        final active = i == index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.only(right: 8),
          height: 8,
          width: active ? 22 : 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            color: active
                ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                : inactive,
          ),
        );
      }),
    );
  }
}
