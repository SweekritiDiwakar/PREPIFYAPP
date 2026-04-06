import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:prepify/home/profile_screen/profile_screen.dart';
import 'package:prepify/home/profile_screen/edit_profile_screen.dart';
import 'package:prepify/providers/recipe_provider.dart';
import 'package:prepify/providers/user_profile_provider.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _stepsController = TextEditingController();
  final List<TextEditingController> _ingredientsControllers = [
    TextEditingController()
  ];
  File? _selectedImage;
  String _selectedCategory = 'Veg';
  final List<String> _categories = [
    'Veg',
    'Non-Veg',
    'Snacks',
    'Nepali Cuisine',
    'Dessert',
    'Drinks',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _stepsController.dispose();
    for (final c in _ingredientsControllers) {
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

  Future<void> _pickRecipeImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() {
      _selectedImage = File(picked.path);
    });
  }

  Future<void> _handleUpload() async {
    final title = _titleController.text.trim();
    final steps = _stepsController.text.trim();
    final ingredients = _ingredientsControllers
        .map((c) => c.text.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    if (title.isEmpty || steps.isEmpty || ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a recipe image.')),
      );
      return;
    }

    final provider = context.read<RecipeProvider>();
    final userProfileProvider = context.read<UserProfileProvider>();
    final userProfile = userProfileProvider.user;
    final username = userProfile?.name ?? 'Anonymous User';

    try {
      final success = await provider.uploadRecipe(
        title: title,
        category: _selectedCategory,
        ingredients: ingredients,
        steps: steps,
        imageFile: _selectedImage!,
        username: username,
      );

      if (!mounted) return;

      if (success) {
        await userProfileProvider.incrementCompletedRecipes();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recipe uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        final errorMsg = provider.errorMessage ?? 'Upload failed. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
              // 🔝 Top Bar
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
                      Image.asset('assets/images/logo.png', height: 30),
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
              _inputField(controller: _titleController, hint: "e.g. Butter chicken and naan"),
              const SizedBox(height: 24),
              _sectionTitle("Category"),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F3),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    items: _categories
                        .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle("Add Picture"),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickRecipeImage,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                      : const Center(
                          child: Icon(Icons.add_photo_alternate, size: 56, color: Colors.grey),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle("Steps"),
              const SizedBox(height: 12),
              _inputField(controller: _stepsController, hint: "Write the cooking steps...", maxLines: 6),
              const SizedBox(height: 32),
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
              Center(
                child: SizedBox(
                  width: 200,
                  child: Consumer<RecipeProvider>(
                    builder: (context, provider, _) {
                      return ElevatedButton(
                        onPressed: provider.isLoading ? null : _handleUpload,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFAED581),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: provider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                              )
                            : const Text(
                                "Upload Recipe",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'serif'),
                              ),
                      );
                    },
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

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'serif', color: Colors.black),
      ),
    );
  }

  Widget _inputField({String? hint, int maxLines = 1, TextEditingController? controller}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF5F5F3), borderRadius: BorderRadius.circular(20)),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _numberBubble(int number) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: const Color(0xFFF5F5F3), borderRadius: BorderRadius.circular(15)),
      child: Center(
        child: Text(
          "$number.",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 16),
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
          backgroundColor: const Color(0xFFAED581).withAlpha(180),
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }
}