import 'package:flutter/material.dart';
import 'package:prepify/home/profile_screen/profile_screen.dart';
import 'package:prepify/home/profile_screen/edit_profile_screen.dart';

class AppPreferencesScreen extends StatefulWidget {
  const AppPreferencesScreen({super.key});

  @override
  State<AppPreferencesScreen> createState() => _AppPreferencesScreenState();
}

class _AppPreferencesScreenState extends State<AppPreferencesScreen> {
  bool _darkMode = false;
  bool _pushNotifications = true;
  bool _mealReminders = true;
  String _selectedLanguage = "English";
  String _unitSystem = "Metric";

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
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                      );
                    },
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage('assets/images/me.jpeg'),
                      backgroundColor: Color(0xFFEEEEEE),
                    ),
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
                        MaterialPageRoute(builder: (context) => ProfileScreen()),
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
                child: const Icon(Icons.arrow_back_ios, color: Color(0xFF9CCC65), size: 18),
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                "App Preferences",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 30),

              // Display Section
              _buildSectionTitle("Display"),
              _buildPreferenceTile(
                icon: Icons.dark_mode_outlined,
                title: "Dark Mode",
                trailing: Switch(
                  value: _darkMode,
                  onChanged: (val) => setState(() => _darkMode = val),
                  activeColor: const Color(0xFF9CCC65),
                ),
              ),
              
              const SizedBox(height: 25),

              // Notifications Section
              _buildSectionTitle("Notifications"),
              _buildPreferenceTile(
                icon: Icons.notifications_none_outlined,
                title: "Push Notifications",
                trailing: Switch(
                  value: _pushNotifications,
                  onChanged: (val) => setState(() => _pushNotifications = val),
                  activeColor: const Color(0xFF9CCC65),
                ),
              ),
              _buildPreferenceTile(
                icon: Icons.timer_outlined,
                title: "Meal Reminders",
                trailing: Switch(
                  value: _mealReminders,
                  onChanged: (val) => setState(() => _mealReminders = val),
                  activeColor: const Color(0xFF9CCC65),
                ),
              ),

              const SizedBox(height: 25),

              // Regional Section
              _buildSectionTitle("Regional"),
              _buildPreferenceTile(
                icon: Icons.language_outlined,
                title: "Language",
                trailing: Text(
                  _selectedLanguage,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                onTap: () {
                  // Show language selector logic
                },
              ),
              _buildPreferenceTile(
                icon: Icons.straighten_outlined,
                title: "Unit System",
                trailing: Text(
                  _unitSystem,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                onTap: () {
                   setState(() {
                     _unitSystem = _unitSystem == "Metric" ? "Imperial" : "Metric";
                   });
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          fontFamily: 'Serif',
        ),
      ),
    );
  }

  Widget _buildPreferenceTile({
    required IconData icon,
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.black, size: 22),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        trailing: trailing,
      ),
    );
  }
}
