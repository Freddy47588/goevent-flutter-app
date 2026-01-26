import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_radius.dart';
import '../../core/widgets/gradient_button.dart';
import '../../routes/app_routes.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final _confirmC = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _passC.dispose();
    _confirmC.dispose();
    super.dispose();
  }

  Future<void> _doSignup() async {
    final name = _nameC.text.trim();
    final email = _emailC.text.trim();
    final pass = _passC.text;
    final confirm = _confirmC.text;

    if (name.isEmpty || email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua field wajib diisi.")));
      return;
    }
    if (pass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Konfirmasi password tidak sama.")),
      );
      return;
    }
    if (pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password minimal 6 karakter.")),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );

      // opsional: set displayName
      await cred.user?.updateDisplayName(name);

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'email-already-in-use' => 'Email sudah terdaftar.',
        'invalid-email' => 'Format email tidak valid.',
        'weak-password' => 'Password terlalu lemah.',
        _ => e.message ?? 'Register gagal.',
      };

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Register gagal: $e")));
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

    InputDecoration fieldStyle({
      required String hint,
      required IconData icon,
      Widget? suffix,
    }) {
      return InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
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
          borderSide: BorderSide(color: textPrimary.withOpacity(0.6)),
        ),
      );
    }

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
                'Buat Akun',
                style: AppTextStyles.h2.copyWith(
                  color: isDark ? Colors.white : textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Daftar untuk melanjutkan',
                style: AppTextStyles.body.copyWith(color: textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),

              TextField(
                controller: _nameC,
                decoration: fieldStyle(
                  hint: 'Nama',
                  icon: Icons.person_outline,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              TextField(
                controller: _emailC,
                keyboardType: TextInputType.emailAddress,
                decoration: fieldStyle(
                  hint: 'Email',
                  icon: Icons.email_outlined,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              TextField(
                controller: _passC,
                obscureText: _obscure1,
                decoration: fieldStyle(
                  hint: 'Password',
                  icon: Icons.lock_outline,
                  suffix: IconButton(
                    onPressed: () => setState(() => _obscure1 = !_obscure1),
                    icon: Icon(
                      _obscure1 ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              TextField(
                controller: _confirmC,
                obscureText: _obscure2,
                decoration: fieldStyle(
                  hint: 'Konfirmasi Password',
                  icon: Icons.lock_outline,
                  suffix: IconButton(
                    onPressed: () => setState(() => _obscure2 = !_obscure2),
                    icon: Icon(
                      _obscure2 ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              GradientButton(
                text: _loading ? 'Loading...' : 'Daftar',
                onPressed: _loading ? null : _doSignup,
              ),

              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: _loading ? null : () => Navigator.pop(context),
                child: const Text('Sudah punya akun? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
