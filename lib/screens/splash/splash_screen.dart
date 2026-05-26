import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:prepify/providers/user_profile_provider.dart';

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

    // Navigate after a fixed 3-second delay
    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;
      
      final prefs = await SharedPreferences.getInstance();

      // Check if user has completed onboarding


      final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

      if (!onboardingCompleted) {
        debugPrint('SplashScreen: Showing onboarding');
        Get.offAllNamed('/onboarding');
        return;
      }

      // Respect "Remember me": only auto-enter app when user chose to be remembered.
      final shouldRemember = prefs.getBool('remember_me') ?? false;

      if (FirebaseAuth.instance.currentUser != null && shouldRemember) {
        debugPrint('SplashScreen: User is already logged in and opted to remember, going to Home');
        if (mounted) {
          Provider.of<UserProfileProvider>(context, listen: false).initializeCurrentUser();
        }
        Get.offAllNamed('/home');
        return;
      }

      if (FirebaseAuth.instance.currentUser != null && !shouldRemember) {
        debugPrint('SplashScreen: User exists but did not opt to remember — signing out and going to Login');
        await FirebaseAuth.instance.signOut();
        Get.offAllNamed('/login');
        return;
      }

      debugPrint('SplashScreen: Going to Login screen');
      Get.offAllNamed('/login');
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
