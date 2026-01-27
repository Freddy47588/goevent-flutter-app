import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final text = isDark ? Colors.white : Colors.black;
    final subText = isDark ? Colors.white70 : Colors.black54;

    // Aksen pink seperti di gambar (kalau kamu punya di AppColors, ganti ke sana)
    const accent = Color(0xFFFF2DA1);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notification',
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w900,
            color: text,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        children: [
          _SectionTitle(title: 'Today', color: subText),
          const SizedBox(height: 10),

          _NotificationTile(
            accent: accent,
            surface: surface,
            titleColor: text,
            subtitleColor: subText,
            icon: Icons.discount_rounded,
            title: 'Get 30% Off on Music Event!',
            subtitle: 'Special promotion only valid today',
          ),
          const SizedBox(height: 12),
          _NotificationTile(
            accent: accent,
            surface: surface,
            titleColor: text,
            subtitleColor: subText,
            icon: Icons.lock_rounded,
            title: 'Password Update Successful',
            subtitle: 'Your password update successfully',
          ),

          const SizedBox(height: 18),
          _SectionTitle(title: 'Yesterday', color: subText),
          const SizedBox(height: 10),

          _NotificationTile(
            accent: accent,
            surface: surface,
            titleColor: text,
            subtitleColor: subText,
            icon: Icons.person_rounded,
            title: 'Account Setup Successful!',
            subtitle: 'Your account has been created',
          ),
          const SizedBox(height: 12),
          _NotificationTile(
            accent: accent,
            surface: surface,
            titleColor: text,
            subtitleColor: subText,
            icon: Icons.card_giftcard_rounded,
            title: 'Redeem your gift cart',
            subtitle: 'You have get one gift card',
          ),
          const SizedBox(height: 12),
          _NotificationTile(
            accent: accent,
            surface: surface,
            titleColor: text,
            subtitleColor: subText,
            icon: Icons.credit_card_rounded,
            title: 'Debit card added successfully',
            subtitle: 'Your debit card added successfully',
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionTitle({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.caption.copyWith(
        color: color,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final Color accent;
  final Color surface;
  final Color titleColor;
  final Color subtitleColor;

  final IconData icon;
  final String title;
  final String subtitle;

  const _NotificationTile({
    required this.accent,
    required this.surface,
    required this.titleColor,
    required this.subtitleColor,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 8),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: subtitleColor,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
