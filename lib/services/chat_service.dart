import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prepify/services/user_profile_service.dart';

class ChatService {
  ChatService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>> get _messages =>
      _db.collection('messages');

  static Future<String> getCurrentUserHouseholdId() {
    return UserProfileService.getCurrentUserHouseholdId();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> streamHouseholdMessages(
    String householdId,
  ) {
    return _messages
        .where('householdId', isEqualTo: householdId)
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  static Future<void> sendHouseholdMessage({
    required String householdId,
    required String messageText,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('You must be logged in to send messages.');
    }

    final trimmed = messageText.trim();
    if (trimmed.isEmpty) return;

    final senderName = await _resolveSenderName(user);
    final docRef = _messages.doc();

    await docRef.set({
      'messageId': docRef.id,
      'householdId': householdId,
      'senderId': user.uid,
      'senderName': senderName,
      'messageText': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
    });
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
