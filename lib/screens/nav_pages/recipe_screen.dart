import 'package:flutter/material.dart';
import 'package:prepify/components/custom_app_bar.dart';

class RecipeScreen extends StatelessWidget {
  const RecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Recipes'),
      body: const Center(
        child: Text('Recipe Page'),
      ),
    );
  }
}