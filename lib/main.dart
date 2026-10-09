import 'package:bloc/bloc.dart';
import 'package:expenses_tracker/simple_bloc_observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:expenses_tracker/app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Loaded before the first frame so the saved theme / name / currency are
  // applied immediately (no flash of the default theme).
  final prefs = await SharedPreferences.getInstance();

  Bloc.observer = SimpleBlocObserver();

  runApp(MyApp(prefs: prefs));
}
