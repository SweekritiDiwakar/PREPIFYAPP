import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prepify/screens/auth/controllers/forgot_password_controller.dart';
import 'package:prepify/utils/constants/colors.dart';
import 'package:prepify/utils/constants/app_sizes.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final ForgotPasswordController controller;

  @override
  void initState() {
    super.initState();
    controller = ForgotPasswordController();
  }

  @override
  void dispose() {
    controller.onClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Logo & Brand Name
                  Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 60,
                        width: 60,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'PREPIFY',
                        style: TextStyle(
                            fontFamily: 'Roboto',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  // Title
                  const Text(
                    'Forgot\npassword?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                  
                   const SizedBox(height: 20),
                   // Divider line
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 20),
                  
                  // Fields
                  Column(
                    children: [
                      // Number
                      TextFormField(
                        controller: controller.numberController,
                        keyboardType: TextInputType.phone,
                        decoration: _buildInputDecoration(
                          hintText: 'Number',
                          prefixIcon: Icons.phone_in_talk_outlined, // Using phone icon
                        ),
                        validator: controller.validateNumber,
                      ),
                      const SizedBox(height: 16),
                      
                      // OTP
                      TextFormField(
                        controller: controller.otpController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration(
                          hintText: 'Your OTP',
                          prefixIcon: Icons.grid_view, // Using grid icon for OTP as in design (roughly)
                        ),
                        validator: controller.validateOTP,
                      ),
                      const SizedBox(height: 16),
                      
                      // New Password
                      Obx(
                        () => TextFormField(
                          controller: controller.newPasswordController,
                          obscureText: controller.obscureNewPassword.value,
                          decoration: _buildInputDecoration(
                            hintText: 'New password',
                            prefixIcon: Icons.lock_outline,
                          ),
                          validator: controller.validatePassword,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Retype Password
                      Obx(
                        () => TextFormField(
                          controller: controller.confirmPasswordController,
                          obscureText: controller.obscureConfirmPassword.value,
                          decoration: _buildInputDecoration(
                            hintText: 'Retype your new password',
                            prefixIcon: Icons.lock_outline,
                          ),
                          validator: controller.validateConfirmPassword,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                   // Divider line
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 30),
                  
                  // Login Button (Reset Action)
                  SizedBox(
                    width: 200, // Fixed width as per design roughly or could be full
                    child: ElevatedButton(
                      onPressed: controller.handleReset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9CCC65), // Light green
                        foregroundColor: Colors.black87,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Login', // Design says 'Login' on the button
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Serif', // Looks like a serif font in design screenshot
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                   const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String hintText, required IconData prefixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13, fontFamily: 'Serif'), // Serif font for placeholders to match design feel
      prefixIcon: Icon(prefixIcon, color: Colors.grey[400], size: 20),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF9CCC65)),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
