import 'package:flutter/material.dart';
import 'package:prepify/utils/constants/text_styles.dart';
import 'package:prepify/utils/constants/app_sizes.dart';

class OnboardingPageModel {
  final String image;
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

  const OnboardingPage({
    super.key, 
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: Image.asset(
            page.image,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[800],
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.white, size: 50),
                ),
              );
            },
          ),
        ),
        // Gradient Overlay for text readability
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.8),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
        ),

        // Content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                page.title,
                textAlign: TextAlign.left,
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: AppSizes.marginMedium),
              Text(
                page.description,
                textAlign: TextAlign.left,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.5,
                ),
              ),
              // Add extra spacing at bottom to account for navigation buttons
              const SizedBox(height: 160), 
            ],
          ),
        ),
      ],
    );
  }
}