import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prepify/models/pantry_item.dart';

class PantryService {
  PantryService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>> _userPantryItems(String userId) =>
      _db.collection('pantry').doc(userId).collection('items');

  /// Stream pantry items in real-time
  static Stream<List<PantryItem>> streamPantry() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return const Stream.empty();

    return _userPantryItems(userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PantryItem.fromFirestore(doc.id, doc.data())).toList());
  }

  /// Add new item OR update existing one (FIXED)
  static Future<void> addOrUpdateItem(
    String name,
    int quantity, {
    int threshold = 1,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final cleanName = name.trim().toLowerCase();
    if (cleanName.isEmpty) return;

    final itemsRef = _userPantryItems(userId);

    try {
      // Check if item already exists
      final query = await itemsRef
          .where('name', isEqualTo: cleanName)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        // UPDATE existing item
        final docId = query.docs.first.id;

        await itemsRef.doc(docId).update({
          'name': cleanName,
          'quantity': quantity,
          'threshold': threshold,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // ADD new item
        await itemsRef.add({
          'name': cleanName,
          'quantity': quantity,
          'threshold': threshold,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to add/update pantry item: $e');
    }
  }

  /// Optional: delete item
  static Future<void> deleteItem(String docId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _userPantryItems(userId).doc(docId).delete();
  }

  /// Optional: increase quantity
  static Future<void> increaseQuantity(String docId, int currentQty) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _userPantryItems(userId).doc(docId).update({
      'quantity': currentQty + 1,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Optional: decrease quantity (won’t go below 0)
  static Future<void> decreaseQuantity(String docId, int currentQty) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final newQty = currentQty - 1;

    await _userPantryItems(userId).doc(docId).update({
      'quantity': newQty < 0 ? 0 : newQty,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}