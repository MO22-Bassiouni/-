import 'package:flutter/material.dart';
import 'app.dart';
import 'core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await app.init();
  } catch (_) {}
  try {
    await Repo.load();
  } catch (_) {}
  runApp(const ClinicApp());
}
