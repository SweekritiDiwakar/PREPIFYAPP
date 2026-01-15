import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prepify/utils/constants/colors.dart';
import 'package:prepify/utils/constants/text_styles.dart';
import 'package:prepify/utils/constants/app_sizes.dart';
import 'package:prepify/screens/auth/login_screen.dart';
import 'package:prepify/screens/onboarding/onboarding_controller.dart';
import 'package:prepify/screens/onboarding/onboarding_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final OnboardingController onboardingController = Get.put(OnboardingController());

  final List<OnboardingPageModel> _onboardingPages = [
    OnboardingPageModel(
      image: "assets/images/download (4).jpeg",
      title: "Discover Recipes",
      description: "Explore thousands of delicious recipes from around the world, tailored to your taste preferences.",
    ),
    OnboardingPageModel(
      image: "assets/images/#VISIO~1.JPG",
      title: "Plan Your Meals",
      description: "Create meal plans for the week and never wonder what to cook again.",
    ),
    OnboardingPageModel(
      image: "assets/images/download.jpg",
      title: "Smart Shopping",
      description: "Generate shopping lists automatically based on your selected recipes.",
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToNextPage() {
    if (onboardingController.currentPageIndex.value < _onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to login screen when onboarding is complete
      Get.to(() => const LoginScreen());
    }
  }

  void _navigateToPreviousPage() {
    if (onboardingController.currentPageIndex.value > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background to prevent white flashes
      body: Stack(
        children: [
          // Page View (Background)
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _onboardingPages.length,
              onPageChanged: (int page) {
                onboardingController.updatePageIndex(page);
              },
              itemBuilder: (context, index) {
                return OnboardingPage(
                  page: _onboardingPages[index],
                );
              },
            ),
          ),
          
          // Skip button (Top Right)
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: () {
                Get.to(() => const LoginScreen());
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Skip',
                style: AppTextStyles.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Bottom Navigation Area
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
              child: Column(
                children: [
                  // Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_onboardingPages.length, (index) {
                      return Obx(() => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: onboardingController.currentPageIndex.value == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: onboardingController.currentPageIndex.value == index
                              ? AppColors.primary
                              : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ));
                    }),
                  ),
                  const SizedBox(height: 30),
                  // Navigation Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Previous button
                      Obx(() => Visibility(
                        visible: !onboardingController.isFirstPage,
                        replacement: const SizedBox(width: 100), // Keep layout stable
                        child: TextButton(
                          onPressed: _navigateToPreviousPage,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: Text(
                            'Previous',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )),
                      
                      // Next/Get Started button
                      Obx(() => ElevatedButton(
                        onPressed: _navigateToNextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          onboardingController.isLastPage
                              ? 'Get Started'
                              : 'Next',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87, // Better contrast on primary green
                          ),
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

