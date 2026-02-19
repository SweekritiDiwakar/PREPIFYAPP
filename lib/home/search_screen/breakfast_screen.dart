import 'package:flutter/material.dart';
import 'package:prepify/home/profile_screen/profile_screen.dart';
import 'package:prepify/home/profile_screen/edit_profile_screen.dart';
import 'package:prepify/home/grocery_list_screen/grocery_list_screen.dart';
import 'package:prepify/home/profile_screen/recipe_details/recipe_detail_screen.dart';
import 'package:prepify/home/profile_screen/recipe_details/recipe_data.dart';

class BreakfastScreen extends StatelessWidget {
  const BreakfastScreen({super.key});

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

              // Back and Grocery List
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios, color: Colors.green, size: 20),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GroceryListScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.list, size: 18, color: Colors.brown[900]),
                          const SizedBox(width: 5),
                          const Text(
                            "Grocery List",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                "Breakfast",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 20),

              // Recipe Cards
              _buildCategoryRecipeCard(
                context,
                "Egg toast",
                "20 minutes - Easy",
                "assets/images/download (1).jpg",
              ),
              const SizedBox(height: 20),
              _buildCategoryRecipeCard(
                context,
                "Pancakes",
                "15 minutes - Easy",
                "assets/images/Panckaes.jpg",
              ),
              const SizedBox(height: 20),
              _buildCategoryRecipeCard(
                context,
                "Overnight oats",
                "10 minutes - Easy",
                "assets/images/download (2).jpg",
              ),
              const SizedBox(height: 20),
              _buildCategoryRecipeCard(
                context,
                "Chickpeas",
                "22 minutes - Medium",
                "assets/images/Kala Chana Chaat (Black Chickpea Salad).jpg",
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryRecipeCard(BuildContext context, String title, String subtitle, String assetPath) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 280,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        assetPath,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
