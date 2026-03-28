import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:prepify/models/app_user.dart';

class UserProfileService {
  UserProfileService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

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
        'name': safeName,
        'email': safeEmail,
        'profileImage': '',
        'householdId': '',
        'createdAt': FieldValue.serverTimestamp(),
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
    final path = 'profile_images/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child(path);
    await ref.putFile(imageFile);
    final downloadUrl = await ref.getDownloadURL();

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

  static Future<String> getCurrentUserHouseholdId() async {
    final authUser = _auth.currentUser;
    if (authUser == null) {
      throw StateError('No authenticated user found.');
    }
    final snap = await _users.doc(authUser.uid).get();
    final householdId = (snap.data()?['householdId'] as String?)?.trim() ?? '';
    if (householdId.isEmpty) {
      throw StateError('User is not in a household yet.');
    }
    return householdId;
  }
}
