import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prepify/models/user_model.dart';

class FollowService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Follow a user
  static Future<void> followUser(String targetUserId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null || currentUserId == targetUserId) return;

    final batch = _db.batch();

    // Add to current user's following
    final currentUserRef = _db.collection('users').doc(currentUserId);
    batch.update(currentUserRef, {
      'following': FieldValue.arrayUnion([targetUserId]),
    });

    // Add to target user's followers
    final targetUserRef = _db.collection('users').doc(targetUserId);
    batch.update(targetUserRef, {
      'followers': FieldValue.arrayUnion([currentUserId]),
    });

    await batch.commit();
  }

  // Unfollow a user
  static Future<void> unfollowUser(String targetUserId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    final batch = _db.batch();

    // Remove from current user's following
    final currentUserRef = _db.collection('users').doc(currentUserId);
    batch.update(currentUserRef, {
      'following': FieldValue.arrayRemove([targetUserId]),
    });

    // Remove from target user's followers
    final targetUserRef = _db.collection('users').doc(targetUserId);
    batch.update(targetUserRef, {
      'followers': FieldValue.arrayRemove([currentUserId]),
    });

    await batch.commit();
  }

  // Check if current user is following target user
  static Future<bool> isFollowing(String targetUserId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return false;

    final doc = await _db.collection('users').doc(currentUserId).get();
    final following = List<String>.from(doc.data()?['following'] ?? []);
    return following.contains(targetUserId);
  }

  // Get followers count
  static Future<int> getFollowersCount(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    final followers = List<String>.from(doc.data()?['followers'] ?? []);
    return followers.length;
  }

  // Get following count
  static Future<int> getFollowingCount(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    final following = List<String>.from(doc.data()?['following'] ?? []);
    return following.length;
  }

  // Stream followers list
  static Stream<List<String>> streamFollowers(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((doc) {
      return List<String>.from(doc.data()?['followers'] ?? []);
    });
  }

  // Stream following list
  static Stream<List<String>> streamFollowing(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((doc) {
      return List<String>.from(doc.data()?['following'] ?? []);
    });
  }

  // Search users by username or email
  static Future<List<UserModel>> searchUsers(String query) async {
    final usernameQuery = await _db
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(20)
        .get();

    final emailQuery = await _db
        .collection('users')
        .where('email', isGreaterThanOrEqualTo: query)
        .where('email', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(20)
        .get();

    final users = <UserModel>[];
    final userIds = <String>{};

    for (var doc in usernameQuery.docs) {
      if (!userIds.contains(doc.id)) {
        users.add(UserModel.fromFirestore(doc));
        userIds.add(doc.id);
      }
    }

    for (var doc in emailQuery.docs) {
      if (!userIds.contains(doc.id)) {
        users.add(UserModel.fromFirestore(doc));
        userIds.add(doc.id);
      }
    }

    return users;
  }
}
