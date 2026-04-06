import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prepify/home/profile_screen/edit_profile_screen.dart';
import 'package:prepify/home/profile_screen/profile_screen.dart';
import 'package:prepify/home/search_screen/breakfast_screen.dart';
import 'package:prepify/home/search_screen/lunch_screen.dart';
import 'package:prepify/home/search_screen/dinner_screen.dart';
import 'package:prepify/home/search_screen/snacks_screen.dart';
import 'package:prepify/home/profile_screen/recipe_details/recipe_detail_screen.dart';
import 'package:prepify/home/profile_screen/recipe_details/recipe_data.dart';
import 'package:prepify/home/recipe_detail_screen/recipe_detail_screen.dart'
    as firestore_detail;
import 'package:prepify/models/recipe.dart';
import 'package:prepify/services/recipe_service.dart';
import 'package:prepify/services/user_profile_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: const AssetImage('assets/images/me.jpeg'),
                          backgroundColor: Colors.grey[200],
                        ),
                      ),
                      Column(
                        children: [
                          Image.asset('assets/images/logo.png', height: 40, width: 40),
                          const SizedBox(height: 2),
                          const Text('PREPIFY',
                              style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                  color: Colors.black87)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => ProfileScreen())),
                        child: const Icon(Icons.settings, size: 28, color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Search Recipe',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Serif',
                          color: Colors.black)),
                  const SizedBox(height: 16),
                  // Live search bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.black),
                      onChanged: (val) => setState(() => _query = val.trim()),
                      decoration: InputDecoration(
                        hintText: 'Search by title, ingredient, or category...',
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                        icon: const Icon(Icons.search, color: Colors.grey, size: 22),
                        border: InputBorder.none,
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _query = '');
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Expanded(
              child: _query.isEmpty
                  ? _buildDefaultContent(context)
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Default view: categories + popular + recommendations ──────────────────

  Widget _buildDefaultContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories
          const Text('Categories',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                  color: Colors.black)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCategory(context, 'Breakfast', Icons.coffee, const Color(0xFFFBE9E7),
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BreakfastScreen()))),
              _buildCategory(context, 'Lunch', Icons.restaurant, const Color(0xFFE8EAF6),
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LunchScreen()))),
              _buildCategory(context, 'Dinner', Icons.wine_bar, const Color(0xFFF3E5F5),
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DinnerScreen()))),
              _buildCategory(context, 'Snacks', Icons.cookie, const Color(0xFFEFEBE9),
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SnacksScreen()))),
            ],
          ),
          const SizedBox(height: 30),

          // Stock-based recommendations
          _StockRecommendations(),

          const SizedBox(height: 30),

          // Popular Recipes (static)
          const Text('Popular Recipes',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                  color: Colors.black)),
          const SizedBox(height: 15),
          _buildRecipeItem(context, 'Garlic bread', 'assets/images/Garlicbread.jpeg'),
          const SizedBox(height: 15),
          _buildRecipeItem(context, 'Butter naan and chicken', 'assets/images/butternaan.jpeg'),
          const SizedBox(height: 15),
          _buildRecipeItem(context, 'Chocolate chip cookies', 'assets/images/muffin.jpeg'),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ── Live Firestore search results ─────────────────────────────────────────

  Widget _buildSearchResults() {
    final q = _query.toLowerCase();
    return FutureBuilder<List<Recipe>>(
      future: _searchRecipes(q),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final results = snapshot.data ?? [];
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 56, color: Colors.grey),
                const SizedBox(height: 12),
                Text('No recipes found for "$_query"',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: results.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final recipe = results[index];
            return _FirestoreRecipeCard(recipe: recipe);
          },
        );
      },
    );
  }

  Future<List<Recipe>> _searchRecipes(String query) async {
    try {
      // Fetch all household recipes then filter client-side
      // (Firestore doesn't support full-text search natively)
      final page = await RecipeService.fetchRecipesPage(limit: 100);
      final all = page.recipes;
      return all.where((r) {
        final titleMatch = r.title.toLowerCase().contains(query);
        final categoryMatch = r.category.toLowerCase().contains(query);
        final ingredientMatch =
            r.ingredients.any((ing) => ing.toLowerCase().contains(query));
        return titleMatch || categoryMatch || ingredientMatch;
      }).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Shared UI helpers ─────────────────────────────────────────────────────

  Widget _buildCategory(BuildContext context, String label, IconData icon,
      Color bgColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 65,
            width: 65,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: Colors.brown[900], size: 30),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildRecipeItem(BuildContext context, String title, String assetPath) {
    return GestureDetector(
      onTap: () {
        final recipe = RecipeData.allRecipes[title];
        if (recipe != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecipeDetailScreen(
                title: recipe['name'],
                imagePath: recipe['image'],
                duration: recipe['duration'],
                difficulty: recipe['difficulty'],
                sections: recipe['sections'],
              ),
            ),
          );
        }
      },
      child: Container(
        height: 90,
        decoration: BoxDecoration(
            color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
              child: Image.asset(assetPath, width: 100, height: 90, fit: BoxFit.cover),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stock-based recipe recommendations ────────────────────────────────────────

class _StockRecommendations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Recipe>>(
      future: _getStockBasedRecommendations(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final recs = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFF9CCC65), size: 20),
                const SizedBox(width: 8),
                const Text('Recommended for You',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Serif',
                        color: Colors.black)),
              ],
            ),
            const SizedBox(height: 6),
            const Text('Based on your available stock',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: recs.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final recipe = recs[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            firestore_detail.RecipeDetailScreen(recipe: recipe),
                      ),
                    ),
                    child: Container(
                      width: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey[100],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16)),
                            child: recipe.imageUrl.isNotEmpty
                                ? Image.network(recipe.imageUrl,
                                    height: 100,
                                    width: 140,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) => Container(
                                        height: 100,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.restaurant,
                                            color: Colors.grey)))
                                : Container(
                                    height: 100,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.restaurant,
                                        color: Colors.grey)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              recipe.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<Recipe>> _getStockBasedRecommendations() async {
    try {
      // Get available stock items
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return [];
      final householdId = await UserProfileService.getCurrentUserHouseholdId();
      if (householdId.isEmpty) return [];

      final stockSnap = await FirebaseFirestore.instance
          .collection('stock')
          .where('householdId', isEqualTo: householdId)
          .get();

      final availableIngredients = stockSnap.docs
          .map((d) => ((d.data()['itemName'] as String?) ?? '').toLowerCase().trim())
          .where((n) => n.isNotEmpty)
          .toSet();

      if (availableIngredients.isEmpty) return [];

      // Fetch household recipes
      final page = await RecipeService.fetchRecipesPage(limit: 50);
      final recipes = page.recipes;

      // Score each recipe by how many ingredients match available stock
      final scored = <MapEntry<Recipe, int>>[];
      for (final recipe in recipes) {
        final matchCount = recipe.ingredients
            .where((ing) => availableIngredients.any(
                (stock) => ing.toLowerCase().contains(stock) || stock.contains(ing.toLowerCase())))
            .length;
        if (matchCount > 0) {
          scored.add(MapEntry(recipe, matchCount));
        }
      }

      // Sort by match count descending, return top 10
      scored.sort((a, b) => b.value.compareTo(a.value));
      return scored.take(10).map((e) => e.key).toList();
    } catch (_) {
      return [];
    }
  }
}

// ── Firestore recipe search result card ───────────────────────────────────────

class _FirestoreRecipeCard extends StatelessWidget {
  const _FirestoreRecipeCard({required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => firestore_detail.RecipeDetailScreen(recipe: recipe),
        ),
      ),
      child: Container(
        height: 90,
        decoration: BoxDecoration(
            color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
              child: recipe.imageUrl.isNotEmpty
                  ? Image.network(recipe.imageUrl,
                      width: 100,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                          width: 100,
                          height: 90,
                          color: Colors.grey[300],
                          child: const Icon(Icons.restaurant, color: Colors.grey)))
                  : Container(
                      width: 100,
                      height: 90,
                      color: Colors.grey[300],
                      child: const Icon(Icons.restaurant, color: Colors.grey)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 4),
                  if (recipe.category.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF1F8E9),
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(recipe.category,
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF558B2F))),
                    ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
