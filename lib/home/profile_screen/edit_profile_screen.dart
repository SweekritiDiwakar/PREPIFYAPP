import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:prepify/home/profile_screen/profile_screen.dart';
import 'package:prepify/providers/user_profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  File? _selectedImage;
  bool _obscurePassword = true;

  ImageProvider? _resolveAvatarProvider({
    required String imageUrl,
    required File? selectedImage,
  }) {
    if (selectedImage != null) return FileImage(selectedImage);
    if (imageUrl.isNotEmpty) return NetworkImage(imageUrl);
    return null;
  }

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProfileProvider>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Top Bar: Avatar, Logo, Bell
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Consumer<UserProfileProvider>(
                    builder: (context, profileProvider, _) {
                      final imageUrl = profileProvider.user?.profileImage ?? '';
                      final avatarProvider = _resolveAvatarProvider(
                        imageUrl: imageUrl,
                        selectedImage: _selectedImage,
                      );
                      return CircleAvatar(
                        radius: 20,
                        backgroundImage: avatarProvider,
                        backgroundColor: const Color(0xFFEEEEEE),
                        child: avatarProvider == null
                            ? const Icon(Icons.person, color: Colors.grey)
                            : null,
                      );
                    },
                  ),
                  Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 40,
                        width: 40,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'PREPIFY',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
                      );
                    },
                    child: const Icon(Icons.settings, size: 28, color: Colors.black),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // Back Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios, color: Color(0xFFAED581), size: 20),
              ),

              const SizedBox(height: 20),

              // Profile Photo Section
              Center(
                child: Column(
                  children: [
                    Consumer<UserProfileProvider>(
                      builder: (context, profileProvider, _) {
                        final imageUrl = profileProvider.user?.profileImage ?? '';
                        final avatarProvider = _resolveAvatarProvider(
                          imageUrl: imageUrl,
                          selectedImage: _selectedImage,
                        );
                        return CircleAvatar(
                      radius: 60,
                      backgroundImage: avatarProvider,
                      child: avatarProvider == null
                          ? const Icon(Icons.person, size: 40, color: Colors.grey)
                          : null,
                    );
                      },
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _pickProfileImage,
                      child: const Text(
                        "Change photo",
                        style: TextStyle(
                          color: Color(0xFF689F38),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Personal Information Section
              const Text(
                "Personal Information",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildEditField("Name", _nameController),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildEditField("Email", _emailController),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Security Section
              const Text(
                "Security",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildEditField(
                  "Password", 
                  _passwordController, 
                  isPassword: true,
                  obscureText: _obscurePassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 40),

              // Save Button
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 120,
                  height: 45,
                  child: Consumer<UserProfileProvider>(
                    builder: (context, profileProvider, _) {
                      return ElevatedButton(
                        onPressed: profileProvider.isLoading
                            ? null
                            : () async {
                                await profileProvider.updateName(
                                  _nameController.text.trim(),
                                );
                                if (_selectedImage != null) {
                                  await profileProvider.updateProfileImage(
                                    _selectedImage!,
                                  );
                                }

                                if (!mounted) return;
                                if (profileProvider.errorMessage != null) {
                                  Get.snackbar(
                                    'Error',
                                    profileProvider.errorMessage!,
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                  return;
                                }

                                Get.snackbar(
                                  'Success',
                                  'Profile updated',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                                Navigator.of(this.context).pop();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFAED581),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: profileProvider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Text(
                                "Save",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null) return;
    setState(() {
      _selectedImage = File(picked.path);
    });
  }

  Widget _buildEditField(String label, TextEditingController controller, {
    bool isPassword = false, 
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontFamily: 'Serif',
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: isPassword ? obscureText : false,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                suffixIcon: isPassword 
                  ? IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                        size: 18,
                        color: Colors.grey,
                      ),
                      onPressed: onToggleVisibility,
                    )
                  : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
