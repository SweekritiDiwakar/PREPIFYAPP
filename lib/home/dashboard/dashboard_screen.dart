import 'package:flutter/material.dart';
import 'package:prepify/home/notification_screen/notification_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Top Bar: Avatar, Logo, Bell
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: const AssetImage('assets/images/me.jpeg'),
                      backgroundColor: Colors.grey[200],
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
                          MaterialPageRoute(builder: (context) => const AppNotificationScreen()),
                        );
                      },
                      child: const Icon(Icons.notifications, size: 28, color: Colors.black),
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
                    _buildQuickLink("Grocery List", Icons.format_list_bulleted, true),
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
                        'assets/images/butternaan.jpeg',
                        'Butter naan and chicken',
                        '1.5 hours · Medium',
                      ),
                      const SizedBox(width: 15),
                      _buildHorizontalDishCard(
                        'assets/images/muffin.jpeg',
                        'Chocolate Muffins',
                        '45 mins · Easy',
                      ),
                      const SizedBox(width: 15),
                      _buildHorizontalDishCard(
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
                const SizedBox(height: 15),
                
                // Naomi's Post
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 12,
                            backgroundImage: AssetImage('assets/images/download (6).jpeg'),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Naomi",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/Garlicbread.jpeg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Recipe!",
                        style: TextStyle(fontSize: 10, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Icon(Icons.favorite_border, size: 20, color: Colors.black54),
                          Icon(Icons.chat_bubble_outline, size: 20, color: Colors.black54),
                          Icon(Icons.share, size: 20, color: Colors.black54),
                        ],
                      ),
                    ],
                  ),
                ),
                
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

  Widget _buildHorizontalDishCard(String assetPath, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 180,
          width: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: AssetImage(assetPath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Serif',
            color: Colors.black,
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
      ],
    );
  }
}
