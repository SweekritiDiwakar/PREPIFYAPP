import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prepify/providers/recipe_provider.dart';
import 'package:prepify/home/profile_screen/recipe_details/recipe_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _ingredientController = TextEditingController();

  List<String> _selectedFilters = [];

  void _performSearch() {
    FocusScope.of(context).unfocus();
    final query = _searchController.text.trim();
    final ingredient = _ingredientController.text.trim();

    List<String> ingredients = [];
    if (ingredient.isNotEmpty) ingredients.add(ingredient);

    context.read<RecipeProvider>().searchRecipes(
      query: query,
      ingredients: ingredients,
      tags: _selectedFilters.isNotEmpty ? _selectedFilters : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Search Recipes',
          style: TextStyle(color: Colors.black, fontFamily: 'serif'),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by title or description...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _ingredientController,
                    decoration: InputDecoration(
                      hintText: 'Must contain ingredient (e.g. Chicken)',
                      prefixIcon: const Icon(Icons.kitchen),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children:
                          [
                            'Veg',
                            'Non-Veg',
                            'Nepali Cuisine',
                            'Snacks',
                            'Dessert',
                            'Drinks',
                          ].map((tag) {
                            final isSelected = _selectedFilters.contains(tag);
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChip(
                                label: Text(tag),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedFilters.add(tag);
                                    } else {
                                      _selectedFilters.remove(tag);
                                    }
                                  });
                                  _performSearch();
                                },
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<RecipeProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.errorMessage != null) {
                    return Center(child: Text(provider.errorMessage!));
                  }

                  final recipes = provider.recipesList;

                  if (recipes.isEmpty) {
                    return const Center(
                      child: Text(
                        'No recipes found. Try modifying your search criteria.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: (recipe.imageUrl.isNotEmpty)
                              ? Image.network(
                                  recipe.imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[300],
                                  ),
                                )
                              : Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[300],
                                ),
                        ),
                        title: Text(
                          recipe.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          recipe.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RecipeDetailScreen.fromRecipe(recipe: recipe),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
