import 'package:flutter/material.dart';
import 'package:prepify/home/household_screen/firestore_service.dart';

class CreateHouseholdSection extends StatefulWidget {
  const CreateHouseholdSection({super.key, this.onCompleted});

  final VoidCallback? onCompleted;

  @override
  State<CreateHouseholdSection> createState() => _CreateHouseholdSectionState();
}

class _CreateHouseholdSectionState extends State<CreateHouseholdSection> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    setState(() => _isLoading = true);
    try {
      await HouseholdFirestoreService.createHousehold(
        name: _nameController.text,
      );
      if (!mounted) return;
      _nameController.clear();
      widget.onCompleted?.call();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Household created.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Household',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Household name',
                hintText: 'e.g. My Family',
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _create,
                child: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
