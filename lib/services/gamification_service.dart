import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prepify/models/badge_model.dart';

class GamificationService {
  GamificationService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>> get _userBadges =>
      _db.collection('userBadges');

  static Stream<List<UserBadge>> streamUserBadges() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _userBadges
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserBadge.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  static Future<void> awardBadge(String badgeId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Check if already awarded
    final existing = await _userBadges
        .where('userId', isEqualTo: userId)
        .where('badgeId', isEqualTo: badgeId)
        .get();
    if (existing.docs.isEmpty) {
      await _userBadges.add({
        'userId': userId,
        'badgeId': badgeId,
        'earnedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
