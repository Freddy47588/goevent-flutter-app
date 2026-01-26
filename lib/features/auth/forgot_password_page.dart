import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_radius.dart';
import '../../core/widgets/gradient_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailC = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailC.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    final email = _emailC.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Email wajib diisi.")));
      return;
    }

    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Link reset password sudah dikirim ke email."),
        ),
      );
      Navigator.pop(context); // balik ke login
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'user-not-found' => 'Email tidak terdaftar.',
        'invalid-email' => 'Format email tidak valid.',
        _ => e.message ?? 'Gagal kirim reset password.',
      };
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
          onPressed: _loading ? null : () => Navigator.pop(context),
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
            children: [
              Image.asset(
                'assets/images/logo_splash.png',
                width: 70,
                height: 70,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Lupa Password',
                style: AppTextStyles.h2.copyWith(
                  color: isDark ? Colors.white : textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Masukkan email untuk reset password',
                style: AppTextStyles.body.copyWith(color: textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),

              TextField(
                controller: _emailC,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: fillColor,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: BorderSide(color: textPrimary.withOpacity(0.6)),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
              GradientButton(
                text: _loading ? 'Loading...' : 'Kirim Link Reset',
                onPressed: _loading ? null : _sendReset,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
