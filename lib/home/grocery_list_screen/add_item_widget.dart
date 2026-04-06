import 'package:flutter/material.dart';

class AddItemWidget extends StatefulWidget {
  const AddItemWidget({
    super.key,
    required this.onAdd,
    this.prefillItemName,
  });

  final Future<void> Function(String itemName, String quantity, {num? amount}) onAdd;
  final String? prefillItemName;

  @override
  State<AddItemWidget> createState() => _AddItemWidgetState();
}

class _AddItemWidgetState extends State<AddItemWidget> {
  late final TextEditingController _itemNameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _amountController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    try {
      _itemNameController = TextEditingController(text: widget.prefillItemName);
      _quantityController = TextEditingController();
      _amountController = TextEditingController();
    } catch (e) {
      // If controller initialization fails, create empty controllers
      _itemNameController = TextEditingController();
      _quantityController = TextEditingController();
      _amountController = TextEditingController();
      
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Initialization error: ${e.toString()}'),
              duration: const Duration(seconds: 3),
            ),
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _quantityController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final itemName = _itemNameController.text.trim();
    final quantity = _quantityController.text.trim();
    if (itemName.isEmpty || quantity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both item and quantity.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final amountText = _amountController.text.trim();
    final amount = amountText.isEmpty ? null : num.tryParse(amountText);

    setState(() => _isSubmitting = true);
    try {
      await widget.onAdd(itemName, quantity, amount: amount);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      String errorMessage = 'Failed to add item. Try again.';
      
      if (e.toString().contains('permission')) {
        errorMessage = 'You don\'t have permission to add items to this list.';
      } else if (e.toString().contains('not found')) {
        errorMessage = 'Grocery list not found. Please refresh and try again.';
      } else if (e.toString().contains('connection')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('required')) {
        errorMessage = 'Please fill in all required fields.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _itemNameController,
            decoration: const InputDecoration(
              labelText: 'Item name',
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(color: Colors.black, fontSize: 14),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _quantityController,
            style: const TextStyle(color: Colors.black, fontSize: 14),
            decoration: const InputDecoration(
              labelText: 'Quantity (e.g. 2 kg)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.black, fontSize: 14),
            decoration: const InputDecoration(
              labelText: 'Price in NPR (optional)',
              border: OutlineInputBorder(),
              prefixText: 'NPR ',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add Item'),
            ),
          ),
        ],
      ),
    );
  }
}
