import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prepify/screens/onboarding/onboarding_screen.dart';
import 'package:prepify/screens/auth/login_screen.dart';
import 'package:prepify/providers/user_profile_provider.dart';
import 'package:prepify/services/auth_service.dart';
import 'package:prepify/navigation/nav_bar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Fade animation for both background and text
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Subtle scale animation for zoom effect
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();

    // Navigate after a fixed 3-second delay as per requirements
    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;
      
      final prefs = await SharedPreferences.getInstance();
      // Debug: Force onboarding to show by ignoring saved preference
      final onboardingCompleted = false; // prefs.getBool('onboarding_completed') ?? false;

      if (!onboardingCompleted) {
        debugPrint('SplashScreen: First time user, going to Onboarding');
        Get.offAllNamed('/onboarding');
        return;
      }

      if (AuthService.currentUser != null) {
        debugPrint('SplashScreen: User logged in, going to Home');
        await context.read<UserProfileProvider>().initializeCurrentUser();
        if (!mounted) return;
        Get.offAll(() => MainScreen(showDashboard: true));
      } else {
        debugPrint('SplashScreen: No user, going to Login');
        Get.offAllNamed('/login');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logo.png', // App logo as requested
                  width: 150,
                  height: 150,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
