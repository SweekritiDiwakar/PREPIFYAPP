import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prepify/home/grocery_list_screen/firestore_service.dart';
import 'package:prepify/models/purchase_record.dart';

class PurchaseHistoryScreen extends StatelessWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase History'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: GroceryFirestoreService.streamPurchaseHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load purchase history.'));
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No purchases recorded yet.', style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 8),
                  Text(
                    'Check off grocery items to record purchases.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final records = docs
              .map((doc) => PurchaseRecord.fromFirestore(doc.id, doc.data()))
              .toList()
            ..sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));

          // Calculate total spend
          final totalSpend = records.fold<num>(
            0,
            (acc, r) => acc + (r.amount ?? 0),
          );
          final recordsWithAmount = records.where((r) => r.amount != null && r.amount! > 0).length;

          return Column(
            children: [
              // Summary card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFAED581)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _summaryItem('${records.length}', 'Items Bought'),
                    Container(width: 1, height: 40, color: Colors.grey[300]),
                    _summaryItem(
                      recordsWithAmount > 0 ? 'NPR ${totalSpend.toStringAsFixed(0)}' : '—',
                      'Total Spent',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: records.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final record = records[index];
                    final dateStr = DateFormat('MMM d, y • h:mm a')
                        .format(record.purchasedAt.toDate());
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F8E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.check_circle_outline,
                            color: Color(0xFF558B2F), size: 22),
                      ),
                      title: Text(
                        record.itemName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Qty: ${record.quantity}'),
                          Text(dateStr,
                              style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                      trailing: record.amount != null && record.amount! > 0
                          ? Text(
                              'NPR ${record.amount!.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF558B2F),
                              ),
                            )
                          : null,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryItem(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
