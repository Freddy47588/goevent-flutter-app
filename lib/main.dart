import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ INIT FIREBASE (WAJIB)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ INIT INTL (WAJIB kalau pakai DateFormat + locale)
  await initializeDateFormatting('id_ID', null);

  runApp(const GoEventApp());
}
