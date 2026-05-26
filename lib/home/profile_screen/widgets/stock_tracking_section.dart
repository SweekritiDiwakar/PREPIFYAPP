import 'package:flutter/material.dart';
import 'package:prepify/models/stock_item.dart';
import 'package:prepify/services/stock_service.dart';

class StockTrackingSection extends StatefulWidget {
  const StockTrackingSection({super.key});

  @override
  State<StockTrackingSection> createState() => _StockTrackingSectionState();
}

class _StockTrackingSectionState extends State<StockTrackingSection> {
  StockSortOption _sortOption = StockSortOption.lowStockFirst;

  Future<void> _openStockDialog() async {
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
                  'Add Stock Item',
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
                      // Prevent saving when quantity equals threshold
                      if (threshold != null && threshold == q) {
                        await showDialog<void>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Invalid values'),
                            content: const Text('Quantity and threshold cannot be the same.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
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
                        if (!context.mounted) return;
                        // Defer closing slightly to avoid framework assertion where
                        // the route is removed while dependents are updating.
                        Future.delayed(const Duration(milliseconds: 50), () async {
                          try {
                            if (!context.mounted) return;
                            if (Navigator.of(context).canPop()) {
                              final popped = await Navigator.of(context).maybePop();
                              debugPrint('Stock dialog maybePop result: $popped');
                            } else {
                              debugPrint('Stock dialog: cannot pop (already closed)');
                            }
                          } catch (err, st) {
                            debugPrint('Error closing stock dialog: $err\n$st');
                          }
                        });
                      } catch (e) {
                        if (!context.mounted) return;
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
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Stock Tracking',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                ),
              ),
              IconButton(
                onPressed: _openStockDialog,
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Add stock item',
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Track pantry items and flag anything that goes below its threshold.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Sort: ', style: TextStyle(fontSize: 12)),
              DropdownButton<StockSortOption>(
                value: _sortOption,
                isDense: true,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(
                    value: StockSortOption.lowStockFirst,
                    child: Text('Low stock first'),
                  ),
                  DropdownMenuItem(
                    value: StockSortOption.quantityAsc,
                    child: Text('Quantity asc'),
                  ),
                  DropdownMenuItem(
                    value: StockSortOption.quantityDesc,
                    child: Text('Quantity desc'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _sortOption = value);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<StockItem>>(
            stream: StockService.streamStockItems(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                debugPrint('Stock stream error: ${snapshot.error}');
                return Text('Failed to load stock items: ${snapshot.error}');
              }
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final items = StockService.sortItems(snapshot.data!, _sortOption);
              if (items.isEmpty) {
                return const Text('No stock items yet.');
              }

              return Column(
                children: items.map((item) => _StockTile(item: item)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StockTile extends StatelessWidget {
  const _StockTile({required this.item});

  final StockItem item;

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete stock item?'),
          content: Text('Delete "${item.itemName}" from stock?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await StockService.deleteStockItem(item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: Key(item.id),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (_) async {
          await StockService.deleteStockItem(item.id);
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: item.isLowStock ? Colors.red.shade200 : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              Icon(
                item.isLowStock ? Icons.warning_amber : Icons.inventory_2_outlined,
                color: item.isLowStock ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.quantity} ${item.unit}',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              if (item.isLowStock)
                const Text(
                  'LOW',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              IconButton(
                tooltip: 'Delete stock item',
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}