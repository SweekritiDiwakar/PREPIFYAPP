import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prepify/home/grocery_list_screen/firestore_service.dart';
import 'package:prepify/services/user_profile_service.dart';

class ChatService {
  ChatService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>> get _messages =>
      _db.collection('messages');

  static Future<String> getCurrentUserHouseholdId() {
    return _resolveCurrentUserHouseholdId();
  }

  static Future<String> _resolveCurrentUserHouseholdId() async {
    final householdId = await UserProfileService.getCurrentUserHouseholdId();
    if (householdId.isNotEmpty) {
      return householdId;
    }

    return GroceryFirestoreService.getCurrentUserHouseholdIdFromLists();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> streamHouseholdMessages(
    String householdId,
  ) {
    return _messages
        .where('householdId', isEqualTo: householdId)
        .snapshots();
  }

  static Future<String> sendHouseholdMessage({
    required String householdId,
    required String messageText,
    String? messageId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('You must be logged in to send messages.');
    }

    final trimmed = messageText.trim();
    if (trimmed.isEmpty) return '';

    // Do not enforce household existence here; Firestore security rules will
    // enforce membership server-side. The client should remain permissive so
    // that optimistic UI works consistently with existing messages.

    final senderName = await _resolveSenderName(user);
    final docRef = messageId == null ? _messages.doc() : _messages.doc(messageId);

    await docRef.set({
      'messageId': docRef.id,
      'householdId': householdId,
      'senderId': user.uid,
      'senderName': senderName,
      'messageText': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  static Future<String> _resolveSenderName(User user) async {
    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final userDoc = await _db.collection('users').doc(user.uid).get();
    final data = userDoc.data() ?? <String, dynamic>{};

    final name = (data['name'] as String?)?.trim();
    if (name != null && name.isNotEmpty) return name;

    final username = (data['username'] as String?)?.trim();
    if (username != null && username.isNotEmpty) return username;

    final email = user.email?.trim();
    if (email != null && email.isNotEmpty) return email;

    return 'Prepify User';
  }
}
