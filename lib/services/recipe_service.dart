import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:prepify/models/recipe.dart';
import 'package:prepify/services/user_profile_service.dart';
import 'package:prepify/services/social_service.dart';

class RecipeService {
  RecipeService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static CollectionReference<Map<String, dynamic>> get _recipes =>
      _db.collection('recipes');

  static const int pageSize = 10;

  static Future<void> uploadRecipe({
    required String title,
    required String category,
    required List<String> ingredients,
    required String steps,
    required File imageFile,
    required String username,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('You must be logged in to upload recipes.');
    }

    final safeTitle = title.trim();
    final safeIngredients = ingredients
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    final safeSteps = steps.trim();

    if (safeTitle.isEmpty || safeIngredients.isEmpty || safeSteps.isEmpty) {
      throw ArgumentError('Please fill all recipe fields.');
    }

    final storagePath =
        'recipes/${currentUser.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child(storagePath);
    try {
      await ref.putFile(imageFile);
    } catch (e) {
      debugPrint('RecipeService: Storage upload failed: $e');
      throw StateError('Image upload failed. Check your internet connection and try again.');
    }
    final imageUrl = await ref.getDownloadURL();

    if (imageUrl.isEmpty) {
      throw StateError('Image upload failed. Please try again.');
    }

    String householdId = '';
    try {
      householdId = await UserProfileService.getCurrentUserHouseholdId();
    } catch (e) {
      // Create a default household if none exists
      householdId = currentUser.uid;
      await UserProfileService.updateHouseholdId(uid: currentUser.uid, householdId: householdId);
    }

    final userId = currentUser.uid;
    await _recipes.add({
      'id': '',
      'title': safeTitle,
      'category': category,
      'ingredients': safeIngredients,
      'steps': safeSteps,
      'imageUrl': imageUrl,
      'userId': userId,
      'createdBy': userId,
      'householdId': householdId,
      'createdAt': FieldValue.serverTimestamp(),
      'likes': 0,
      'likesCount': 0,
    });

    await SocialService.createPost(
      imageUrl: imageUrl,
      description: 'Check out my new recipe: $safeTitle!\n\nCategory: $category\n\nSteps:\n$safeSteps',
      category: category,
      username: username,
    );

    // Badge awarding is now handled by UserProfileProvider
  }

  static Future<RecipePageResult> fetchRecipesPage({
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
    int limit = pageSize,
  }) async {
    String householdId = '';
    try {
      householdId = await UserProfileService.getCurrentUserHouseholdId();
    } catch (e) {
      debugPrint('RecipeService: Could not get householdId: $e');
    }

    try {
      Query<Map<String, dynamic>> query;
      if (householdId.isNotEmpty) {
        // Get both household recipes and user's personal recipes
        final householdSnap = await _recipes
            .where('householdId', isEqualTo: householdId)
            .limit(limit)
            .get();
            
        final userSnap = await _recipes
            .where('createdBy', isEqualTo: _auth.currentUser?.uid ?? '')
            .limit(limit)
            .get();
            
        // Combine and deduplicate results
        final allDocs = {...householdSnap.docs, ...userSnap.docs}.toList();
        
        return RecipePageResult(
          recipes: allDocs.map((doc) => Recipe.fromFirestore(doc.id, doc.data())).toList(),
          hasMore: false,
          lastDocument: allDocs.isNotEmpty ? allDocs.last : null,
        );
      } else {
        query = _recipes.orderBy('createdAt', descending: true).limit(limit);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snap = await query.get();

      var recipes = snap.docs
          .map((doc) {
            try {
              return Recipe.fromFirestore(doc.id, doc.data());
            } catch (e) {
              debugPrint('RecipeService: Failed to parse recipe ${doc.id}: $e');
              return null;
            }
          })
          .whereType<Recipe>()
          .toList();

      // Sort client-side by createdAt descending
      recipes.sort((a, b) {
        final aTs = a.createdAt?.seconds ?? 0;
        final bTs = b.createdAt?.seconds ?? 0;
        return bTs.compareTo(aTs);
      });

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

  static Future<void> likeRecipe(String recipeId) async {
    await _recipes.doc(recipeId).update({
      'likes': FieldValue.increment(1),
    });
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
