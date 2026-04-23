import 'package:flutter/material.dart';
import 'package:prepify/home/profile_screen/user_profile_screen.dart';
import 'package:prepify/home/grocery_list_screen/grocery_list_screen.dart';
import 'package:prepify/home/profile_screen/recipe_details/recipe_detail_screen.dart';
import 'package:prepify/home/profile_screen/recipe_details/recipe_data.dart';
import 'package:prepify/home/social_feed/social_feed_list.dart';
import 'package:prepify/screens/settings_screen.dart';
import 'package:prepify/screens/main_chat_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MainChatScreen()),
          );
        },
        backgroundColor: const Color(0xFFD84315),
        tooltip: 'Open chat',
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 26),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Top Bar: Avatar, Logo, Settings
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const UserProfileScreen())),
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
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen())),
                      child: const Icon(Icons.settings, size: 28, color: Colors.black),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const SizedBox(height: 20),

                const Text(
                  "Welcome back!",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Serif',
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 30),

                // Reminders Section
                const Text(
                  "Reminders",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBE9E7), // Light reddish/pink bg
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_cart, color: Color(0xFFD84315), size: 36),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Weekly grocery run!",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: 'Serif',
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "Friday, 5:00pm",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Quick Links
                const Text(
                  "Quick links",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const GroceryListScreen()),
                        );
                      },
                      child: _buildQuickLink("Grocery List", Icons.format_list_bulleted, true),
                    ),
                    const SizedBox(width: 15),
                    _buildQuickLink("My profile", null, false),
                  ],
                ),

                const SizedBox(height: 30),

                // Your friends
                const Text(
                  "Your friends",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildFriendAvatar('assets/images/eden mccrorey.jpeg'),
                      const SizedBox(width: 15),
                      _buildFriendAvatar('assets/images/five survive _ arthur.jpeg'),
                      const SizedBox(width: 15),
                      _buildFriendAvatar('assets/images/five survive _ red.jpeg'),
                      const SizedBox(width: 15),
                      _buildFriendAvatar('assets/images/Bing Image Creator.jpeg'),
                      const SizedBox(width: 15),
                      _buildFriendAvatar('assets/images/download (5).jpeg'),
                      const SizedBox(width: 15),
                      _buildFriendAvatar('assets/images/me.jpeg'),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Today's dish
                const Text(
                  "Today's dish",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Serif',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildHorizontalDishCard(
                        context,
                        'assets/images/butternaan.jpeg',
                        'Butter naan and chicken',
                        '1.5 hours · Medium',
                      ),
                      const SizedBox(width: 15),
                      _buildHorizontalDishCard(
                        context,
                        'assets/images/muffin.jpeg',
                        'Chocolate Muffins',
                        '45 mins · Easy',
                      ),
                      const SizedBox(width: 15),
                      _buildHorizontalDishCard(
                        context,
                        'assets/images/Garlicbread.jpeg',
                        'Garlic Bread',
                        '20 mins · Easy',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Delicious Food
                const Text(
                  "Delicious food",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Serif',
                    color: Colors.black,
                  ),
                ),
                // Social Feed
                const SocialFeedList(),
                
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLink(String text, IconData? icon, bool isHighlighted) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 22, color: const Color(0xFFD84315)),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'Serif',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendAvatar(String assetPath) {
    return CircleAvatar(
      radius: 32,
      backgroundImage: AssetImage(assetPath),
      backgroundColor: Colors.grey[300],
    );
  }

  Widget _buildHorizontalDishCard(BuildContext context, String assetPath, String title, String subtitle) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 70) * 0.8; // Responsive width
    
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            width: cardWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: AssetImage(assetPath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: cardWidth,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Serif',
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: cardWidth,
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
