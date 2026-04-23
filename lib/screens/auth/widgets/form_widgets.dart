import 'package:flutter/material.dart';
import 'package:prepify/utils/constants/colors.dart';
import 'package:prepify/utils/constants/app_sizes.dart';

class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const EmailField({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
        ),
      ),
      validator: validator,
    );
  }
}

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggleObscureText;
  final String? Function(String?)? validator;
  final String labelText;

  const PasswordField({
    super.key,
    required this.controller,
    required this.obscureText,
    required this.onToggleObscureText,
    this.validator,
    this.labelText = 'Password',
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          onPressed: onToggleObscureText,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
        ),
      ),
      validator: validator,
    );
  }
}

class NameField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const NameField({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Full Name',
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
        ),
      ),
      validator: validator,
    );
  }
}

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback onGoogleTap;
  final VoidCallback onFacebookTap;
  final VoidCallback onTwitterTap;

  const SocialLoginButtons({
    super.key,
    required this.onGoogleTap,
    required this.onFacebookTap,
    required this.onTwitterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Google Button
        OutlinedButton(
          onPressed: onGoogleTap,
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
            ),
          ),
          child: const Icon(
            Icons.account_circle_outlined,
            color: AppColors.primary,
            size: AppSizes.iconLarge,
          ),
        ),
        // Facebook Button
        OutlinedButton(
          onPressed: onFacebookTap,
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
            ),
          ),
          child: const Icon(
            Icons.account_circle_outlined,
            color: AppColors.primary,
            size: AppSizes.iconLarge,
          ),
        ),
        // Twitter Button
        OutlinedButton(
          onPressed: onTwitterTap,
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
            ),
          ),
          child: const Icon(
            Icons.account_circle_outlined,
            color: AppColors.primary,
            size: AppSizes.iconLarge,
          ),
        ),
      ],
    );
  }
}