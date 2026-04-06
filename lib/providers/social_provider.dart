import 'package:flutter/material.dart';
import 'package:prepify/services/social_service.dart';

class SocialProvider extends ChangeNotifier {
  final Map<String, bool> _likedPosts = {};
  final Map<String, bool> _favoritedPosts = {};

  bool isLiked(String postId) => _likedPosts[postId] ?? false;
  bool isFavorited(String postId) => _favoritedPosts[postId] ?? false;

  Future<void> checkLikeStatus(String postId, String userId) async {
    if (_likedPosts.containsKey(postId)) return;
    try {
      final liked = await SocialService.isPostLikedByUser(postId, userId);
      _likedPosts[postId] = liked;
      notifyListeners();
    } catch (e) {
      // Ignored for now
    }
  }

  Future<void> checkFavoriteStatus(String postId, String userId) async {
    if (_favoritedPosts.containsKey(postId)) return;
    try {
      final favorited = await SocialService.isPostFavoritedByUser(postId, userId);
      _favoritedPosts[postId] = favorited;
      notifyListeners();
    } catch (e) {
      // Ignored for now
    }
  }

  Future<void> toggleLike(String postId, String userId) async {
    final currentlyLiked = isLiked(postId);
    _likedPosts[postId] = !currentlyLiked;
    notifyListeners();

    try {
      await SocialService.toggleLike(postId, userId, currentlyLiked);
    } catch (e) {
      _likedPosts[postId] = currentlyLiked;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String postId, String userId) async {
    final currentlyFavorited = isFavorited(postId);
    _favoritedPosts[postId] = !currentlyFavorited;
    notifyListeners();

    try {
      await SocialService.toggleFavorite(postId, userId, currentlyFavorited);
    } catch (e) {
      _favoritedPosts[postId] = currentlyFavorited;
      notifyListeners();
    }
  }
}
