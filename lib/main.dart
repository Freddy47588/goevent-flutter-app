import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'app.dart'; // file tempat GoEventApp berada

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Anti white screen: tampilkan error kalau Firebase gagal
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Text(
              'Firebase init error:\n$e',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
    return;
  }

  runApp(const GoEventApp());
}
