import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prepify/utils/constants/colors.dart';
import 'package:prepify/utils/constants/text_styles.dart';
import 'package:prepify/screens/onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to onboarding screen after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      Get.offAll(() => const OnboardingScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BACKGROUND IMAGE
          SizedBox.expand(
            child: Image.asset(
              'assets/images/splash.jpeg',
              fit: BoxFit.cover,
            ),
          ),

          // COLOR OVERLAY
          Container(
            color: Colors.black.withOpacity(0.4), // dark overlay for contrast
          ),

          // CONTENT
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 100,
                  color: AppColors.onPrimary,
                ),
                const SizedBox(height: 20),
                Text(
                  'Prepify',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your personal recipe assistant',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.onPrimary.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 40),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
