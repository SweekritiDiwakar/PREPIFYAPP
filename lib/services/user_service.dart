import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prepify/models/user_model.dart';

class UserService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user by ID
  static Future<UserModel?> getUserById(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  // Update user profile
  static Future<void> updateUserProfile(UserModel user) async {
    await _db.collection('users').doc(user.uid).update(user.toFirestore());
  }

  // Stream user data
  static Stream<UserModel?> streamUser(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }

  // Get user's recipes
  static Stream<List<Map<String, dynamic>>> streamUserRecipes(String userId) {
    // Support both newer `createdBy` field and legacy `userId` field.
    // We'll listen to both queries and merge results to ensure compatibility.
    final controller = StreamController<List<Map<String, dynamic>>>.broadcast();

    StreamSubscription? subCreatedBy;
    StreamSubscription? subUserId;

    void emitCombined(List<QueryDocumentSnapshot> a, List<QueryDocumentSnapshot> b) {
      final map = <String, Map<String, dynamic>>{};
      for (final doc in a) {
        map[doc.id] = {'_id': doc.id, ...doc.data() as Map<String, dynamic>};
      }
      for (final doc in b) {
        map[doc.id] = {'_id': doc.id, ...doc.data() as Map<String, dynamic>};
      }
      final combined = map.values.toList()
        ..sort((x, y) {
          final tx = x['createdAt'] as Timestamp?;
          final ty = y['createdAt'] as Timestamp?;
          final dx = tx?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
          final dy = ty?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
          return dy.compareTo(dx);
        });
      controller.add(combined);
    }

    List<QueryDocumentSnapshot> latestCreatedBy = [];
    List<QueryDocumentSnapshot> latestUserId = [];

    subCreatedBy = _db
        .collection('recipes')
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snap) {
      latestCreatedBy = snap.docs;
      emitCombined(latestCreatedBy, latestUserId);
    }, onError: (err) {
      // ignore errors for one stream; emit what we have
    });

    subUserId = _db
        .collection('recipes')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snap) {
      latestUserId = snap.docs;
      emitCombined(latestCreatedBy, latestUserId);
    }, onError: (err) {
      // ignore
    });

    controller.onCancel = () async {
      await subCreatedBy?.cancel();
      await subUserId?.cancel();
      await controller.close();
    };

    return controller.stream;
  }

  // Get user's favorite recipes
  static Stream<List<Map<String, dynamic>>> streamUserFavorites(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .orderBy('favoritedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Toggle favorite
  static Future<void> toggleFavorite(String recipeId, Map<String, dynamic> recipeData) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    final favRef = _db.collection('users').doc(currentUserId).collection('favorites').doc(recipeId);
    final doc = await favRef.get();

    if (doc.exists) {
      // Unfavorite
      await favRef.delete();
    } else {
      // Favorite
      await favRef.set({
        ...recipeData,
        'favoritedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Check if recipe is favorited
  static Future<bool> isRecipeFavorited(String recipeId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return false;

    final doc = await _db.collection('users').doc(currentUserId).collection('favorites').doc(recipeId).get();
    return doc.exists;
  }

  // Delete user account
  static Future<void> deleteAccount() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    // Delete user data from Firestore
    await _db.collection('users').doc(currentUser.uid).delete();

    // Delete favorites
    final favorites = await _db.collection('users').doc(currentUser.uid).collection('favorites').get();
    for (var doc in favorites.docs) {
      await doc.reference.delete();
    }

    // Delete user from Firebase Auth
    await currentUser.delete();
  }
}
