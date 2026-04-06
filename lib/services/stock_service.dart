import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:prepify/models/stock_item.dart';
import 'package:prepify/services/user_profile_service.dart';

enum StockSortOption { lowStockFirst, quantityAsc, quantityDesc, nameAsc, nameDesc }

class StockService {
  StockService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>> get _stock =>
      _db.collection('stock');
  static CollectionReference<Map<String, dynamic>> get _events =>
      _db.collection('household_events');
  static CollectionReference<Map<String, dynamic>> get _lists =>
      _db.collection('grocery_lists');

  static String get _currentUid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('You must be logged in.');
    }
    return uid;
  }

  static Stream<List<StockItem>> streamStockItems() async* {
    try {
      final householdId = await UserProfileService.getCurrentUserHouseholdId();
      if (householdId.isEmpty) {
        yield [];
        return;
      }
      yield* _stock
          .where('householdId', isEqualTo: householdId)
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map(
            (snap) => snap.docs
                .map((doc) => StockItem.fromFirestore(doc.id, doc.data()))
                .toList(),
          );
    } catch (e) {
      debugPrint('StockService.streamStockItems error: $e');
      yield [];
    }
  }

  static Future<void> addOrUpdateStock({
    required String itemName,
    required num quantity,
    required String unit,
    num? lowStockThreshold,
  }) async {
    final safeName = itemName.trim();
    final safeUnit = unit.trim();
    if (safeName.isEmpty || safeUnit.isEmpty) {
      throw ArgumentError('Item name and unit are required.');
    }
    if (quantity < 0) {
      throw ArgumentError('Quantity cannot be negative.');
    }

    final householdId = await UserProfileService.getCurrentUserHouseholdId();
    final normalizedName = safeName.toLowerCase();

    final existing = await _stock
        .where('householdId', isEqualTo: householdId)
        .where('itemNameLower', isEqualTo: normalizedName)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      await existing.docs.first.reference.update({
        'itemName': safeName,
        'quantity': quantity,
        'unit': safeUnit,
        'lowStockThreshold': lowStockThreshold,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await _stock.add({
        'itemName': safeName,
        'itemNameLower': normalizedName,
        'quantity': quantity,
        'unit': safeUnit,
        'householdId': householdId,
        'addedBy': _currentUid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lowStockThreshold': lowStockThreshold,
      });
    }

    if (lowStockThreshold != null && quantity <= lowStockThreshold) {
      await _events.add({
        'householdId': householdId,
        'type': 'low_stock_alert',
        'title': 'Low stock alert',
        'body': '$safeName is low ($quantity $safeUnit left).',
        'createdBy': _currentUid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  static Future<void> deleteStockItem(String stockId) async {
    await _stock.doc(stockId).delete();
  }

  static Future<List<String>> fetchGrocerySuggestions() async {
    final householdId = await UserProfileService.getCurrentUserHouseholdId();
    final lists = await _lists
        .where('householdId', isEqualTo: householdId)
        .limit(10)
        .get();

    final suggestions = <String>{};
    for (final list in lists.docs) {
      final items = await list.reference
          .collection('items')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();
      for (final itemDoc in items.docs) {
        final name = (itemDoc.data()['itemName'] as String?)?.trim() ?? '';
        if (name.isNotEmpty) suggestions.add(name);
      }
    }
    return suggestions.toList()..sort();
  }

  static List<StockItem> sortItems(List<StockItem> items, StockSortOption option) {
    final sorted = [...items];
    switch (option) {
      case StockSortOption.lowStockFirst:
        sorted.sort((a, b) {
          final aLow = a.isLowStock;
          final bLow = b.isLowStock;
          if (aLow != bLow) return aLow ? -1 : 1;
          return a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase());
        });
        break;
      case StockSortOption.quantityAsc:
        sorted.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case StockSortOption.quantityDesc:
        sorted.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
      case StockSortOption.nameAsc:
        sorted.sort((a, b) => a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase()));
        break;
      case StockSortOption.nameDesc:
        sorted.sort((a, b) => b.itemName.toLowerCase().compareTo(a.itemName.toLowerCase()));
        break;
    }
    return sorted;
  }

  static Future<List<String>> findMissingIngredients(List<String> ingredients) async {
    final householdId = await UserProfileService.getCurrentUserHouseholdId();
    final stockSnap = await _stock.where('householdId', isEqualTo: householdId).get();
    final available = stockSnap.docs
        .map((doc) => ((doc.data()['itemName'] as String?) ?? '').trim().toLowerCase())
        .where((name) => name.isNotEmpty)
        .toSet();

    return ingredients
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .where((item) => !available.contains(item.toLowerCase()))
        .toList();
  }
}
