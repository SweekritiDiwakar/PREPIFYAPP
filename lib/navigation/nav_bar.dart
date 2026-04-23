import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:prepify/home/dashboard/dashboard_screen.dart';
import 'package:prepify/screens/nav_pages/landing_page.dart';
import 'package:prepify/screens/nav_pages/add_recipe.dart';
import 'package:prepify/home/search_screen/search_screen.dart';
import 'package:prepify/home/notification_screen/notification_screen.dart';
import 'package:prepify/home/profile_screen/user_profile_screen.dart';

class MainScreen extends StatefulWidget {
  final bool showDashboard;
  const MainScreen({super.key, this.showDashboard = true});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    debugPrint('MainScreen: Initializing... showDashboard: ${widget.showDashboard}');
    _pages = [
      widget.showDashboard ? const DashboardScreen() : const LandingPage(),
      const SearchScreen(),
      const AddRecipeScreen(),
      const AppNotificationScreen(),
      UserProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 60.0,
        items: <Widget>[
          const Icon(Icons.home_filled, size: 30, color: Colors.white),
          const Icon(Icons.search, size: 30, color: Colors.white),
          
          // Custom Add Button as an Item
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF9CCC65), // Light green
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.add, size: 20, color: Colors.black),
          ),
          
          const Icon(Icons.notifications_none_outlined, size: 30, color: Colors.white),
          const Icon(Icons.person_outline, size: 30, color: Colors.white),
        ],
        color: Colors.black, // Bar color
        buttonBackgroundColor: Colors.black, // Bubble color
        backgroundColor: Colors.white, // Background behind the curve
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
