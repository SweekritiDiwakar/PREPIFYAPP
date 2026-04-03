import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:prepify/providers/recipe_provider.dart';
import 'package:prepify/providers/social_provider.dart';
import 'package:prepify/firebase_options.dart';
import 'package:prepify/providers/user_profile_provider.dart';
import 'package:prepify/screens/splash/splash_screen.dart';
import 'package:prepify/screens/onboarding/onboarding_screen.dart';
import 'package:prepify/screens/auth/login_screen.dart';
import 'package:prepify/navigation/nav_bar.dart';
import 'package:prepify/services/push_notification_service.dart';
import 'package:prepify/utils/constants/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // Initialize push notifications in the background — do NOT await this,
  // otherwise a slow/failing FCM token request will block the entire app.
  PushNotificationService.initialize();
  runApp(const MyApp());
}



class NoElasticityScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => SocialProvider()),
      ],
      child: GetMaterialApp(
        title: 'Prepify',
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        scrollBehavior: NoElasticityScrollBehavior(),
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => SplashScreen()),
          GetPage(name: '/onboarding', page: () => OnboardingScreen()),
          GetPage(name: '/login', page: () => LoginScreen()),
          GetPage(name: '/home', page: () => MainScreen(showDashboard: true)),
        ],
      ),
    );
  }
}