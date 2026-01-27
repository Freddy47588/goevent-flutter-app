import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../services/profile_service.dart';
import 'edit_profile_page.dart';
import 'settings_sheet.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => const SettingsSheet(),
              );
            },
          ),
        ],
      ),
      body: uid.isEmpty
          ? const Center(child: Text('Silakan login terlebih dahulu'))
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data?.data() ?? {};
                final name = data['name'] ?? 'User';
                final username = data['username'] ?? '';
                final about = data['about'] ?? 'Belum ada deskripsi';

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // ===== AVATAR DEFAULT (FIX) =====
                    Center(
                      child: CircleAvatar(
                        radius: 44,
                        backgroundImage: const AssetImage(
                          'assets/images/avatar_default.png',
                        ),
                        backgroundColor: AppColors.lightSurface,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Center(
                      child: Text(
                        name,
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (username.toString().isNotEmpty)
                      Center(
                        child: Text(
                          '@$username',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProfilePage(
                                name: name,
                                username: username,
                                about: about,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                        ),
                        child: const Text(
                          'Edit Profile',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Divider(),

                    Text(
                      'About',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      about,
                      style: AppTextStyles.body.copyWith(color: Colors.black87),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
