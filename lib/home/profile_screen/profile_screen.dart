import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:prepify/home/about_us_screen/about_us_screen.dart';
import 'package:prepify/home/household_screen/household_screen.dart';
import 'package:prepify/screens/auth/login_screen.dart';
import 'package:prepify/home/profile_screen/edit_profile_screen.dart';
import 'package:prepify/home/notification_screen/notification_screen.dart';
import 'package:prepify/home/profile_screen/app_preferences_screen.dart';
import 'package:prepify/home/profile_screen/widgets/stock_tracking_section.dart';
import 'package:prepify/providers/user_profile_provider.dart';
import 'package:prepify/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔝 Top Bar
              Consumer<UserProfileProvider>(
                builder: (context, profileProvider, _) {
                  final imageUrl = profileProvider.user?.profileImage ?? '';
                  return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                      );
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: imageUrl.isNotEmpty
                          ? NetworkImage(imageUrl)
                          : null,
                      backgroundColor: Color(0xFFEEEEEE),
                      child: imageUrl.isEmpty
                          ? const Icon(Icons.person, color: Colors.grey)
                          : null,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 35,
                      ),
                      const Text(
                        "PREPIFY",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileScreen()),
                      );
                    },
                    child: const Icon(Icons.settings, size: 28, color: Colors.black),
                  ),
                ],
                  );
                },
              ),

              const SizedBox(height: 16),

              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios,
                    color: Color(0xFF9CCC65), size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),

              const SizedBox(height: 16),

              const Text(
                "Profile",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 24),

              // Profile Info Card
              Consumer<UserProfileProvider>(
                builder: (context, profileProvider, _) {
                  if (profileProvider.isLoading && profileProvider.user == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final user = profileProvider.user;
                  final imageUrl = user?.profileImage ?? '';
                  return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage:
                          imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                      child: imageUrl.isEmpty
                          ? const Icon(Icons.person, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name.isNotEmpty == true ? user!.name : 'No name',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'serif',
                          ),
                        ),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                  );
                },
              ),

              const SizedBox(height: 32),

              const Text(
                "Accounts & Preferences",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 24),

              const Divider(height: 1, color: Colors.grey),
              _settingsItem(
                icon: Icons.person,
                title: "Edit Profile",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                  );
                },
                iconColor: Colors.white,
                circleColor: const Color(0xFF7B322A),
              ),
              const Divider(height: 1, color: Colors.grey),
              _settingsItem(
                icon: Icons.notifications,
                title: "Notifications",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AppNotificationScreen()),
                  );
                },
                iconColor: Colors.white,
                circleColor: const Color(0xFF7B322A),
              ),
              const Divider(height: 1, color: Colors.grey),
              _settingsItem(
                icon: Icons.credit_card,
                title: "App prefernces",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AppPreferencesScreen()),
                  );
                },
                iconColor: Colors.white,
                circleColor: const Color(0xFF7B322A),
              ),
              const Divider(height: 1, color: Colors.grey),
              _settingsItem(
                icon: Icons.groups_2_outlined,
                title: "Household",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HouseholdScreen(),
                    ),
                  );
                },
                iconColor: Colors.white,
                circleColor: const Color(0xFF7B322A),
              ),
              const Divider(height: 1, color: Colors.grey),
              const SizedBox(height: 24),
              const StockTrackingSection(),

              const SizedBox(height: 24),

              const SizedBox(height: 80),

              Center(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.3),
                            spreadRadius: 2,
                            blurRadius: 1,
                            offset: const Offset(0, 0),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: SizedBox(
                        width: 220,
                        child: ElevatedButton(
                          onPressed: () async {
                            await AuthService.signOut();
                            if (context.mounted) {
                              context.read<UserProfileProvider>().clearUser();
                            }
                            Get.offAll(() => const LoginScreen());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFAED581),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Logout",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'serif',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AboutUsScreen()),
                        );
                      },
                      child: const Text(
                        "About us",
                        style: TextStyle(
                          color: Color(0xFF9CCC65),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color iconColor,
    required Color circleColor,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: circleColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
          fontFamily: 'serif',
        ),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
    );
  }
}
