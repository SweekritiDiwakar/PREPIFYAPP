import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prepify/screens/auth/controllers/forgot_password_controller.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgotPasswordController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: controller.formKey,
              child: Obx(
                () => Column(
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

                    // Email field
                    TextFormField(
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                      decoration: _buildInputDecoration(
                        hintText: 'Email address',
                        prefixIcon: Icons.email_outlined,
                      ),
                      validator: controller.validateEmail,
                    ),

                    const SizedBox(height: 20),

                    // Divider line
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 30),

                    // Reset button
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.handleReset,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9CCC65),
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Text(
                                'Send reset link',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.grey[500],
        fontSize: 13,
        fontFamily: 'Serif',
      ),
      prefixIcon: Icon(prefixIcon, color: Colors.grey[400], size: 20),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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