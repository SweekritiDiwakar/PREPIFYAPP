import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prepify/services/user_profile_service.dart';

class GroceryFirestoreService {
  GroceryFirestoreService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>> get _lists =>
      _db.collection('grocery_lists');
  static CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');
  static CollectionReference<Map<String, dynamic>> get _events =>
      _db.collection('household_events');

  static String get _currentUid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('User not authenticated.');
    }
    return uid;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> streamUserLists() {
    return Stream.fromFuture(UserProfileService.getCurrentUserHouseholdId())
        .asyncExpand(
      (householdId) => _lists
          .where('householdId', isEqualTo: householdId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
    );
  }

  static Future<String> createGroceryList(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('List name cannot be empty.');
    }

    final householdId = await UserProfileService.getCurrentUserHouseholdId();
    final docRef = await _lists.add({
      'name': trimmed,
      'createdBy': _currentUid,
      'members': <String>[_currentUid],
      'householdId': householdId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> streamItems(String listId) {
    return _lists
        .doc(listId)
        .collection('items')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<void> addItem({
    required String listId,
    required String itemName,
    required String quantity,
  }) async {
    final safeName = itemName.trim();
    final safeQuantity = quantity.trim();
    if (safeName.isEmpty || safeQuantity.isEmpty) {
      throw ArgumentError('Item name and quantity are required.');
    }

    final householdId = await UserProfileService.getCurrentUserHouseholdId();
    await _lists.doc(listId).collection('items').add({
      'itemName': safeName,
      'quantity': safeQuantity,
      'isChecked': false,
      'addedBy': _currentUid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _createHouseholdEvent(
      householdId: householdId,
      type: 'grocery_item_added',
      title: 'New grocery item',
      body: '$safeName was added to your list.',
    );
  }

  static Future<void> toggleItemChecked({
    required String listId,
    required String itemId,
    required bool isChecked,
  }) async {
    await _lists.doc(listId).collection('items').doc(itemId).update({
      'isChecked': isChecked,
    });
    if (isChecked) {
      final householdId = await UserProfileService.getCurrentUserHouseholdId();
      await _createHouseholdEvent(
        householdId: householdId,
        type: 'grocery_item_purchased',
        title: 'Item purchased',
        body: 'A grocery item was marked as purchased.',
      );
    }
  }

  static Future<void> deleteItem({
    required String listId,
    required String itemId,
  }) async {
    await _lists.doc(listId).collection('items').doc(itemId).delete();
  }

  static Future<void> addMemberByEmail({
    required String listId,
    required String email,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      throw ArgumentError('Email is required.');
    }

    final userSnap = await _users
        .where('email', isEqualTo: normalizedEmail)
        .limit(1)
        .get();

    if (userSnap.docs.isEmpty) {
      throw StateError('No user found with this email.');
    }

    final userId = userSnap.docs.first.id;
    await _lists.doc(listId).update({
      'members': FieldValue.arrayUnion(<String>[userId]),
    });
  }

  static Future<Map<String, String>> getUserNamesByIds(List<String> uids) async {
    final uniqueIds = uids.toSet().where((id) => id.trim().isNotEmpty).toList();
    if (uniqueIds.isEmpty) return {};

    final Map<String, String> result = {};
    for (final uid in uniqueIds) {
      final doc = await _users.doc(uid).get();
      final data = doc.data();
      final name = (data?['name'] as String?)?.trim();
      result[uid] = (name != null && name.isNotEmpty) ? name : uid;
    }
    return result;
  }

  static Future<void> triggerLowStockAlert({
    required String itemName,
  }) async {
    final safeName = itemName.trim();
    if (safeName.isEmpty) return;
    final householdId = await UserProfileService.getCurrentUserHouseholdId();
    await _createHouseholdEvent(
      householdId: householdId,
      type: 'low_stock_alert',
      title: 'Low stock alert',
      body: '$safeName is running low.',
    );
  }

  static Future<void> _createHouseholdEvent({
    required String householdId,
    required String type,
    required String title,
    required String body,
  }) async {
    await _events.add({
      'householdId': householdId,
      'type': type,
      'title': title,
      'body': body,
      'createdBy': _currentUid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
