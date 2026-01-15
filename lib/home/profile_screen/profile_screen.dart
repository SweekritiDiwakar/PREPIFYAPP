import 'package:flutter/material.dart';
import 'package:prepify/home/about_us_screen/about_us_screen.dart';

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage('assets/images/me.jpeg'),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 30,
                      ),
                      const Text(
                        "PREPIFY",
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.notifications, size: 28),
                ],
              ),

              const SizedBox(height: 16),

              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.arrow_back_ios,
                    color: Color(0xFF9CCC65), size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),

              const SizedBox(height: 16),

              const Text(
                "Settings",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                  decoration: TextDecoration.underline,
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                "Accounts & Preferences",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                ),
              ),

              const SizedBox(height: 24),

              const Divider(height: 1, color: Colors.grey),
              _settingsItem(
                icon: Icons.person,
                title: "Edit Profile",
                onTap: () {},
                iconColor: const Color(0xFF7B322A),
              ),
              const Divider(height: 1, color: Colors.grey),
              _settingsItem(
                icon: Icons.notifications,
                title: "Notifications",
                onTap: () {},
                iconColor: const Color(0xFF7B322A),
              ),
              const Divider(height: 1, color: Colors.grey),
              _settingsItem(
                icon: Icons.card_membership,
                title: "App prefernces",
                onTap: () {},
                iconColor: const Color(0xFF7B322A),
              ),
              const Divider(height: 1, color: Colors.grey),

              const SizedBox(height: 60),

              Center(
                child: Column(
                  children: [
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () {},
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
                    const SizedBox(height: 16),
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
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
    );
  }
}
