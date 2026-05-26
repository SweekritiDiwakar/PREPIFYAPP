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
  static CollectionReference<Map<String, dynamic>> get _households =>
      _db.collection('households');
  static CollectionReference<Map<String, dynamic>> get _events =>
      _db.collection('household_events');

  static String get _currentUid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('User not authenticated.');
    }
    return uid;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> streamUserLists() async* {
    try {
      final householdId = await UserProfileService.getCurrentUserHouseholdId();
      if (householdId.isEmpty) {
        // No household — show lists where user is a member
        yield* _lists
            .where('members', arrayContains: _currentUid)
            .snapshots();
      } else {
        // With household — show lists where user is a member OR list belongs to household
        yield* _lists.where(
          Filter.or(
            Filter('householdId', isEqualTo: householdId),
            Filter('members', arrayContains: _currentUid),
          )
        ).snapshots();
      }
    } catch (e) {
      yield* _lists.limit(0).snapshots();
    }
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

  static Future<String> getCurrentUserHouseholdIdFromLists() async {
    final query = await _lists.where('members', arrayContains: _currentUid).get();

    if (query.docs.isEmpty) {
      return '';
    }

    for (final doc in query.docs) {
      final householdId = ((doc.data()['householdId'] as String?) ?? '').trim();
      if (householdId.isEmpty) {
        continue;
      }

      await _syncHouseholdMembership(
        householdId: householdId,
        userId: _currentUid,
      );

      return householdId;
    }

    return '';
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> streamItems(String listId) {
    return _lists
        .doc(listId)
        .collection('items')
        .snapshots();
  }

  static Future<void> addItem({
    required String listId,
    required String itemName,
    required String quantity,
    num? amount,
  }) async {
    // Check authentication first
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('Please log in to add items to the grocery list.');
    }

    final safeName = itemName.trim();
    final safeQuantity = quantity.trim();
    if (safeName.isEmpty || safeQuantity.isEmpty) {
      throw ArgumentError('Item name and quantity are required.');
    }

    try {
      final householdId = await UserProfileService.getCurrentUserHouseholdId();
      
      // Check if user has permission to add to this list
      final listDoc = await _lists.doc(listId).get();
      if (!listDoc.exists) {
        throw StateError('Grocery list not found.');
      }
      
      final listData = listDoc.data();
      final listHouseholdId = listData?['householdId'] as String?;
      final members = List<String>.from(listData?['members'] ?? []);
      
      bool hasAccess = members.contains(currentUser.uid);
      if (!hasAccess && householdId.isNotEmpty && householdId == listHouseholdId) {
        hasAccess = true;
      }
      
      if (!hasAccess) {
        throw StateError('You do not have permission to add items to this list.');
      }

      await _lists.doc(listId).collection('items').add({
        'itemName': safeName,
        'quantity': safeQuantity,
        'isChecked': false,
        'addedBy': currentUser.uid,
        'amount': amount,
        'currency': 'NPR',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      await _createHouseholdEvent(
        householdId: householdId,
        type: 'grocery_item_added',
        title: 'New grocery item',
        body: '$safeName was added to your list.',
      );
    } catch (e) {
      if (e is ArgumentError || e is StateError) {
        rethrow;
      }
      throw StateError('Failed to add item. Please check your connection and try again.');
    }
  }

  static Future<void> toggleItemChecked({
    required String listId,
    required String itemId,
    required bool isChecked,
    String? itemName,
    String? quantity,
    num? amount,
  }) async {
    await _lists.doc(listId).collection('items').doc(itemId).update({
      'isChecked': isChecked,
    });
    if (isChecked) {
      final householdId = await UserProfileService.getCurrentUserHouseholdId();
      // Write a purchase record
      if (itemName != null && itemName.isNotEmpty) {
        await _db.collection('purchase_records').add({
          'householdId': householdId,
          'listId': listId,
          'itemId': itemId,
          'itemName': itemName,
          'quantity': quantity ?? '',
          'purchasedBy': _currentUid,
          'purchasedAt': FieldValue.serverTimestamp(),
          'amount': amount,
          'currency': 'NPR',
        });
      }
      await _createHouseholdEvent(
        householdId: householdId,
        type: 'grocery_item_purchased',
        title: 'Item purchased',
        body: '${itemName ?? 'An item'} was marked as purchased.',
      );
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> streamPurchaseHistory() async* {
    try {
      final householdId = await UserProfileService.getCurrentUserHouseholdId();
      if (householdId.isEmpty) {
        yield* _db
            .collection('purchase_records')
            .where('purchasedBy', isEqualTo: _currentUid)
            .snapshots();
      } else {
        yield* _db
            .collection('purchase_records')
            .where('householdId', isEqualTo: householdId)
            .snapshots();
      }
    } catch (e) {
      yield* _db.collection('purchase_records').limit(0).snapshots();
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
    final listDoc = await _lists.doc(listId).get();
    if (!listDoc.exists) {
      throw StateError('Grocery list not found.');
    }

    final listData = listDoc.data();
    final listName = ((listData?['name'] as String?) ?? '').trim();
    final members = List<String>.from(listData?['members'] ?? []);

    final listHouseholdId = ((listData?['householdId'] as String?) ?? '').trim();

    if (userId == _currentUid) {
      throw StateError('You cannot add yourself to the list.');
    }
    if (members.contains(userId)) {
      throw StateError('This user is already a member of the list.');
    }

    await _lists.doc(listId).update({
      'members': FieldValue.arrayUnion(<String>[userId]),
    });

    await _syncHouseholdMembership(
      householdId: listHouseholdId,
      userId: userId,
    );

    await _notifyUserAddedToList(
      userId: userId,
      listId: listId,
      listName: listName.isNotEmpty ? listName : 'your grocery list',
      householdId: listHouseholdId,
    );
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

  // Invite by username or email
  static Future<String> inviteToList(String listId, String usernameOrEmail) async {
    final currentUserId = _currentUid;

    // Search by username first, then email
    QuerySnapshot? snap;
    snap = await _users
        .where('username', isEqualTo: usernameOrEmail)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) {
      snap = await _users
          .where('email', isEqualTo: usernameOrEmail)
          .limit(1)
          .get();
    }

    if (snap.docs.isEmpty) return 'userNotFound';

    final inviteeUid = snap.docs.first.id;

    // Don't add yourself
    if (inviteeUid == currentUserId) return 'isSelf';

    final listDoc = await _lists.doc(listId).get();
    if (!listDoc.exists) return 'listNotFound';

    final listData = listDoc.data();
    final members = List<String>.from(listData?['members'] ?? []);
    if (members.contains(inviteeUid)) return 'alreadyMember';
    final listName = ((listData?['name'] as String?) ?? '').trim();
    final householdId = ((listData?['householdId'] as String?) ?? '').trim();

    await _lists.doc(listId).update({
      'members': FieldValue.arrayUnion([inviteeUid]),
    });

    await _syncHouseholdMembership(
      householdId: householdId,
      userId: inviteeUid,
    );

    await _notifyUserAddedToList(
      userId: inviteeUid,
      listId: listId,
      listName: listName.isNotEmpty ? listName : 'your grocery list',
      householdId: householdId,
    );

    return 'success';
  }

  // Remove a member
  static Future<void> removeMember(String listId, String memberId) async {
    await _lists.doc(listId).update({
      'members': FieldValue.arrayRemove([memberId]),
    });
  }

  static Future<void> removeMemberFromHousehold(String householdId, String memberId) async {
    final trimmedHouseholdId = householdId.trim();
    final trimmedMemberId = memberId.trim();
    if (trimmedHouseholdId.isEmpty || trimmedMemberId.isEmpty) {
      return;
    }

    final query = await _lists
        .where('householdId', isEqualTo: trimmedHouseholdId)
        .where('members', arrayContains: trimmedMemberId)
        .get();

    for (final doc in query.docs) {
      await doc.reference.update({
        'members': FieldValue.arrayRemove(<String>[trimmedMemberId]),
      });
    }

    await _households.doc(trimmedHouseholdId).update({
      'members': FieldValue.arrayRemove(<String>[trimmedMemberId]),
    });

    await UserProfileService.updateHouseholdId(
      uid: trimmedMemberId,
      householdId: '',
    );
  }

  static Future<void> _syncHouseholdMembership({
    required String householdId,
    required String userId,
  }) async {
    final trimmedHouseholdId = householdId.trim();
    if (trimmedHouseholdId.isEmpty || userId.trim().isEmpty) {
      return;
    }

    await _households.doc(trimmedHouseholdId).set(
      {
        'members': FieldValue.arrayUnion(<String>[userId]),
      },
      SetOptions(merge: true),
    );

    await UserProfileService.updateHouseholdId(
      uid: userId,
      householdId: trimmedHouseholdId,
    );
  }

  static Future<void> _notifyUserAddedToList({
    required String userId,
    required String listId,
    required String listName,
    required String householdId,
  }) async {
    final actorName = _auth.currentUser?.displayName?.trim();
    final message = actorName != null && actorName.isNotEmpty
        ? '$actorName added you to the grocery list "$listName".'
        : 'You were added to the grocery list "$listName".';

    await _db.collection('notifications').add({
      'userId': userId,
      'listId': listId,
      'listName': listName,
      'title': 'Added to grocery list',
      'message': message,
      'type': 'grocery_list_member_added',
      'read': false,
      'createdBy': _currentUid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (householdId.isNotEmpty) {
      await _events.add({
        'householdId': householdId,
        'type': 'grocery_list_member_added',
        'title': 'Added to grocery list',
        'body': message,
        'createdBy': _currentUid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
