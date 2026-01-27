import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/services/auth_service.dart';
import '../../routes/app_routes.dart';
import 'profile_setup_state.dart';

class CreateUsernamePage extends StatefulWidget {
  const CreateUsernamePage({super.key});

  @override
  State<CreateUsernamePage> createState() => _CreateUsernamePageState();
}

class _CreateUsernamePageState extends State<CreateUsernamePage> {
  final _c = TextEditingController();
  bool _loading = false;

  Future<void> _next() async {
    final username = _c.text.trim();
    if (username.isEmpty) return;

    setState(() => _loading = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await AuthService().saveUsername(uid, username);

    if (!mounted) return;
    setState(() => _loading = false);

    Navigator.pushNamed(
      context,
      AppRoutes.selectFavourite,
      arguments: ProfileSetupState(username: username),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create username',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _c,
                decoration: const InputDecoration(hintText: 'Tanya Hill'),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _next,
                  child: Text(_loading ? 'Loading...' : 'Next'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
