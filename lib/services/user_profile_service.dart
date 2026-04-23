import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prepify/models/app_user.dart';
import 'package:prepify/services/cloudinary_service.dart';

class UserProfileService {
  UserProfileService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  static Future<AppUser> ensureUserDocument({
    required String uid,
    String? fallbackName,
    String? fallbackEmail,
  }) async {
    final docRef = _users.doc(uid);
    final snap = await docRef.get();

    if (!snap.exists) {
      final authUser = _auth.currentUser;
      final safeEmail = fallbackEmail ?? authUser?.email ?? '';
      final safeName = (fallbackName ?? authUser?.displayName ?? '').trim();

      await docRef.set({
        'username': safeName,
        'email': safeEmail,
        'bio': '',
        'photoUrl': '',
        'followers': <String>[],
        'following': <String>[],
        'isPrivate': false,
        'showFavoritesPublicly': true,
        'householdId': '',
        'createdAt': FieldValue.serverTimestamp(),
        'completedRecipes': 0,
        'badges': <String>[],
      });
    }

    final latest = await docRef.get();
    final data = latest.data() ?? <String, dynamic>{};
    return AppUser.fromFirestore(uid, data);
  }

  static Future<AppUser> fetchCurrentUserProfile() async {
    final authUser = _auth.currentUser;
    if (authUser == null) {
      throw StateError('No authenticated user found.');
    }
    return ensureUserDocument(
      uid: authUser.uid,
      fallbackName: authUser.displayName,
      fallbackEmail: authUser.email,
    );
  }

  static Future<AppUser> updateName({
    required String uid,
    required String name,
  }) async {
    await _users.doc(uid).update({'name': name.trim()});
    if (_auth.currentUser != null) {
      await _auth.currentUser!.updateDisplayName(name.trim());
    }
    final snap = await _users.doc(uid).get();
    return AppUser.fromFirestore(uid, snap.data() ?? <String, dynamic>{});
  }

  static Future<AppUser> updateProfileImage({
    required String uid,
    required File imageFile,
  }) async {
    final downloadUrl = await CloudinaryService.uploadImage(imageFile);
    await _users.doc(uid).update({'profileImage': downloadUrl});
    final snap = await _users.doc(uid).get();
    return AppUser.fromFirestore(uid, snap.data() ?? <String, dynamic>{});
  }

  static Future<void> updateHouseholdId({
    required String uid,
    required String householdId,
  }) async {
    await _users.doc(uid).update({
      'householdId': householdId.trim(),
    });
  }

  static Future<void> addBadge({
    required String uid,
    required String badge,
  }) async {
    await ensureUserDocument(uid: uid);
    await _users.doc(uid).update({
      'badges': FieldValue.arrayUnion(<String>[badge]),
    });
  }

  static Future<void> incrementCompletedRecipes({
    required String uid,
    required int newCount,
    List<String>? badges,
  }) async {
    final Map<String, dynamic> updates = {
      'completedRecipes': newCount,
    };
    if (badges != null) {
      updates['badges'] = badges;
    }
    await _users.doc(uid).update(updates);
  }

  static Future<String> getCurrentUserHouseholdId() async {
    final authUser = _auth.currentUser;
    if (authUser == null) {
      throw StateError('No authenticated user found.');
    }
    final snap = await _users.doc(authUser.uid).get();
    final householdId = (snap.data()?['householdId'] as String?)?.trim() ?? '';
    
    // Return empty string instead of throwing - let services handle it
    return householdId;
  }
}
