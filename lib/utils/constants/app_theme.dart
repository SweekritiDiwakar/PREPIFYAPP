import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      color: AppColors.primary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.onPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: Colors.black),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: Colors.black),
      displaySmall: AppTextStyles.displaySmall.copyWith(color: Colors.black),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: Colors.black),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: Colors.black),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(color: Colors.black),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: Colors.black),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: Colors.black),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: Colors.black),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: Colors.black),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: Colors.black),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: Colors.black),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: Colors.black),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: Colors.black),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: Colors.black),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: Colors.black),
      hintStyle: TextStyle(color: Colors.grey[600]),
      suffixIconColor: Colors.grey,
      prefixIconColor: Colors.grey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF9CCC65)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        textStyle: AppTextStyles.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTextStyles.labelLarge,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: const AppBarTheme(
      color: AppColors.primary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.onPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: Colors.black),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: Colors.black),
      displaySmall: AppTextStyles.displaySmall.copyWith(color: Colors.black),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: Colors.black),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: Colors.black),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(color: Colors.black),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: Colors.black),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: Colors.black),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: Colors.black),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: Colors.black),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: Colors.black),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: Colors.black),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: Colors.black),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: Colors.black),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: Colors.black),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        textStyle: AppTextStyles.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTextStyles.labelLarge,
      ),
    ),
  );
}