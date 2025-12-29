import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:prepify/screens/nav_pages/home_page.dart';
import 'package:prepify/screens/nav_pages/search_screen.dart';
import 'package:prepify/screens/nav_pages/recipe_screen.dart';
import 'package:prepify/screens/nav_pages/profile_screen.dart';
import 'package:prepify/utils/constants/colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const SearchScreen(),
    const RecipeScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 60.0,
        items: const <Widget>[
          Icon(Icons.home, size: 30, color: AppColors.onPrimary),
          Icon(Icons.search, size: 30, color: AppColors.onPrimary),
          Icon(Icons.restaurant, size: 30, color: AppColors.onPrimary),
          Icon(Icons.person, size: 30, color: AppColors.onPrimary),
        ],
        color: AppColors.primary,
        buttonBackgroundColor: AppColors.primary,
        backgroundColor: AppColors.background,
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