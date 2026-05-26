import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prepify/models/user_model.dart';
import 'package:prepify/services/user_service.dart';
import 'package:prepify/services/auth_service.dart';
import 'package:prepify/screens/auth/login_screen.dart';
import 'package:prepify/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}


class _SettingsScreenState extends State<SettingsScreen> {
  UserModel? _user;
  bool _isLoading = true;
  bool _notifications = true;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null) {
      final user = await UserService.getUserById(currentUserId);
      if (user != null && mounted) {
        setState(() {
          _user = user;
          _usernameController.text = user.username;
          _bioController.text = user.bio;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_user == null) return;

    final updatedUser = _user!.copyWith(
      username: _usernameController.text.trim(),
      bio: _bioController.text.trim(),
    );

    try {
      await UserService.updateUserProfile(updatedUser);
      setState(() => _user = updatedUser);
      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile');
    }
  }

  Future<void> _togglePrivacy(String field, bool value) async {
    if (_user == null) return;

    final updatedUser = field == 'isPrivate'
        ? _user!.copyWith(isPrivate: value)
        : _user!.copyWith(showFavoritesPublicly: value);

    try {
      await UserService.updateUserProfile(updatedUser);
      setState(() => _user = updatedUser);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update privacy settings');
    }
  }

  Future<void> _logout() async {
    await AuthService.signOut();
    Get.offAll(() => const LoginScreen());
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await UserService.deleteAccount();
        Get.offAll(() => const LoginScreen());
      } catch (e) {
        Get.snackbar('Error', 'Failed to delete account');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildSectionHeader('Profile'),
            _buildTextField('Username', _usernameController),
            _buildTextField('Bio', _bioController, maxLines: 3),
            _buildButton('Update Profile', _updateProfile),

            // Preferences Section
            _buildSectionHeader('Preferences'),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return _buildSwitch(
                  'Dark Mode',
                  themeProvider.isDarkMode,
                  (value) => themeProvider.toggleDarkMode(),
                );
              },
            ),
            _buildSwitch(
              'Notifications',
              _notifications,
              (value) => setState(() => _notifications = value),
            ),

            // Privacy Section
            _buildSectionHeader('Privacy'),
            _buildSwitch(
              'Private Profile',
              _user?.isPrivate ?? false,
              (value) => _togglePrivacy('isPrivate', value),
            ),
            _buildSwitch(
              'Show Favorites Publicly',
              _user?.showFavoritesPublicly ?? true,
              (value) => _togglePrivacy('showFavoritesPublicly', value),
            ),

            // Account Section
            _buildSectionHeader('Account'),
            _buildButton('Logout', _logout, color: Colors.grey),
            _buildButton('Delete Account', _deleteAccount, color: Colors.red),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(text),
        ),
      ),
    );
  }
}
