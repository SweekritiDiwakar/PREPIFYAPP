import 'package:flutter/material.dart';
import 'package:prepify/utils/constants/colors.dart';
import 'package:prepify/utils/constants/text_styles.dart';
import 'package:prepify/utils/constants/app_sizes.dart';

class OnboardingPageModel {
  final IconData image;
  final String title;
  final String description;

  OnboardingPageModel({
    required this.image,
    required this.title,
    required this.description,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingPageModel page;

  const OnboardingPage({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Icon(
            page.image,
            size: 150,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSizes.marginLarge),
          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.marginMedium),
          // Description
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge,
          ),
        ],
      ),
    );
  }
}