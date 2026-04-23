import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prepify/models/grocery_list.dart';

class GroceryService {
  GroceryService._();
  
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static CollectionReference<Map<String, dynamic>> get _lists => _db.collection('groceryLists');

  // Stream lists where the current user is a member
  static Stream<List<GroceryList>> streamUserLists() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _lists
        .where('members', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => GroceryList.fromFirestore(doc.id, doc.data())).toList());
  }

  // Stream items inside a list
  static Stream<List<GroceryItem>> streamListItems(String listId) {
    return _lists.doc(listId).collection('items').snapshots().map((snapshot) => 
        snapshot.docs.map((doc) => GroceryItem.fromFirestore(doc.id, doc.data())).toList());
  }

  // Create list
  static Future<String> createList(String name) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw StateError('Not logged in');

    final docRef = await _lists.add({
      'name': name,
      'createdBy': userId,
      'members': [userId],
    });
    return docRef.id;
  }

  // Add Item
  static Future<void> addItem(String listId, String name, int quantity) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _lists.doc(listId).collection('items').add({
      'name': name,
      'quantity': quantity,
      'status': 'pending',
      'addedBy': userId,
    });
  }

  // Toggle item status
  static Future<void> toggleItemStatus(String listId, String itemId, bool isCompleted) async {
    await _lists.doc(listId).collection('items').doc(itemId).update({
      'status': isCompleted ? 'completed' : 'pending',
    });
  }
}
