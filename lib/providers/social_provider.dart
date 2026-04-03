import 'package:flutter/material.dart';
import 'package:prepify/services/social_service.dart';

class SocialProvider extends ChangeNotifier {
  final Map<String, bool> _likedPosts = {};

  bool isLiked(String postId) => _likedPosts[postId] ?? false;

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

  Future<void> toggleLike(String postId, String userId) async {
    final currentlyLiked = isLiked(postId);
    
    // Optimistic UI update
    _likedPosts[postId] = !currentlyLiked;
    notifyListeners();

    try {
      await SocialService.toggleLike(postId, userId, currentlyLiked);
    } catch (e) {
      // Revert if failing
      _likedPosts[postId] = currentlyLiked;
      notifyListeners();
    }
  }
}
