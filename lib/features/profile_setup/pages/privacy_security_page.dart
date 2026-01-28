import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';

class PrivacySecurityPage extends StatelessWidget {
  const PrivacySecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Security')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ActionCard(
            icon: Icons.password_rounded,
            title: 'Change Password',
            subtitle: 'Update your account password',
            color: brand,
            onTap: () => _changePassword(context),
          ),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.delete_forever_rounded,
            title: 'Delete Account',
            subtitle: 'Permanently remove your account',
            color: const Color(0xFFD32F2F),
            onTap: () => _deleteAccount(context),
          ),
        ],
      ),
    );
  }

  // =========================
  // CHANGE PASSWORD (REAL)
  // =========================
  static Future<void> _changePassword(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final messenger = ScaffoldMessenger.of(context);

    final isPasswordProvider = user.providerData.any(
      (p) => p.providerId == 'password',
    );

    // Jika login via Google/Phone, reset via email (tetap pakai konfirmasi)
    if (!isPasswordProvider) {
      final email = user.email;
      if (email == null || email.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Akun ini tidak punya email untuk reset password.'),
          ),
        );
        return;
      }

      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Reset Password'),
          content: Text('Kirim link reset password ke:\n$email ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Send'),
            ),
          ],
        ),
      );

      if (ok != true) return;

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        if (context.mounted) {
          messenger.showSnackBar(
            SnackBar(content: Text('Link reset password dikirim ke $email')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          messenger.showSnackBar(
            SnackBar(content: Text('Gagal kirim reset email: $e')),
          );
        }
      }
      return;
    }

    final currentC = TextEditingController();
    final newC = TextEditingController();

    final fill = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentC,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current password'),
            ),
            TextField(
              controller: newC,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New password (min 6 chars)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (fill != true) {
      currentC.dispose();
      newC.dispose();
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Update'),
        content: const Text('Yakin ingin mengubah password akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (confirm != true) {
      currentC.dispose();
      newC.dispose();
      return;
    }

    final newPass = newC.text.trim();
    if (newPass.length < 6) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Password baru minimal 6 karakter.')),
      );
      currentC.dispose();
      newC.dispose();
      return;
    }

    try {
      final email = user.email!;
      final cred = EmailAuthProvider.credential(
        email: email,
        password: currentC.text.trim(),
      );

      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPass);

      if (context.mounted) {
        await _showPasswordSuccessDialog(context);
      }
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Gagal ubah password: $e')),
        );
      }
    } finally {
      currentC.dispose();
      newC.dispose();
    }
  }

  static Future<void> _showPasswordSuccessDialog(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: brand),
            const SizedBox(width: 8),
            const Text('Berhasil'),
          ],
        ),
        content: const Text(
          'Password kamu berhasil diubah.\n'
          'Gunakan password baru saat login berikutnya.',
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: brand,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // =========================
  // DELETE ACCOUNT (FIXED)
  // =========================
  static Future<void> _deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // simpan handler SEBELUM await (biar tidak pakai context dialog/disposed)
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // 1) Konfirmasi pertama
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Akun akan dihapus permanen (Firestore user doc juga dihapus).\n\nLanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFD32F2F)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 2) Konfirmasi kedua: ketik DELETE
    final confirmTextC = TextEditingController();
    final confirm2 = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Final Confirmation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ketik "DELETE" untuk melanjutkan.'),
            const SizedBox(height: 12),
            TextField(
              controller: confirmTextC,
              decoration: const InputDecoration(labelText: 'Type DELETE'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
            ),
            onPressed: () {
              final ok = confirmTextC.text.trim().toUpperCase() == 'DELETE';
              Navigator.pop(ctx, ok);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    confirmTextC.dispose();

    if (confirm2 != true) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi tidak valid. Hapus akun dibatalkan.'),
        ),
      );
      return;
    }

    // 3) Jika provider password -> minta password untuk re-auth
    final isPasswordProvider = user.providerData.any(
      (p) => p.providerId == 'password',
    );

    String? password;

    if (isPasswordProvider) {
      final passC = TextEditingController();
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirm Password'),
          content: TextField(
            controller: passC,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );

      password = ok == true ? passC.text.trim() : null;
      passC.dispose();

      if (password == null || password.isEmpty) return;
    }

    // 4) Loading (gunakan rootNavigator)
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Re-auth (wajib kalau provider password)
      if (isPasswordProvider) {
        final email = user.email!;
        final cred = EmailAuthProvider.credential(
          email: email,
          password: password!,
        );
        await user.reauthenticateWithCredential(cred);
      }

      final uid = user.uid;

      // Hapus user doc Firestore dulu
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();

      // Hapus auth account
      await user.delete();

      // Tutup loading dulu
      if (navigator.canPop()) navigator.pop();

      // Redirect ke login (pakai named route kamu)
      navigator.pushNamedAndRemoveUntil('/login', (_) => false);
    } on FirebaseAuthException catch (e) {
      // Tutup loading kalau masih kebuka
      if (navigator.canPop()) navigator.pop();

      if (e.code == 'requires-recent-login') {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Untuk hapus akun, silakan login ulang dulu (security).',
            ),
          ),
        );
        await FirebaseAuth.instance.signOut();
        navigator.pushNamedAndRemoveUntil('/login', (_) => false);
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Gagal delete account: ${e.message ?? e.code}'),
          ),
        );
      }
    } catch (e) {
      if (navigator.canPop()) navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text('Gagal delete account: $e')),
      );
    }
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
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
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}
