import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prepify/utils/constants/colors.dart';
import 'package:prepify/utils/constants/text_styles.dart';
import 'package:prepify/utils/constants/app_sizes.dart';
import 'package:prepify/screens/auth/signup_screen.dart';
import 'package:prepify/screens/auth/controllers/login_controller.dart';
import 'package:prepify/screens/auth/widgets/form_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginController loginController;

  @override
  void initState() {
    super.initState();
    loginController = LoginController();
  }

  @override
  void dispose() {
    loginController.onClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/logo.png',
                  height: 120,
                  width: 120,
                ),
                const SizedBox(height: AppSizes.marginLarge),
                
                // Welcome text
                Text(
                  'Welcome Back!',
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSizes.marginSmall),
                
                Text(
                  'Sign in to continue',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.grey,
                  ),
                ),
                const SizedBox(height: AppSizes.marginLarge * 2),
                
                // Login Form
                Form(
                  key: loginController.formKey,
                  child: Column(
                    children: [
                      // Identifier Field (Email, Phone, or Username)
                      TextFormField(
                        controller: loginController.identifierController,
                        decoration: InputDecoration(
                          labelText: 'Email, Phone, or Username',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
                          ),
                          filled: true,
                          fillColor: AppColors.lightGrey.withOpacity(0.3),
                        ),
                        validator: loginController.validateIdentifier,
                      ),
                      const SizedBox(height: AppSizes.marginMedium),
                      
                      // Password Field
                      Obx(
                        () => TextFormField(
                          controller: loginController.passwordController,
                          obscureText: loginController.obscurePassword.value,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                loginController.obscurePassword.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: loginController.togglePasswordVisibility,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
                            ),
                            filled: true,
                            fillColor: AppColors.lightGrey.withOpacity(0.3),
                          ),
                          validator: loginController.validatePassword,
                        ),
                      ),
                      const SizedBox(height: AppSizes.marginSmall),
                      
                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Handle forgot password
                          },
                          child: Text(
                            'Forgot Password?',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.marginLarge),
                      
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: loginController.handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
                            ),
                          ),
                          child: Text(
                            'Login',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.marginLarge),
                      
                      // Divider
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingSmall),
                            child: Text(
                              'or continue with',
                              style: AppTextStyles.labelMedium,
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: AppSizes.marginLarge),
                      
                      // Social Login Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Google Button
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.lightGrey.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.account_circle,
                                color: AppColors.primary,
                                size: AppSizes.iconLarge,
                              ),
                              onPressed: () {
                                // Handle Google login
                              },
                            ),
                          ),
                          // Facebook Button
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.lightGrey.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.facebook,
                                color: AppColors.primary,
                                size: AppSizes.iconLarge,
                              ),
                              onPressed: () {
                                // Handle Facebook login
                              },
                            ),
                          ),
                          // Twitter Button
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.lightGrey.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.chat,
                                color: AppColors.primary,
                                size: AppSizes.iconLarge,
                              ),
                              onPressed: () {
                                // Handle Twitter login
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.marginLarge * 2),
                      
                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: AppTextStyles.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () {
                              Get.to(() => const SignupScreen());
                            },
                            child: Text(
                              'Sign Up',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
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
}