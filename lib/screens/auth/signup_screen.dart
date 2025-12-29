import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prepify/utils/constants/colors.dart';
import 'package:prepify/utils/constants/text_styles.dart';
import 'package:prepify/utils/constants/app_sizes.dart';
import 'package:prepify/screens/auth/login_screen.dart';
import 'package:prepify/screens/auth/controllers/signup_controller.dart';
import 'package:prepify/screens/auth/widgets/form_widgets.dart';

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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingLarge),
            child: Form(
              key: signupController.formKey,
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
                    'Create Account',
                    style: AppTextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.marginSmall),
                  
                  Text(
                    'Sign up to get started',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: AppSizes.marginLarge * 2),
                  
                  // Name and Username Fields in the same row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: signupController.nameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
                            ),
                            filled: true,
                            fillColor: AppColors.lightGrey.withOpacity(0.3),
                          ),
                          validator: signupController.validateName,
                        ),
                      ),
                      const SizedBox(width: AppSizes.marginMedium),
                      Expanded(
                        child: TextFormField(
                          controller: signupController.usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
                            ),
                            filled: true,
                            fillColor: AppColors.lightGrey.withOpacity(0.3),
                          ),
                          validator: signupController.validateUsername,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.marginMedium),
                  
                  // Email Field
                  TextFormField(
                    controller: signupController.emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
                      ),
                      filled: true,
                      fillColor: AppColors.lightGrey.withOpacity(0.3),
                    ),
                    validator: signupController.validateEmail,
                  ),
                  const SizedBox(height: AppSizes.marginMedium),
                  
                  // Phone Field
                  TextFormField(
                    controller: signupController.phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
                      ),
                      filled: true,
                      fillColor: AppColors.lightGrey.withOpacity(0.3),
                    ),
                    validator: signupController.validatePhone,
                  ),
                  const SizedBox(height: AppSizes.marginMedium),
                  
                  // Password Field
                  Obx(
                    () => TextFormField(
                      controller: signupController.passwordController,
                      obscureText: signupController.obscurePassword.value,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            signupController.obscurePassword.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: signupController.togglePasswordVisibility,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
                        ),
                        filled: true,
                        fillColor: AppColors.lightGrey.withOpacity(0.3),
                      ),
                      validator: signupController.validatePassword,
                    ),
                  ),
                  const SizedBox(height: AppSizes.marginMedium),
                  
                  // Confirm Password Field
                  Obx(
                    () => TextFormField(
                      controller: signupController.confirmPasswordController,
                      obscureText: signupController.obscureConfirmPassword.value,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            signupController.obscureConfirmPassword.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: signupController.toggleConfirmPasswordVisibility,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
                        ),
                        filled: true,
                        fillColor: AppColors.lightGrey.withOpacity(0.3),
                      ),
                      validator: signupController.validateConfirmPassword,
                    ),
                  ),
                  const SizedBox(height: AppSizes.marginLarge),
                  
                  // Signup Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: signupController.handleSignup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
                        ),
                      ),
                      child: Text(
                        'Sign Up',
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
                          'or sign up with',
                          style: AppTextStyles.labelMedium,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: AppSizes.marginLarge),
                  
                  // Social Signup Buttons
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
                            // Handle Google signup
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
                            // Handle Facebook signup
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
                            // Handle Twitter signup
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.marginLarge * 2),
                  
                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTextStyles.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          Get.to(() => const LoginScreen());
                        },
                        child: Text(
                          'Login',
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
          ),
        ),
      ),
    );
  }
}