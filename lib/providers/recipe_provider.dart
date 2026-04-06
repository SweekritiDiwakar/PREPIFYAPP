import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:prepify/models/recipe.dart';
import 'package:prepify/services/recipe_service.dart';

class RecipeProvider extends ChangeNotifier {
  List<Recipe> _recipesList = <Recipe>[];
  bool _isLoading = false;
  bool _isFetchingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  DocumentSnapshot<Map<String, dynamic>>? _lastDocument;

  List<Recipe> get recipesList => _recipesList;
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;

  Future<void> fetchRecipes() async {
    _setLoading(true);
    _errorMessage = null;
    _lastDocument = null;
    _hasMore = true;
    try {
      final page = await RecipeService.fetchRecipesPage();
      _recipesList = page.recipes;
      _lastDocument = page.lastDocument;
      _hasMore = page.hasMore;
    } catch (e) {
      debugPrint('RecipeProvider.fetchRecipes error: $e');
      _errorMessage = 'Unable to load recipes. Please check your connection.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMoreRecipes() async {
    if (_isLoading || _isFetchingMore || !_hasMore) return;
    _isFetchingMore = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final page = await RecipeService.fetchRecipesPage(
        startAfter: _lastDocument,
      );
      _recipesList = [..._recipesList, ...page.recipes];
      _lastDocument = page.lastDocument;
      _hasMore = page.hasMore;
    } catch (e) {
      _errorMessage = 'Unable to load more recipes.';
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  Future<bool> uploadRecipe({
    required String title,
    required String category,
    required List<String> ingredients,
    required String steps,
    required File imageFile,
    required String username,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await RecipeService.uploadRecipe(
        title: title,
        category: category,
        ingredients: ingredients,
        steps: steps,
        imageFile: imageFile,
        username: username,
      );
      // Refresh list after upload — don't let a fetch failure block success
      try {
        await fetchRecipes();
      } catch (_) {
        // Fetch failing doesn't mean upload failed
        _setLoading(false);
      }
      return true;
    } catch (e) {
      debugPrint('RecipeProvider.uploadRecipe error: $e');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<void> likeRecipe(String recipeId) async {
    try {
      await RecipeService.likeRecipe(recipeId);
      final index = _recipesList.indexWhere((recipe) => recipe.id == recipeId);
      if (index != -1) {
        final current = _recipesList[index];
        _recipesList[index] = current.copyWith(likes: current.likes + 1);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to like recipe.';
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
