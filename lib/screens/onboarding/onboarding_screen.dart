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
      image: Icons.fastfood,
      title: "Discover Recipes",
      description: "Explore thousands of delicious recipes from around the world, tailored to your taste preferences.",
    ),
    OnboardingPageModel(
      image: Icons.restaurant,
      title: "Plan Your Meals",
      description: "Create meal plans for the week and never wonder what to cook again.",
    ),
    OnboardingPageModel(
      image: Icons.shopping_cart,
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
      Get.offAll(() => const LoginScreen());
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  Get.offAll(() => const LoginScreen());
                },
                child: Text(
                  'Skip',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            // Page view
            Expanded(
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
            // Indicators and buttons
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  Obx(() => onboardingController.isFirstPage ? 
                    const SizedBox(width: 80) : // Placeholder for spacing
                    TextButton(
                      onPressed: _navigateToPreviousPage,
                      child: Text(
                        'Previous',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  ),
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_onboardingPages.length, (index) {
                      return Obx(() => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: onboardingController.currentPageIndex.value == index ? 12 : 8,
                        height: onboardingController.currentPageIndex.value == index ? 12 : 8,
                        decoration: BoxDecoration(
                          color: onboardingController.currentPageIndex.value == index
                              ? AppColors.primary
                              : AppColors.grey,
                          shape: BoxShape.circle,
                        ),
                      ));
                    }),
                  ),
                  // Next/Skip button
                  Obx(() => TextButton(
                    onPressed: _navigateToNextPage,
                    child: Text(
                      onboardingController.isLastPage
                          ? 'Get Started'
                          : 'Next',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

