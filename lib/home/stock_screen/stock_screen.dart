import 'package:flutter/material.dart';
import 'package:prepify/models/stock_item.dart';
import 'package:prepify/services/stock_service.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  StockSortOption _sortOption = StockSortOption.lowStockFirst;

  Future<void> _openAddStockSheet() async {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final unitController = TextEditingController();
    final thresholdController = TextEditingController();
    final suggestions = await StockService.fetchGrocerySuggestions();

    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add / Update Stock',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Item name',
                  ),
                ),
                if (suggestions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: suggestions
                        .take(8)
                        .map(
                          (item) => ActionChip(
                            label: Text(item),
                            onPressed: () => nameController.text = item,
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 10),
                TextField(
                  controller: quantityController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Quantity',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: unitController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Unit (kg, litre, pcs...)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: thresholdController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Low stock threshold (optional)',
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final q = num.tryParse(quantityController.text.trim());
                      if (q == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Enter a valid quantity.')),
                        );
                        return;
                      }
                      final thresholdText = thresholdController.text.trim();
                      final threshold = thresholdText.isEmpty
                          ? null
                          : num.tryParse(thresholdText);
                      if (thresholdText.isNotEmpty && threshold == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invalid threshold value.')),
                        );
                        return;
                      }
                      try {
                        await StockService.addOrUpdateStock(
                          itemName: nameController.text,
                          quantity: q,
                          unit: unitController.text,
                          lowStockThreshold: threshold,
                        );
                        if (!mounted) return;
                        Navigator.pop(context);
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    nameController.dispose();
    quantityController.dispose();
    unitController.dispose();
    thresholdController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Tracking'),
        actions: [
          PopupMenuButton<StockSortOption>(
            initialValue: _sortOption,
            onSelected: (value) => setState(() => _sortOption = value),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: StockSortOption.lowStockFirst,
                child: Text('Low stock first'),
              ),
              PopupMenuItem(
                value: StockSortOption.quantityAsc,
                child: Text('Quantity ascending'),
              ),
              PopupMenuItem(
                value: StockSortOption.quantityDesc,
                child: Text('Quantity descending'),
              ),
              PopupMenuItem(
                value: StockSortOption.nameAsc,
                child: Text('Name A-Z'),
              ),
              PopupMenuItem(
                value: StockSortOption.nameDesc,
                child: Text('Name Z-A'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddStockSheet,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<StockItem>>(
        stream: StockService.streamStockItems(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load stock items.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = StockService.sortItems(snapshot.data!, _sortOption);
          if (items.isEmpty) {
            return const Center(child: Text('No stock items yet.'));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Dismissible(
                key: Key(item.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) async {
                  await StockService.deleteStockItem(item.id);
                },
                child: ListTile(
                  leading: Icon(
                    item.isLowStock ? Icons.warning_amber : Icons.inventory_2_outlined,
                    color: item.isLowStock ? Colors.red : Colors.green,
                  ),
                  title: Text(
                    item.itemName,
                    style: TextStyle(
                      color: item.isLowStock ? Colors.red : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text('${item.quantity} ${item.unit}'),
                  trailing: item.isLowStock
                      ? const Text(
                          'LOW',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
