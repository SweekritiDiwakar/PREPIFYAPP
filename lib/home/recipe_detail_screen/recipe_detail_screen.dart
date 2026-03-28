import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prepify/models/recipe.dart';
import 'package:prepify/providers/recipe_provider.dart';

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({
    super.key,
    required this.recipe,
  });

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
      ),
      body: Consumer<RecipeProvider>(
        builder: (context, provider, _) {
          final index = provider.recipesList.indexWhere(
            (item) => item.id == recipe.id,
          );
          final liveRecipe = index >= 0 ? provider.recipesList[index] : recipe;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    liveRecipe.imageUrl,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 220,
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        liveRecipe.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => provider.likeRecipe(liveRecipe.id),
                      icon: const Icon(Icons.favorite_border),
                    ),
                    Text('${liveRecipe.likes}'),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ingredients',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ...liveRecipe.ingredients.map(
                  (ingredient) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('- $ingredient'),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Steps',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  liveRecipe.steps,
                  style: const TextStyle(height: 1.5),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
