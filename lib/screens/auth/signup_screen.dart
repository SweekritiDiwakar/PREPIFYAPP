import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prepify/screens/auth/login_screen.dart';
import 'package:prepify/screens/auth/controllers/signup_controller.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late final SignupController signupController;

  @override
  void initState() {
    super.initState();
    signupController = SignupController();
  }

  @override
  void dispose() {
    signupController.onClose();
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
                      height: 120,
                      width: 120,
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
                  'Create your\nown account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.2,
                  ),
                ),
                
                const SizedBox(height: 10),
                 // Divider line
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 24),
                
                // Form
                Form(
                  key: signupController.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full Name
                      _buildLabel('Full Name'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: signupController.nameController,
                        decoration: _buildInputDecoration(hintText: 'Your full name'),
                        validator: signupController.validateName,
                      ),
                      const SizedBox(height: 16),
                      
                      // Email
                      _buildLabel('Email'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: signupController.emailController,
                        decoration: _buildInputDecoration(hintText: 'abc@gmail.com'),
                        validator: signupController.validateEmail,
                      ),
                      const SizedBox(height: 16),
                      
                      // Password
                      _buildLabel('Password'),
                      const SizedBox(height: 8),
                      Obx(
                        () => TextFormField(
                          controller: signupController.passwordController,
                          obscureText: signupController.obscurePassword.value,
                          decoration: _buildInputDecoration(hintText: 'At least 8 characters'),
                          validator: signupController.validatePassword,
                        ),
                      ),
                      const SizedBox(height: 16),

                       // Confirm Password
                      _buildLabel('Confirm password'),
                      const SizedBox(height: 8),
                      Obx(
                        () => TextFormField(
                          controller: signupController.confirmPasswordController,
                          obscureText: signupController.obscureConfirmPassword.value,
                          decoration: _buildInputDecoration(hintText: 'Confirm password'),
                          validator: signupController.validateConfirmPassword,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Create Account Button
                      Obx(() => SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: signupController.isLoading.value
                                  ? null
                                  : () => signupController.handleSignup(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF9CCC65), // Light green
                                foregroundColor: Colors.black87,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: signupController.isLoading.value
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black87,
                                      ),
                                    )
                                  : const Text(
                                      'Create account',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          )),
                      
                      const SizedBox(height: 24),
                       // OR Divider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 40, height: 1, color: Colors.grey[400]),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'or',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(width: 40, height: 1, color: Colors.grey[400]),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Have an account? ",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.to(() => const LoginScreen());
                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                color: Color(0xFF7CB342),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10), // Slightly smaller radius in signup? no same.
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