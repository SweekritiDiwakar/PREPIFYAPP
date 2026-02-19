import 'package:flutter/material.dart';
import 'package:prepify/home/profile_screen/edit_profile_screen.dart';
import 'package:prepify/home/profile_screen/profile_screen.dart';
import 'package:prepify/home/search_screen/breakfast_screen.dart';
import 'package:prepify/home/search_screen/lunch_screen.dart';
import 'package:prepify/home/search_screen/dinner_screen.dart';
import 'package:prepify/home/search_screen/snacks_screen.dart';
import 'package:prepify/home/profile_screen/recipe_details/recipe_detail_screen.dart';
import 'package:prepify/home/profile_screen/recipe_details/recipe_data.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Top Bar: Avatar, Logo, Bell
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
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: const AssetImage('assets/images/me.jpeg'),
                      backgroundColor: Colors.grey[200],
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

              const SizedBox(height: 20),

              // Search Title
              const Text(
                "Search Recipe",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 20),

              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const TextField(
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Search for recipes...",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    icon: Icon(Icons.search, color: Colors.grey, size: 22),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Categories Header
              const Text(
                "Categories",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 15),

              // Categories Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCategory(context, "Breakfast", Icons.coffee, const Color(0xFFFBE9E7), () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const BreakfastScreen()));
                    }),
                    _buildCategory(context, "Lunch", Icons.restaurant, const Color(0xFFE8EAF6), () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LunchScreen()));
                    }),
                    _buildCategory(context, "Dinner", Icons.wine_bar, const Color(0xFFF3E5F5), () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const DinnerScreen()));
                    }),
                    _buildCategory(context, "Snacks", Icons.cookie, const Color(0xFFEFEBE9), () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SnacksScreen()));
                    }),
                  ],
                ),

              const SizedBox(height: 30),

              // Popular Recipes Header
              const Text(
                "Popular Recipes",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 15),

              // Popular Recipes Vertical List
              _buildRecipeItem(context, "Garlic bread", 'assets/images/Garlicbread.jpeg'),
              const SizedBox(height: 15),
              _buildRecipeItem(context, "Butter naan and chicken", 'assets/images/butternaan.jpeg'),
              const SizedBox(height: 15),
              _buildRecipeItem(context, "Chocolate chip cookies", 'assets/images/muffin.jpeg'),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategory(BuildContext context, String label, IconData icon, Color bgColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 65,
            width: 65,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: Colors.brown[900], size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeItem(BuildContext context, String title, String assetPath) {
    return GestureDetector(
      onTap: () {
        final recipe = RecipeData.allRecipes[title];
        if (recipe != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(
                title: recipe["name"],
                imagePath: recipe["image"],
                duration: recipe["duration"],
                difficulty: recipe["difficulty"],
                sections: recipe["sections"],
              ),
            ),
          );
        }
      },
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
              child: Image.asset(
                assetPath,
                width: 100,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
