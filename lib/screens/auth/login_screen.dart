import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prepify/screens/auth/signup_screen.dart';
import 'package:prepify/screens/auth/controllers/login_controller.dart';
import 'package:prepify/screens/auth/forgot_password_screen.dart';
import 'package:prepify/services/auth_service.dart';
import 'package:prepify/navigation/nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:prepify/providers/user_profile_provider.dart';

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
    debugPrint('LoginScreen: Initializing... Current User: ${AuthService.currentUser?.email}');
    // if user already signed in, skip login screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AuthService.currentUser != null) {
        context.read<UserProfileProvider>().initializeCurrentUser().then((_) {
          Get.offAll(() => MainScreen(showDashboard: true));
        });
      }
    });
  }

  @override
  void dispose() {
    loginController.onClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('LoginScreen: Building UI...');
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Logo & Brand Name
                Column(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 80,
                      width: 80,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'PREPIFY',
                      style: TextStyle(
                        fontFamily: 'Roboto', // Or your custom font if applicable
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                
                // Welcome Text
                Text(
                  'Welcome to\nPrepify!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                
                Text(
                  'Login to discover amazing\nrecipes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Divider line
                Container(
                  width: 150,
                  height: 1,
                  color: Colors.grey[300],
                ),
                
                const SizedBox(height: 32),
                
                // Login Heading
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600, // Semi-bold/Bold serif look in design?
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Form
                Form(
                  key: loginController.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email Field
                      _buildLabel('Email address'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: loginController.emailController,
                        decoration: _buildInputDecoration(
                          hintText: 'Email address',
                          prefixIcon: Icons.email_outlined,
                        ),
                        validator: loginController.validateEmail,
                      ),
                      const SizedBox(height: 16),
                      
                      // Password Field
                      _buildLabel('Password'),
                      const SizedBox(height: 8),
                      Obx(
                        () => TextFormField(
                          controller: loginController.passwordController,
                          obscureText: loginController.obscurePassword.value,
                          decoration: _buildInputDecoration(
                            hintText: 'Password',
                            prefixIcon: Icons.lock_outline,
                          ).copyWith(
                            suffixIcon: IconButton( // Removed unnecessary prefix icon from screenshot if not present, but keeping lock for UX
                              icon: Icon(
                                loginController.obscurePassword.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: loginController.togglePasswordVisibility,
                            ),
                          ),
                          validator: loginController.validatePassword,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Login Button
                      Obx(() => SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: loginController.isLoading.value
                                  ? null
                                  : () => loginController.handleLogin(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF9CCC65), // Light green from design
                                foregroundColor: Colors.black87,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: loginController.isLoading.value
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black87,
                                      ),
                                    )
                                  : const Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          )),
                      
                      const SizedBox(height: 16),
                      
                      // Forgot Password
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Get.to(() => const ForgotPasswordScreen());
                          },
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
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
                      
                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold, // Matches "Have an account?" bolding in signup
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.to(() => const SignupScreen());
                            },
                            child: Text(
                              "Sign up",
                              style: TextStyle(
                                color: const Color(0xFF7CB342), // Green color matching button roughly
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
        text, // Actually the design puts the label inside the input or as a header. screenshot shows it inside as placeholder mostly? No, "Email address" is valid placeholder. "Password" is placeholder. But usually good to have labels.
        // Wait, looking closer at screenshot:
        // Login:
        // [Email Icon] Email address (Placeholder)
        // [Lock Icon] Password (Placeholder)
        // I will use them as HintText/LabelText inside decoration to match "clean" look.
        // Wait, screenshot 2 (signup) has explicit labels ABOVE the fields "Full Name", "Email", "Password".
        // Screenshot 1 (login) layout is different. It just has fields.
        // I will follow the specific screenshot for each screen.
        // Login screenshot: Just fields with icons.
        // Signup screenshot: Labels above fields.
        // wait... actually looking closely at Login screenshot, it seems to have labels or just placeholders?
        // It looks like placeholders inside the box.
        // I'll stick to placeholders for Login to match strict visual.
        style: const TextStyle(height: 0, fontSize: 0), // Hidden for Login if not needed
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String hintText, required IconData prefixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: Colors.grey[400], size: 20),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF9CCC65)),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}