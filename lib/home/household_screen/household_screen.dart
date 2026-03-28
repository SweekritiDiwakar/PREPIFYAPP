import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prepify/home/household_screen/create_household.dart';
import 'package:prepify/home/household_screen/firestore_service.dart';
import 'package:prepify/home/household_screen/join_household.dart';

class HouseholdScreen extends StatelessWidget {
  const HouseholdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Household')),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: HouseholdFirestoreService.streamUserHousehold(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Could not load household.'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  CreateHouseholdSection(),
                  SizedBox(height: 12),
                  JoinHouseholdSection(),
                ],
              );
            }

            final householdDoc = docs.first;
            final data = householdDoc.data();
            final name = (data['name'] as String?) ?? 'Unnamed Household';
            final inviteCode = (data['inviteCode'] as String?) ?? '';
            final members = ((data['members'] as List<dynamic>?) ?? [])
                .map((e) => e.toString())
                .where((e) => e.trim().isNotEmpty)
                .toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Invite code: $inviteCode'),
                        const SizedBox(height: 12),
                        const Text(
                          'Members',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        FutureBuilder(
                          future: HouseholdFirestoreService.getMembersByIds(members),
                          builder: (context, memberSnapshot) {
                            if (!memberSnapshot.hasData) {
                              return const Padding(
                                padding: EdgeInsets.all(8),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              );
                            }

                            final users = memberSnapshot.data!;
                            if (users.isEmpty) {
                              return const Text('No members yet.');
                            }
                            return Column(
                              children: users
                                  .map(
                                    (user) => ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: const Icon(Icons.person_outline),
                                      title: Text(
                                        user.name.isEmpty ? 'No name' : user.name,
                                      ),
                                      subtitle: Text(user.email),
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () async {
                              try {
                                await HouseholdFirestoreService.leaveHousehold();
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('You left the household.'),
                                  ),
                                );
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      e.toString().replaceFirst('Exception: ', ''),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: const Text('Leave Household'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
