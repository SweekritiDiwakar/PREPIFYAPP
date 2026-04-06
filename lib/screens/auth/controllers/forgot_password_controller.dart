import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prepify/services/auth_service.dart';

class ForgotPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  var isLoading = false.obs;

  final emailController = TextEditingController();

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> handleReset() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    update(); // Notify GetBuilder to rebuild

    try {
      await AuthService.resetPassword(email: emailController.text.trim());
      Get.snackbar(
        'Success',
        'Reset link sent to your email. Please check your inbox.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.back();
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Failed to send reset email.';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email address.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Please enter a valid email address.';
      } else if (e.message != null) {
        errorMessage = e.message!;
      }

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      update(); // Notify GetBuilder to rebuild
    }
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
}
