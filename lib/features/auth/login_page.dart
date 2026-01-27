import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goevent_app/routes/app_routes.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_radius.dart';
import '../../core/widgets/gradient_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userC = TextEditingController(); // dipakai sebagai EMAIL
  final _passC = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _userC.dispose();
    _passC.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    final email = _userC.text.trim();
    final pass = _passC.text;

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email & password wajib diisi.")),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );

      final uid = cred.user!.uid;

      // ✅ cek / buat doc user
      final users = FirebaseFirestore.instance.collection('users');
      final docRef = users.doc(uid);
      final snap = await docRef.get();

      bool complete = false;

      if (!snap.exists) {
        // user lama yang belum punya dokumen profile
        await docRef.set({
          'uid': uid,
          'email': cred.user!.email,
          'name': cred.user!.displayName,
          'photoUrl': cred.user!.photoURL,
          'favourites': <String>[],
          'isProfileComplete': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        complete = false;
      } else {
        complete = (snap.data()?['isProfileComplete'] == true);
      }

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        complete ? AppRoutes.home : AppRoutes.createUsername,
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'user-not-found' => 'Akun tidak ditemukan.',
        'wrong-password' => 'Password salah.',
        'invalid-email' => 'Format email tidak valid.',
        'too-many-requests' => 'Terlalu banyak percobaan. Coba lagi nanti.',
        _ => e.message ?? 'Login gagal.',
      };

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login gagal: $e")));
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Image.asset(
                'assets/images/logo_splash.png',
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'GoEvent',
                style: AppTextStyles.h2.copyWith(
                  color: isDark ? Colors.white : textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Login untuk melanjutkan',
                style: AppTextStyles.body.copyWith(color: textSecondary),
              ),

              const SizedBox(height: AppSpacing.lg),

              TextField(
                controller: _userC,
                keyboardType: TextInputType.emailAddress,
                decoration: fieldStyle(
                  hint: 'Email',
                  icon: Icons.email_outlined,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              TextField(
                controller: _passC,
                obscureText: _obscure,
                decoration: fieldStyle(
                  hint: 'Password',
                  icon: Icons.lock_outline,
                  suffix: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _loading
                      ? null
                      : () => Navigator.pushNamed(
                          context,
                          AppRoutes.forgotPassword,
                        ),
                  child: const Text('Lupa password?'),
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              GradientButton(
                text: _loading ? 'Loading...' : 'Login',
                onPressed: _loading ? null : _doLogin,
              ),

              const SizedBox(height: AppSpacing.md),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Belum punya akun? ',
                    style: AppTextStyles.body.copyWith(color: textSecondary),
                  ),
                  GestureDetector(
                    onTap: _loading
                        ? null
                        : () => Navigator.pushNamed(context, AppRoutes.signup),
                    child: Text(
                      'Daftar',
                      style: AppTextStyles.body.copyWith(
                        color: isDark ? Colors.white : textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
