import 'package:flutter/material.dart';
import 'package:prepify/home/profile_screen/profile_screen.dart';
import 'package:prepify/home/profile_screen/edit_profile_screen.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<TextEditingController> _ingredientsControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> _instructionsControllers = [
    TextEditingController()
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final c in _ingredientsControllers) {
      c.dispose();
    }
    for (final c in _instructionsControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addIngredient() {
    setState(() => _ingredientsControllers.add(TextEditingController()));
  }

  void _removeIngredient(int index) {
    if (_ingredientsControllers.length > 1) {
      setState(() {
        _ingredientsControllers[index].dispose();
        _ingredientsControllers.removeAt(index);
      });
    }
  }

  void _addInstruction() {
    setState(() => _instructionsControllers.add(TextEditingController()));
  }

  void _removeInstruction(int index) {
    if (_instructionsControllers.length > 1) {
      setState(() {
        _instructionsControllers[index].dispose();
        _instructionsControllers.removeAt(index);
      });
    }
  }

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
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                      );
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: const AssetImage('assets/images/me.jpeg'),
                    ),
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

              const SizedBox(height: 16),

              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF9CCC65), size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),

              const SizedBox(height: 16),

              const Text(
                "Upload Recipe",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 24),

              _sectionTitle("Recipe Title"),
              const SizedBox(height: 12),
              _inputField(
                controller: _titleController,
                hint: "e.g. Butter chicken and naan",
              ),

              const SizedBox(height: 24),

              _sectionTitle("Add Picture"),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Icon(
                    Icons.add_photo_alternate,
                    size: 56,
                    color: Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              _sectionTitle("Description"),
              const SizedBox(height: 12),
              _inputField(
                controller: _descriptionController,
                hint: "Tell us little about your recipe..",
                maxLines: 4,
              ),

              const SizedBox(height: 32),

              /// 🧂 Ingredients
              _sectionTitle("Ingredients"),
              const SizedBox(height: 8),
              ...List.generate(_ingredientsControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      _numberBubble(index + 1),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _inputField(
                          controller: _ingredientsControllers[index],
                          hint: index == 0 ? "e.g. 1 cup milk" : "e.g. 2 tbsp sugar",
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _removeIngredient(index),
                        icon: const Icon(Icons.delete, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }),

              _pillButton("Add ingredients", _addIngredient),

              const SizedBox(height: 32),


              /// 📝 Instructions Section (Below the bar in Figma)
              _sectionTitle("Instructions"),
              const SizedBox(height: 8),
              ...List.generate(_instructionsControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _numberBubble(index + 1),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _inputField(
                          controller: _instructionsControllers[index],
                          hint: "Describe the step..",
                          maxLines: 3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _removeInstruction(index),
                        icon: const Icon(Icons.delete, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }),

              _pillButton("Add instruction", _addInstruction),

              const SizedBox(height: 48),

              /// 🚀 Final Upload Button
              Center(
                child: SizedBox(
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
                      "Upload Recipe",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'serif',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 UI helpers

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'serif',
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _inputField({
    String? hint,
    int maxLines = 1,
    TextEditingController? controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _numberBubble(int number) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Text(
          "$number.",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _pillButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFAED581).withOpacity(0.5),
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
