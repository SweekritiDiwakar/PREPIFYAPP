import 'package:cloud_firestore/cloud_firestore.dart';

class PurchaseRecord {
  const PurchaseRecord({
    required this.id,
    required this.householdId,
    required this.listId,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.purchasedBy,
    required this.purchasedAt,
    this.amount,
    this.currency,
  });

  final String id;
  final String householdId;
  final String listId;
  final String itemId;
  final String itemName;
  final String quantity;
  final String purchasedBy;
  final Timestamp purchasedAt;
  final num? amount;
  final String? currency;

  factory PurchaseRecord.fromFirestore(String id, Map<String, dynamic> data) {
    return PurchaseRecord(
      id: id,
      householdId: (data['householdId'] as String?) ?? '',
      listId: (data['listId'] as String?) ?? '',
      itemId: (data['itemId'] as String?) ?? '',
      itemName: (data['itemName'] as String?) ?? '',
      quantity: (data['quantity'] as String?) ?? '',
      purchasedBy: (data['purchasedBy'] as String?) ?? '',
      purchasedAt: data['purchasedAt'] as Timestamp? ?? Timestamp.now(),
      amount: data['amount'] as num?,
      currency: (data['currency'] as String?) ?? 'NPR',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'householdId': householdId,
      'listId': listId,
      'itemId': itemId,
      'itemName': itemName,
      'quantity': quantity,
      'purchasedBy': purchasedBy,
      'purchasedAt': purchasedAt,
      'amount': amount,
      'currency': currency,
    };
  }
}
