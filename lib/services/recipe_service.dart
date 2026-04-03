import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
    await ref.putFile(imageFile);
    final imageUrl = await ref.getDownloadURL();

    if (imageUrl.isEmpty) {
      throw StateError('Image upload failed. Please try again.');
    }

    await _recipes.add({
      'title': safeTitle,
      'ingredients': safeIngredients,
      'steps': safeSteps,
      'imageUrl': imageUrl,
      'createdBy': currentUser.uid,
      'householdId': await UserProfileService.getCurrentUserHouseholdId(),
      'createdAt': FieldValue.serverTimestamp(),
      'likes': 0,
    });

    await SocialService.createPost(
      imageUrl: imageUrl,
      description: 'Check out my new recipe: $safeTitle!\n\nSteps:\n$safeSteps',
      username: username,
    );
  }

  static Future<RecipePageResult> fetchRecipesPage({
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
    int limit = pageSize,
  }) async {
    final householdId = await UserProfileService.getCurrentUserHouseholdId();
    Query<Map<String, dynamic>> query = _recipes
        .where('householdId', isEqualTo: householdId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snap = await query.get();
    final recipes = snap.docs
        .map((doc) => Recipe.fromFirestore(doc.id, doc.data()))
        .toList();

    return RecipePageResult(
      recipes: recipes,
      lastDocument: snap.docs.isNotEmpty ? snap.docs.last : startAfter,
      hasMore: snap.docs.length == limit,
    );
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
