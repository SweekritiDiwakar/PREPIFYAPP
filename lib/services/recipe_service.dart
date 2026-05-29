import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:prepify/models/recipe.dart';
import 'package:prepify/services/cloudinary_service.dart';
import 'package:prepify/services/social_service.dart';
import 'package:prepify/services/gamification_service.dart';

class RecipeService {
  RecipeService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _recipes =>
      _db.collection('recipes');

  static const int pageSize = 10;

  static Future<void> uploadRecipe({
    required String title,
    required String description,
    required List<String> ingredients,
    required List<String> steps,
    required List<String> tags,
    required File imageFile,
    required String username,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('You must be logged in to upload recipes.');
    }

    final safeTitle = title.trim();
    final safeDescription = description.trim();
    final safeIngredients = ingredients
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    final safeSteps = steps
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    final safeTags = tags
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    if (safeTitle.isEmpty || safeIngredients.isEmpty || safeSteps.isEmpty) {
      throw ArgumentError('Please fill all recipe fields.');
    }

    final imageUrl = await CloudinaryService.uploadImage(imageFile);

    final userId = currentUser.uid;
    final docRef = await _recipes.add({
      'title': safeTitle,
      'description': safeDescription,
      'ingredients': safeIngredients,
      'steps': safeSteps,
      'imageUrl': imageUrl,
      'createdBy': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'likes': 0,
      'tags': safeTags,
    });

    try {
      await SocialService.createPost(
        recipeId: docRef.id,
        imageUrl: imageUrl,
        description:
            'Check out my new recipe: $safeTitle!\n\n$safeDescription\n\nTags: ${safeTags.join(', ')}',
        category: safeTags.isNotEmpty ? safeTags.first : 'General',
        username: username,
      );

      // Award gamification badge for uploading a recipe
      await GamificationService.awardBadge('recipe_creator');
    } catch (e) {
      debugPrint('Error creating social post or awarding badge: $e');
    }
  }

  static Future<Recipe> updateRecipe({
    required Recipe recipe,
    required String title,
    required String description,
    required List<String> ingredients,
    required List<String> steps,
    required List<String> tags,
    File? imageFile,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('You must be logged in to edit recipes.');
    }

    if (recipe.createdBy != currentUser.uid) {
      throw StateError('You can only edit your own recipes.');
    }

    final safeTitle = title.trim();
    final safeDescription = description.trim();
    final safeIngredients = ingredients
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    final safeSteps = steps
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    final safeTags = tags
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    if (safeTitle.isEmpty || safeIngredients.isEmpty || safeSteps.isEmpty) {
      throw ArgumentError('Please fill all recipe fields.');
    }

    final imageUrl = imageFile != null
        ? await CloudinaryService.uploadImage(imageFile)
        : recipe.imageUrl.trim();

    if (imageUrl.isEmpty) {
      throw ArgumentError('Please add a recipe image.');
    }

    final updatedRecipe = recipe.copyWith(
      title: safeTitle,
      description: safeDescription,
      ingredients: safeIngredients,
      steps: safeSteps,
      imageUrl: imageUrl,
      tags: safeTags,
    );

    await _recipes.doc(recipe.id).update({
      'title': safeTitle,
      'description': safeDescription,
      'ingredients': safeIngredients,
      'steps': safeSteps,
      'imageUrl': imageUrl,
      'tags': safeTags,
    });

    return updatedRecipe;
  }

  static Future<void> deleteRecipe(String recipeId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('You must be logged in to delete recipes.');
    }

    final doc = await _recipes.doc(recipeId).get();
    if (!doc.exists) {
      throw StateError('Recipe not found.');
    }

    final recipe = Recipe.fromFirestore(doc.id, doc.data() ?? {});
    if (recipe.createdBy != currentUser.uid) {
      throw StateError('You can only delete your own recipes.');
    }

    await _recipes.doc(recipeId).delete();

    try {
      await SocialService.deleteRecipePost(
        recipeId: recipeId,
        userId: currentUser.uid,
        imageUrl: recipe.imageUrl,
        title: recipe.title,
      );
    } catch (e) {
      debugPrint('Error deleting recipe post: $e');
    }
  }

  // Stream for real-time updates (e.g. for user's own recipes)
  static Stream<List<Recipe>> streamUserRecipes() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _recipes
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Recipe.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  static Future<RecipePageResult> fetchRecipesPage({
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
    int limit = pageSize,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _recipes
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snap = await query.get();

      var recipes = snap.docs
          .map((doc) => Recipe.fromFirestore(doc.id, doc.data()))
          .toList();

      return RecipePageResult(
        recipes: recipes,
        lastDocument: snap.docs.isNotEmpty ? snap.docs.last : startAfter,
        hasMore: snap.docs.length == limit,
      );
    } catch (e) {
      debugPrint('RecipeService.fetchRecipesPage error: $e');
      rethrow;
    }
  }

  // Search and filter recipes
  static Future<List<Recipe>> searchRecipes({
    String? queryText,
    List<String>? ingredientsList,
    List<String>? tagsList,
  }) async {
    try {
      // Note: Firestore does not support multiple array-contains.
      // A common workaround is fetching and client-side filtering if complex, or using a third-party service like Algolia.
      // Here we will do basic fetching and client-side filtering for simplicity and robustness.
      final snap = await _recipes.orderBy('createdAt', descending: true).get();

      var recipes = snap.docs
          .map((doc) => Recipe.fromFirestore(doc.id, doc.data()))
          .toList();

      if (queryText != null && queryText.isNotEmpty) {
        final queryLower = queryText.toLowerCase();
        recipes = recipes
            .where(
              (r) =>
                  r.title.toLowerCase().contains(queryLower) ||
                  r.description.toLowerCase().contains(queryLower),
            )
            .toList();
      }

      if (ingredientsList != null && ingredientsList.isNotEmpty) {
        recipes = recipes
            .where(
              (r) => ingredientsList.every(
                (ing) => r.ingredients.any(
                  (ri) => ri.toLowerCase().contains(ing.toLowerCase()),
                ),
              ),
            )
            .toList();
      }

      if (tagsList != null && tagsList.isNotEmpty) {
        recipes = recipes
            .where(
              (r) => tagsList.every(
                (tag) =>
                    r.tags.any((rt) => rt.toLowerCase() == tag.toLowerCase()),
              ),
            )
            .toList();
      }

      return recipes;
    } catch (e) {
      debugPrint('RecipeService.searchRecipes error: $e');
      rethrow;
    }
  }

  static Future<void> likeRecipe(String recipeId) async {
    await _recipes.doc(recipeId).update({'likes': FieldValue.increment(1)});
  }

  static Future<Recipe?> fetchRecipeById(String recipeId) async {
    final trimmedId = recipeId.trim();
    if (trimmedId.isEmpty) {
      return null;
    }

    final doc = await _recipes.doc(trimmedId).get();
    if (!doc.exists) {
      return null;
    }

    return Recipe.fromFirestore(doc.id, doc.data() ?? {});
  }

  static Future<Recipe?> fetchRecipeByImageUrl(String imageUrl) async {
    final trimmed = imageUrl.trim();
    if (trimmed.isEmpty) return null;

    final query = await _recipes.where('imageUrl', isEqualTo: trimmed).limit(1).get();
    if (query.docs.isEmpty) return null;
    final doc = query.docs.first;
    return Recipe.fromFirestore(doc.id, doc.data());
  }
}

class RecipePageResult {
  const RecipePageResult({
    required this.recipes,
    required this.lastDocument,
    required this.hasMore,
  });

  final List<Recipe> recipes;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  final bool hasMore;
}
