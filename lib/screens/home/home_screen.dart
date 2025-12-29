import 'package:flutter/material.dart';
import 'package:prepify/utils/constants/colors.dart';
import 'package:prepify/utils/constants/text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.onPrimary),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: const Center(
        child: Text('Welcome to Prepify!'),
      ),
    );
  }
}