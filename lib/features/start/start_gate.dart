import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../routes/app_routes.dart';
import '../../auth_gate.dart';

class StartGate extends StatefulWidget {
  const StartGate({super.key});

  @override
  State<StartGate> createState() => _StartGateState();
}

class _StartGateState extends State<StartGate> {
  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seen_onboarding') ?? false;

    if (!mounted) return;

    if (!seen) {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      return;
    }

    // sudah pernah onboarding → lanjut auth flow (login/home)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthGate()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // UI kosong, karena native splash sudah tampil
    return const Scaffold(body: SizedBox.shrink());
  }
}
