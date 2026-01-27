import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/notification_helper.dart';

class EditProfilePage extends StatefulWidget {
  final String name;
  final String username;
  final String about;

  const EditProfilePage({
    super.key,
    required this.name,
    required this.username,
    required this.about,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nameC;
  late final TextEditingController _usernameC;
  late final TextEditingController _aboutC;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameC = TextEditingController(text: widget.name);
    _usernameC = TextEditingController(text: widget.username);
    _aboutC = TextEditingController(text: widget.about);
  }

  @override
  void dispose() {
    _nameC.dispose();
    _usernameC.dispose();
    _aboutC.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _nameC.text.trim(),
        'username': _usernameC.text.trim(),
        'about': _aboutC.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // ✅ push notif setelah update profil sukses
      await pushNotif(
        type: 'profile_updated',
        title: 'Profile Updated',
        message: 'Your profile has been updated successfully.',
      );

      if (mounted)
        Navigator.pop(
          context,
          true,
        ); // opsional: return true biar page sebelumnya bisa refresh

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal update profile: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar tetap default & tidak interaktif
          Center(
            child: CircleAvatar(
              radius: 42,
              backgroundImage: const AssetImage(
                'assets/images/avatar_default.png',
              ),
            ),
          ),
          const SizedBox(height: 16),

          _field('Name', _nameC),
          _field('Username', _usernameC),
          _field('About', _aboutC, maxLines: 4),

          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _loading ? null : _update,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              child: _loading
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : const Text(
                      'Update',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: c,
            maxLines: maxLines,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }
}
