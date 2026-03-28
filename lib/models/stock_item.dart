import 'package:cloud_firestore/cloud_firestore.dart';

class StockItem {
  const StockItem({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.householdId,
    required this.addedBy,
    this.createdAt,
    this.updatedAt,
    this.lowStockThreshold,
  });

  final String id;
  final String itemName;
  final num quantity;
  final String unit;
  final String householdId;
  final String addedBy;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final num? lowStockThreshold;

  bool get isLowStock {
    final threshold = lowStockThreshold;
    if (threshold == null) return false;
    return quantity <= threshold;
  }

  factory StockItem.fromFirestore(String id, Map<String, dynamic> data) {
    return StockItem(
      id: id,
      itemName: (data['itemName'] as String?) ?? '',
      quantity: (data['quantity'] as num?) ?? 0,
      unit: (data['unit'] as String?) ?? '',
      householdId: (data['householdId'] as String?) ?? '',
      addedBy: (data['addedBy'] as String?) ?? '',
      createdAt: data['createdAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
      lowStockThreshold: data['lowStockThreshold'] as num?,
    );
  }
}
