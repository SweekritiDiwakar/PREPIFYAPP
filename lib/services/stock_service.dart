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
      // Firestore requires a composite index for queries that combine a
      // `where` on one field and an `orderBy` on another. To avoid that
      // requirement during development, fetch the household docs and sort
      // client-side by `updatedAt` (descending).
      yield* _stock
          .where('householdId', isEqualTo: householdId)
          .snapshots()
          .map((snap) {
        final items = snap.docs
            .map((doc) => StockItem.fromFirestore(doc.id, doc.data()))
            .toList();
        items.sort((a, b) {
          final aTs = a.updatedAt?.toDate().millisecondsSinceEpoch ?? 0;
          final bTs = b.updatedAt?.toDate().millisecondsSinceEpoch ?? 0;
          return bTs.compareTo(aTs);
        });
        return items;
      });
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

    final shouldAlertLowStock = lowStockThreshold != null && quantity <= lowStockThreshold;

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

    if (shouldAlertLowStock) {
      debugPrint('Low stock alert: household=$householdId item=$safeName qty=$quantity threshold=$lowStockThreshold');
      await _events.add({
        'householdId': householdId,
        'type': 'low_stock_alert',
        'title': 'Low stock',
        'body': 'Low stock: $safeName is running low ($quantity $safeUnit left).',
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

  // Try to consume ingredients specified by recipe when cooking finishes.
  // Each ingredient is a freeform string (e.g., '500 g chicken', '1 cup flour').
  // We attempt to parse quantity, unit and item name, match the stock item by
  // normalized name, and decrement the stock quantity inside a transaction.
  static Future<void> consumeIngredients(List<String> ingredients) async {
    final householdId = await UserProfileService.getCurrentUserHouseholdId();
    if (householdId.isEmpty) return;

    for (final raw in ingredients) {
      final parsed = _parseIngredient(raw);
      if (parsed == null) {
        debugPrint('consumeIngredients: could not parse "$raw"');
        continue;
      }
      final itemName = parsed['name'] as String;
      final qty = parsed['quantity'] as num;
      final unit = (parsed['unit'] as String?)?.toLowerCase() ?? '';

      final norm = itemName.toLowerCase().trim();

      try {
        final query = await _stock
            .where('householdId', isEqualTo: householdId)
            .where('itemNameLower', isEqualTo: norm)
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          debugPrint('consumeIngredients: no stock match for "$itemName"');
          continue;
        }

        final docRef = query.docs.first.reference;

        await _db.runTransaction((tx) async {
          final snapshot = await tx.get(docRef);
          final data = snapshot.data() ?? <String, dynamic>{};
          final prevQty = (data['quantity'] as num?) ?? 0;
          final prevUnit = ((data['unit'] as String?) ?? '').toLowerCase();
          final prevThreshold = data['lowStockThreshold'] as num?;

          // Only consume if units match (simple check). If unit mismatch, skip.
          if (unit.isNotEmpty && prevUnit.isNotEmpty && unit != prevUnit) {
            debugPrint('consumeIngredients: unit mismatch for $itemName (recipe:$unit stock:$prevUnit)');
            return;
          }

          final newQty = (prevQty - qty) < 0 ? 0 : (prevQty - qty);
          tx.update(docRef, {
            'quantity': newQty,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // If we crossed the low-stock threshold, emit an event
          if (prevThreshold != null && prevQty > prevThreshold && newQty <= prevThreshold) {
            await _events.add({
              'householdId': householdId,
              'type': 'low_stock_alert',
              'title': 'Low stock',
              'body': 'Low stock: $itemName is running low ($newQty $prevUnit left).',
              'createdBy': _currentUid,
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
        });
      } catch (e, st) {
        debugPrint('consumeIngredients error for $raw: $e\n$st');
      }
    }
  }

  // Very small heuristic parser for ingredient strings. Returns map with
  // `name`, `quantity`, `unit` or null if parsing failed.
  static Map<String, Object?>? _parseIngredient(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;

    // Try pattern: leading quantity (e.g., '500 g chicken' or '1.5 kg flour')
    final leading2 = RegExp(r'^([0-9]+(?:[\.,][0-9]+)?)\s*([a-zA-Z]+)?\s+(.+)');
    final m = leading2.firstMatch(s);
    if (m != null) {
      final qText = m.group(1)!.replaceAll(',', '.');
      final quantity = num.tryParse(qText);
      if (quantity == null) return null;
      final unit = (m.group(2) ?? '').trim();
      var name = m.group(3)!.trim();
      // remove common descriptors
      name = name.replaceAll(RegExp(r'\(.*?\)'), '').trim();
      name = name.replaceAll(RegExp(r'[,\-:]'), '').trim();
      // remove adjectives like 'chopped', keep base noun at end
      final parts = name.split(RegExp('\s+'));
      if (parts.length > 1) {
        name = parts.sublist(parts.length - 2).join(' ');
      }
      // lower and singular-ish
      if (name.endsWith('s') && name.length > 3) name = name.substring(0, name.length - 1);
      return {'name': name, 'quantity': quantity, 'unit': unit};
    }

    // Fallback: look for a number anywhere
    final any = RegExp(r'([0-9]+(?:[\.,][0-9]+)?)');
    final m2 = any.firstMatch(s);
    if (m2 != null) {
      final qText = m2.group(1)!.replaceAll(',', '.');
      final quantity = num.tryParse(qText);
      if (quantity == null) return null;
      // guess unit as next token
      final after = s.substring(m2.end).trim();
      final tokens = after.split(RegExp('\s+'));
      final unit = tokens.isNotEmpty ? tokens.first : '';
      // remaining as name
      final name = tokens.length > 1 ? tokens.sublist(1).join(' ') : s.replaceFirst(m2.group(1)!, '').trim();
      var nm = name.replaceAll(RegExp(r'\(.*?\)'), '').replaceAll(RegExp(r'[,\-:]'), '').trim();
      if (nm.endsWith('s') && nm.length > 3) nm = nm.substring(0, nm.length - 1);
      return {'name': nm, 'quantity': quantity, 'unit': unit};
    }

    return null;
  }
}
