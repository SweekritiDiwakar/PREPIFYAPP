import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prepify/navigation/nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prepify/providers/user_profile_provider.dart';
import 'package:prepify/services/auth_service.dart';

class SignupController extends GetxController {
  final formKey = GlobalKey<FormState>();
  var obscurePassword = true.obs;
  var obscureConfirmPassword = true.obs;
  var isLoading = false.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  Future<void> handleSignup(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      await AuthService.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
        name: nameController.text.trim(),
      );
      if (!context.mounted) return;
      await context.read<UserProfileProvider>().initializeCurrentUser();
      // user is automatically signed in after sign up
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      nameController.clear();

      Get.offAll(() => const MainScreen(showDashboard: false));
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'That email is already registered.';
          break;
        case 'invalid-email':
          message = 'Email address is invalid.';
          break;
        case 'weak-password':
          message = 'Password is too weak.';
          break;
        default:
          message = e.message ?? 'Signup failed. Please try again.';
      }
      Get.snackbar('Signup error', message,
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Signup error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }
}