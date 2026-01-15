import 'package:flutter/material.dart';
import 'package:prepify/home/notification_screen/notification_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
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
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AppNotificationScreen()),
                      ),
                      child: const Icon(Icons.notifications, size: 28, color: Colors.black),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                const SizedBox(height: 20),
                
                // Grocery List Button
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                       Icon(Icons.format_list_bulleted, color: Color(0xFFD84315)),
                       SizedBox(width: 8),
                       Text(
                         'Grocery List',
                         style: TextStyle(
                           fontSize: 14,
                           fontWeight: FontWeight.bold,
                           color: Colors.black87,
                           fontFamily: 'Serif', 
                         ),
                       ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // "Today's dish" Title
                const Text(
                  "Today's dish",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Serif',
                    color: Colors.black, // Explicitly black
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Dish Card
                _buildDishCard(
                   imagePath: 'assets/images/butternaan.jpeg', 
                   title: 'Butter naan and chicken',
                   subtitle: '1.5 hours · Medium',
                ),
                
                const SizedBox(height: 30),
                
                // Second Card
                 _buildDishCard(
                   imagePath: 'assets/images/muffin.jpeg', 
                   title: 'Chocolate Muffins',
                   subtitle: '45 mins · Easy',
                ),
                 const SizedBox(height: 80), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildDishCard({required String imagePath, required String title, required String subtitle}) {
    return Column(
      children: [
        Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Serif',
            color: Colors.black, // Explicitly black
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}