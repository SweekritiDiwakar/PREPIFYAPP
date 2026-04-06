import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prepify/navigation/nav_bar.dart';
import 'package:prepify/providers/user_profile_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prepify/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  var obscurePassword = true.obs;
  var isLoading = false.obs;
  var rememberMe = false.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadSavedCredentials();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('saved_email');
      final savedPassword = prefs.getString('saved_password');
      final shouldRemember = prefs.getBool('remember_me') ?? false;

      if (shouldRemember && savedEmail != null && savedPassword != null) {
        emailController.text = savedEmail;
        passwordController.text = savedPassword;
        rememberMe.value = true;
      }
    } catch (e) {
      // Silently fail if we can't load saved credentials
    }
  }

  Future<void> _saveCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (rememberMe.value) {
        await prefs.setString('saved_email', emailController.text);
        await prefs.setString('saved_password', passwordController.text);
        await prefs.setBool('remember_me', true);
      } else {
        await prefs.remove('saved_email');
        await prefs.remove('saved_password');
        await prefs.setBool('remember_me', false);
      }
    } catch (e) {
      // Silently fail if we can't save credentials
    }
  }

  Future<void> handleLogin(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await AuthService.signIn(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      
      // Save credentials if "Remember Me" is checked
      await _saveCredentials();
      
      if (!context.mounted) return;
      await context.read<UserProfileProvider>().initializeCurrentUser();
      
      // Only clear sensitive information if "Remember Me" is not checked
      if (!rememberMe.value) {
        emailController.clear();
        passwordController.clear();
      }

      Get.offAll(() => const MainScreen(showDashboard: true));
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found for that email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password provided.';
          break;
        case 'invalid-email':
          message = 'Email address is invalid.';
          break;
        default:
          message = e.message ?? 'Login failed. Please try again.';
      }
      Get.snackbar('Login error', message,
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Login error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
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