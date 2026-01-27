import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../routes/app_routes.dart';
import 'privacy_security_page.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Kalau AppColors kamu beda namanya, cukup edit mapping warna di sini.
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final divider = isDark ? AppColors.darkBorder : const Color(0xFFE8E8E8);
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final brand = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
          boxShadow: const [
            BoxShadow(
              blurRadius: 18,
              offset: Offset(0, -8),
              color: Color(0x12000000),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // grab handle
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 14),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Settings',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Divider(color: divider),

            // ===== Theme =====
            ValueListenableBuilder<ThemeMode>(
              valueListenable: ThemeController.instance.notifier,
              builder: (context, mode, _) {
                return _SettingTile(
                  icon: Icons.color_lens_outlined,
                  title: 'Theme',
                  subtitle: _modeLabel(mode),
                  iconColor: brand,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  divider: divider,
                  onTap: () =>
                      _openThemePicker(context, mode, brand, bg, textPrimary),
                );
              },
            ),

            // ===== Notifications (opsional - placeholder) =====
            _SettingTile(
              icon: Icons.notifications_none_outlined,
              title: 'Notifications',
              subtitle: 'Event reminders & booking updates',
              iconColor: brand,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              divider: divider,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.notifications);
              },
            ),

            // ===== Language (opsional - placeholder) =====
            _SettingTile(
              icon: Icons.language_outlined,
              title: 'Language',
              subtitle: 'Indonesia / English',
              iconColor: brand,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              divider: divider,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Coming soon: language settings'),
                  ),
                );
              },
            ),

            _SettingTile(
              icon: Icons.lock_outline,
              title: 'Privacy & Security',
              subtitle: 'Change password & delete account',
              iconColor: brand,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              divider: divider,
              onTap: () {
                Navigator.pop(context); // tutup SettingsSheet
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrivacySecurityPage(),
                  ),
                );
              },
            ),

            // ===== About GoEvent =====
            _SettingTile(
              icon: Icons.info_outline,
              title: 'About GoEvent',
              subtitle: 'App info & version',
              iconColor: brand,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              divider: divider,
              onTap: () => _showAbout(
                context,
                brand,
                textPrimary,
                textSecondary,
                divider,
              ),
            ),

            const SizedBox(height: 6),
            Divider(color: divider),
            const SizedBox(height: 6),

            // ===== Logout (destructive) =====
            _SettingTile(
              icon: Icons.logout_rounded,
              title: 'Logout',
              subtitle: 'Sign out from your account',
              iconColor: const Color(0xFFD32F2F),
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              divider: divider,
              showDivider: false,
              onTap: () => _confirmLogout(context),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static String _modeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  static Future<void> _openThemePicker(
    BuildContext context,
    ThemeMode current,
    Color brand,
    Color bg,
    Color textPrimary,
  ) async {
    final picked = await showModalBottomSheet<ThemeMode>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Choose Theme',
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _ThemeRadio(
                  title: 'System',
                  value: ThemeMode.system,
                  group: current,
                  brand: brand,
                  onPick: (v) => Navigator.pop(context, v),
                ),
                _ThemeRadio(
                  title: 'Light',
                  value: ThemeMode.light,
                  group: current,
                  brand: brand,
                  onPick: (v) => Navigator.pop(context, v),
                ),
                _ThemeRadio(
                  title: 'Dark',
                  value: ThemeMode.dark,
                  group: current,
                  brand: brand,
                  onPick: (v) => Navigator.pop(context, v),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (picked != null) {
      await ThemeController.instance.setTheme(picked);
      if (context.mounted) Navigator.pop(context); // tutup sheet Settings juga
    }
  }

  static Future<void> _showAbout(
    BuildContext context,
    Color brand,
    Color textPrimary,
    Color textSecondary,
    Color divider,
  ) async {
    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          title: Row(
            children: [
              Icon(Icons.event_available_rounded, color: brand),
              const SizedBox(width: 10),
              Text(
                'GoEvent',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GoEvent is an event discovery & ticketing app.',
                style: AppTextStyles.body.copyWith(color: textSecondary),
              ),
              const SizedBox(height: 10),
              Divider(color: divider),
              const SizedBox(height: 8),
              _AboutRow(label: 'Version', value: '1.0.0'),
              const SizedBox(height: 6),
              _AboutRow(label: 'Build', value: 'GoEventAPP'),
              const SizedBox(height: 6),
              _AboutRow(label: 'Developer', value: 'GoEvent Team'),
              const SizedBox(height: 6),
              Text(
                '© ${DateTime.now().year} GoEvent',
                style: AppTextStyles.caption.copyWith(color: textSecondary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: TextStyle(color: brand, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    // Tutup sheet settings dulu biar dialog tampil rapi
    Navigator.pop(context);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin mau logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    // ✅ Logout Firebase
    await FirebaseAuth.instance.signOut();
    await Future.delayed(const Duration(milliseconds: 200));

    if (!context.mounted) return;

    // ✅ Pindah ke login + bersihkan stack
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login', // pastikan route ini ada di AppRoutes
      (route) => false,
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color divider;
  final VoidCallback onTap;
  final bool showDivider;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.divider,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final tile = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black38),
          ],
        ),
      ),
    );

    return Column(
      children: [
        tile,
        if (showDivider) Divider(color: divider),
      ],
    );
  }
}

class _ThemeRadio extends StatelessWidget {
  final String title;
  final ThemeMode value;
  final ThemeMode group;
  final Color brand;
  final ValueChanged<ThemeMode> onPick;

  const _ThemeRadio({
    required this.title,
    required this.value,
    required this.group,
    required this.brand,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<ThemeMode>(
      value: value,
      groupValue: group,
      activeColor: brand,
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
      ),
      onChanged: (v) {
        if (v != null) onPick(v);
      },
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _AboutRow extends StatelessWidget {
  final String label;
  final String value;

  const _AboutRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
