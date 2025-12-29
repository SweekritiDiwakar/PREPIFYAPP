import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:prepify/firebase_options.dart';
import 'package:prepify/screens/splash/splash_screen.dart';
import 'package:prepify/utils/constants/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Prepify',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      home: const SplashScreen(),
    );
  }
}