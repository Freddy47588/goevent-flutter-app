import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _passC.dispose();
    _confirmC.dispose();
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
          borderSide: BorderSide(
            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
            width: 1.4,
          ),
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

              // =========================
              // LOGO + APP NAME
              // =========================
              Image.asset(
                'assets/images/logo_splash.png',
                width: 86,
                height: 86,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'GoEvent',
                style: AppTextStyles.h2.copyWith(
                  color: isDark ? Colors.white : textPrimary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // =========================
              // TITLE
              // =========================
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Create Account',
                  style: AppTextStyles.h2.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Buat akun baru untuk mulai booking event.',
                style: AppTextStyles.body.copyWith(color: textSecondary),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xl),

              // =========================
              // FULL NAME
              // =========================
              TextField(
                controller: _nameC,
                decoration: fieldStyle(
                  hint: 'Full Name',
                  icon: Icons.person_outline,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // =========================
              // EMAIL
              // =========================
              TextField(
                controller: _emailC,
                decoration: fieldStyle(
                  hint: 'Email Address',
                  icon: Icons.email_outlined,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // =========================
              // PASSWORD
              // =========================
              TextField(
                controller: _passC,
                obscureText: _obscure1,
                decoration: fieldStyle(
                  hint: 'Password',
                  icon: Icons.lock_outline,
                  suffix: IconButton(
                    onPressed: () => setState(() => _obscure1 = !_obscure1),
                    icon: Icon(
                      _obscure1 ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // =========================
              // CONFIRM PASSWORD
              // =========================
              TextField(
                controller: _confirmC,
                obscureText: _obscure2,
                decoration: fieldStyle(
                  hint: 'Confirm Password',
                  icon: Icons.lock_outline,
                  suffix: IconButton(
                    onPressed: () => setState(() => _obscure2 = !_obscure2),
                    icon: Icon(
                      _obscure2 ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // =========================
              // SIGNUP BUTTON
              // =========================
              GradientButton(
                text: 'Signup',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Signup (dummy)')),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // =========================
              // OR DIVIDER
              // =========================
              Row(
                children: [
                  Expanded(child: Divider(color: borderColor)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Or',
                      style: AppTextStyles.body.copyWith(color: textSecondary),
                    ),
                  ),
                  Expanded(child: Divider(color: borderColor)),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // =========================
              // SOCIAL BUTTONS
              // =========================
              _SocialButton(
                text: 'Signup with Facebook',
                icon: const Icon(Icons.facebook, color: Color(0xFF1877F2)),
                onPressed: () {},
              ),
              const SizedBox(height: AppSpacing.sm),
              _SocialButton(
                text: 'Signup with Google',
                icon: Image.asset(
                  'assets/icons/google.png',
                  width: 22,
                  height: 22,
                ),
                onPressed: () {},
              ),

              const SizedBox(height: AppSpacing.xl),

              // =========================
              // BACK TO LOGIN
              // =========================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: AppTextStyles.body.copyWith(color: textSecondary),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    },
                    child: Text(
                      "Login",
                      style: AppTextStyles.body.copyWith(
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.lightPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String text;
  final Widget icon;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final fillColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        backgroundColor: fillColor,
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 10),
          Text(
            text,
            style: AppTextStyles.body.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
