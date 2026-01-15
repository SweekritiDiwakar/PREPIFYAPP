import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:prepify/navigation/nav_bar.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  var obscurePassword = true.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void onClose() {
    emailController.dispose();
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
      Get.offAll(() => const MainScreen(showDashboard: true));
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
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