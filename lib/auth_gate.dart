import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'features/auth/login_page.dart';
import 'features/home/home_page.dart'; // shell kamu yang ada bottom nav
import 'core/theme/theme_controller.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        final user = snap.data;

        // ✅ kalau user login, load theme dari Firestore (sekali per user)
        if (user != null) {
          ThemeController.instance.init(); // aman kalau init() sudah idempotent
        }

        if (user == null) {
          return const LoginPage();
        }
        return const HomePage(); // ini shell kamu (IndexedStack + bottom nav)
      },
    );
  }
}
