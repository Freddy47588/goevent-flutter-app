import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_radius.dart';
import '../../core/widgets/gradient_button.dart';
import '../../routes/app_routes.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailC = TextEditingController();

  @override
  void dispose() {
    _emailC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final fillColor = isDark ? AppColors.darkSurface : Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? Colors.white : textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.sm),

              // Logo kecil (template-like)
              Image.asset(
                'assets/images/logo_splash.png',
                width: 70,
                height: 70,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'GoEvent',
                style: AppTextStyles.h2.copyWith(
                  color: isDark ? Colors.white : textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              Align(
                alignment: Alignment.centerLeft,
                child: Center(
                  child: Text(
                    'Lupa Password?',
                    style: AppTextStyles.h2.copyWith(
                      color: textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Masukkan email kamu. Nanti kami kirim link reset password.',
                  style: AppTextStyles.body.copyWith(
                    color: textSecondary,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Email input
              TextField(
                controller: _emailC,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email Address',
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: fillColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.darkPrimary
                          : AppColors.lightPrimary,
                      width: 1.4,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              GradientButton(
                text: 'Kirim Link Reset',
                onPressed: () {
                  final email = _emailC.text.trim();
                  if (email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Email wajib diisi.')),
                    );
                    return;
                  }

                  // Dummy success
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Link reset dikirim ke $email (dummy).'),
                    ),
                  );

                  // Balik ke Login (rapi)
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
