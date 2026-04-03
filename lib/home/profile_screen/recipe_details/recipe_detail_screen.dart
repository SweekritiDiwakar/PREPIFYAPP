import 'package:flutter/material.dart';
import 'package:prepify/home/profile_screen/profile_screen.dart';
import 'package:prepify/home/profile_screen/edit_profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:prepify/providers/user_profile_provider.dart';
import 'package:prepify/models/recipe.dart';

class RecipeSection {
  final String? sectionTitle;
  final List<String> ingredients;
  final List<String> steps;

  RecipeSection({
    this.sectionTitle,
    required this.ingredients,
    required this.steps,
  });
}

class RecipeDetailScreen extends StatelessWidget {
  final String title;
  final String imagePath;
  final String duration;
  final String difficulty;
  final List<RecipeSection> sections;
  final Recipe? recipe;

  const RecipeDetailScreen({
    super.key,
    required this.title,
    required this.imagePath,
    required this.duration,
    required this.difficulty,
    required this.sections,
    this.recipe,
  });

  // Factory constructor to create from Recipe model
  factory RecipeDetailScreen.fromRecipe({required Recipe recipe}) {
    return RecipeDetailScreen(
      title: recipe.title,
      imagePath: recipe.imageUrl,
      duration: '30 min', // Default duration
      difficulty: 'Medium', // Default difficulty
      sections: [
        RecipeSection(
          sectionTitle: null,
          ingredients: recipe.ingredients,
          steps: recipe.steps.split('\n').where((step) => step.trim().isNotEmpty).toList(),
        ),
      ],
      recipe: recipe,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // 🔝 Top Bar (Avatar, Logo, Bell)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
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
                          height: 35,
                          width: 35,
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
              ),
              const SizedBox(height: 10),
              // ⬅ Back Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF9CCC65), size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              // Recipe Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Recipe Image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: imagePath.startsWith('assets') 
                    ? Image.asset(
                        imagePath,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        imagePath,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 250,
                            color: Colors.grey[300],
                            child: const Icon(Icons.restaurant, size: 50, color: Colors.grey),
                          );
                        },
                      ),
                ),
              ),
              const SizedBox(height: 12),
              // Duration & Difficulty
              Center(
                child: Text(
                  "$duration - $difficulty",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Recipe Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sections.map((section) => _buildSection(section)).toList(),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Consumer<UserProfileProvider>(
                  builder: (context, provider, _) {
                    return ElevatedButton.icon(
                      onPressed: () async {
                        await provider.incrementCompletedRecipes();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🎉 Recipe Finished! Points added to your profile!'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 3),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                      label: const Text(
                        "Finish Recipe",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD84315),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    );
                  }
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(RecipeSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section.sectionTitle != null) ...[
          const SizedBox(height: 20),
          Row(
            children: [
              if (section.sectionTitle!.contains("Chicken")) 
                const Text("🍗 ", style: TextStyle(fontSize: 18)),
              if (section.sectionTitle!.contains("Rice")) 
                const Text("🍚 ", style: TextStyle(fontSize: 18)),
              Text(
                section.sectionTitle!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 15),
        const Text(
          "Ingredients:",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        ...section.ingredients.map((ing) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("• ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Expanded(
                child: Text(
                  ing,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
              ),
            ],
          ),
        )),
        const SizedBox(height: 20),
        const Text(
          "Steps:",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        ...section.steps.asMap().entries.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${entry.key + 1}. ",
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              Expanded(
                child: Text(
                  entry.value,
                  style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
