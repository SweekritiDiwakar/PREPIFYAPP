import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:prepify/navigation/nav_bar.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  var obscurePassword = true.obs;

  final identifierController = TextEditingController(); // Can be email, phone, or username
  final passwordController = TextEditingController();

  @override
  void onClose() {
    identifierController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void handleLogin() {
    if (formKey.currentState!.validate()) {
      // Perform login logic here
      // For now, we'll just navigate to the main screen
      Get.offAll(() => const MainScreen());
    }
  }

  String? validateIdentifier(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email, phone, or username';
    }
    
    // Check if it's an email
    if (RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return null; // Valid email
    }
    
    // Check if it's a phone number (10-15 digits)
    if (RegExp(r'^[0-9]{10,15}$').hasMatch(value)) {
      return null; // Valid phone
    }
    
    // Check if it's a username (at least 3 characters)
    if (value.length >= 3) {
      return null; // Valid username
    }
    
    return 'Please enter a valid email, phone number, or username';
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}