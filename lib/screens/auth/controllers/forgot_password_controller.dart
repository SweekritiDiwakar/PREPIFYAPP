import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:prepify/screens/auth/login_screen.dart';

class ForgotPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  var obscureNewPassword = true.obs;
  var obscureConfirmPassword = true.obs;

  final numberController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void onClose() {
    numberController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void toggleNewPasswordVisibility() {
    obscureNewPassword.value = !obscureNewPassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  void handleReset() {
    if (formKey.currentState!.validate()) {
      // Perform password reset logic here
      // Navigate back to Login Screen
      Get.offAll(() => const LoginScreen());
    }
  }

  String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your number';
    }
    if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the OTP';
    }
    if (value.length < 4) {
      return 'OTP must be at least 4 digits';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a new password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please retype your new password';
    }
    if (value != newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }
}
