import 'package:flutter/material.dart';
import 'package:prepify/home/household_screen/firestore_service.dart';

class JoinHouseholdSection extends StatefulWidget {
  const JoinHouseholdSection({super.key, this.onCompleted});

  final VoidCallback? onCompleted;

  @override
  State<JoinHouseholdSection> createState() => _JoinHouseholdSectionState();
}

class _JoinHouseholdSectionState extends State<JoinHouseholdSection> {
  final TextEditingController _inviteController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _inviteController.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    setState(() => _isLoading = true);
    try {
      await HouseholdFirestoreService.joinHouseholdByInviteCode(
        _inviteController.text,
      );
      if (!mounted) return;
      _inviteController.clear();
      widget.onCompleted?.call();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Joined household.')));
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
              'Join Household',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _inviteController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Invite Code',
                hintText: 'Enter 6-character code',
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _join,
                child: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Join'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
