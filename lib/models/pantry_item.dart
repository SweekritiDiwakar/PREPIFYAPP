import 'package:cloud_firestore/cloud_firestore.dart';

class PantryItem {
  final String itemId;
  final String name;
  final int quantity;
  final int threshold;
  final DateTime updatedAt;

  PantryItem({
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.threshold,
    required this.updatedAt,
  });

  factory PantryItem.fromFirestore(String id, Map<String, dynamic> data) {
    return PantryItem(
      itemId: id,
      name: data['name'] ?? '',
      quantity: data['quantity'] ?? 0,
      threshold: data['threshold'] ?? 1,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'quantity': quantity,
      'threshold': threshold,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
