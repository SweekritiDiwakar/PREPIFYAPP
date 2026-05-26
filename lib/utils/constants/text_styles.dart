import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  // Display styles
  static TextStyle displayLarge = const TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.bold,
    color: AppColors.onBackground,
    height: 1.12,
  );
  
  static TextStyle displayMedium = const TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.bold,
    color: AppColors.onBackground,
    height: 1.15,
  );
  
  static TextStyle displaySmall = const TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.onBackground,
    height: 1.22,
  );
  
  // Headline styles
  static TextStyle headlineLarge = const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.onBackground,
    height: 1.25,
  );
  
  static TextStyle headlineMedium = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.onBackground,
    height: 1.28,
  );
  
  static TextStyle headlineSmall = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.onBackground,
    height: 1.33,
  );
  
  // Title styles
  static TextStyle titleLarge = const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.onBackground,
    height: 1.27,
  );
  
  static TextStyle titleMedium = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.onBackground,
    height: 1.50,
  );
  
  static TextStyle titleSmall = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.onBackground,
    height: 1.42,
  );
  
  // Body styles
  static TextStyle bodyLarge = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.onBackground,
    height: 1.50,
  );
  
  static TextStyle bodyMedium = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.onBackground,
    height: 1.42,
  );
  
  static TextStyle bodySmall = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.onBackground,
    height: 1.33,
  );
  
  // Label styles
  static TextStyle labelLarge = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.onBackground,
    height: 1.42,
  );
  
  static TextStyle labelMedium = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.onBackground,
    height: 1.33,
  );
  
  static TextStyle labelSmall = const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: AppColors.onBackground,
    height: 1.45,
  );

  static Null get headingExtraLarge => null;
}