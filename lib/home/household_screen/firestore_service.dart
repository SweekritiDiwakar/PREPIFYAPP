import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prepify/models/app_user.dart';
import 'package:prepify/services/user_profile_service.dart';

class HouseholdFirestoreService {
  HouseholdFirestoreService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final Random _random = Random.secure();

  static CollectionReference<Map<String, dynamic>> get _households =>
      _db.collection('households');
  static CollectionReference<Map<String, dynamic>> get _events =>
      _db.collection('household_events');

  static String get _currentUid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('You must be logged in.');
    }
    return uid;
  }

  static Future<String> _generateUniqueInviteCode() async {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    for (var i = 0; i < 12; i++) {
      final code = List.generate(
        6,
        (_) => chars[_random.nextInt(chars.length)],
      ).join();
      final existing = await _households
          .where('inviteCode', isEqualTo: code)
          .limit(1)
          .get();
      if (existing.docs.isEmpty) return code;
    }
    throw StateError('Could not generate unique invite code. Please retry.');
  }

  static Future<DocumentReference<Map<String, dynamic>>> createHousehold({
    required String name,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Household name is required.');
    }

    final uid = _currentUid;
    final inviteCode = await _generateUniqueInviteCode();
    final docRef = await _households.add({
      'name': trimmedName,
      'createdBy': uid,
      'members': <String>[uid],
      'inviteCode': inviteCode,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await UserProfileService.updateHouseholdId(uid: uid, householdId: docRef.id);
    return docRef;
  }

  static Future<void> joinHouseholdByInviteCode(String inviteCode) async {
    final code = inviteCode.trim().toUpperCase();
    if (code.isEmpty) {
      throw ArgumentError('Invite code is required.');
    }

    final uid = _currentUid;
    final query = await _households
        .where('inviteCode', isEqualTo: code)
        .limit(1)
        .get();
    if (query.docs.isEmpty) {
      throw StateError('Invalid invite code.');
    }

    final householdDoc = query.docs.first;
    await householdDoc.reference.update({
      'members': FieldValue.arrayUnion(<String>[uid]),
    });
    await UserProfileService.updateHouseholdId(uid: uid, householdId: householdDoc.id);
    await _events.add({
      'householdId': householdDoc.id,
      'type': 'household_member_joined',
      'title': 'New household member',
      'body': 'A new user joined your household.',
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> leaveHousehold() async {
    final uid = _currentUid;
    final household = await fetchUserHousehold();
    if (household == null) return;

    await household.reference.update({
      'members': FieldValue.arrayRemove(<String>[uid]),
    });
    await UserProfileService.updateHouseholdId(uid: uid, householdId: '');
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>?> fetchUserHousehold() async {
    final uid = _currentUid;
    final query = await _households
        .where('members', arrayContains: uid)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return query.docs.first;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> streamUserHousehold() {
    final uid = _currentUid;
    return _households.where('members', arrayContains: uid).limit(1).snapshots();
  }

  static Future<List<AppUser>> getMembersByIds(List<String> userIds) async {
    final ids = userIds.toSet().where((id) => id.trim().isNotEmpty).toList();
    if (ids.isEmpty) return <AppUser>[];

    final users = <AppUser>[];
    for (final id in ids) {
      final user = await UserProfileService.ensureUserDocument(uid: id);
      users.add(user);
    }
    return users;
  }
}
