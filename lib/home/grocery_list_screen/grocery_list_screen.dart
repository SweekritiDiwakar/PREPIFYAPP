import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prepify/home/profile_screen/profile_screen.dart';
import 'package:prepify/home/profile_screen/edit_profile_screen.dart';
import 'package:prepify/home/grocery_list_screen/add_item_widget.dart';
import 'package:prepify/home/grocery_list_screen/firestore_service.dart';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  String? _selectedListId;
  final Map<String, String> _userNameCache = {};

  Future<void> _showCreateListDialog() async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Grocery List'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'e.g. Weekly Groceries',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final name = controller.text.trim();
              if (name.isEmpty) return;
              try {
                final listId = await GroceryFirestoreService.createGroceryList(
                  name,
                );
                if (!mounted) return;
                setState(() {
                  _selectedListId = listId;
                });
                navigator.pop();
              } catch (_) {
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(content: Text('Could not create list.')),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  Future<void> _openAddItemSheet(String listId) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddItemWidget(
        onAdd: (itemName, quantity) {
          return GroceryFirestoreService.addItem(
            listId: listId,
            itemName: itemName,
            quantity: quantity,
          );
        },
      ),
    );
  }

  Future<void> _showInviteMemberDialog(String listId) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite Member'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Enter member email',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await GroceryFirestoreService.addMemberByEmail(
                  listId: listId,
                  email: controller.text,
                );
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Member added to list.')),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                );
              }
            },
            child: const Text('Invite'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  Future<void> _preloadUserNames(List<String> userIds) async {
    final missing = userIds.where((id) => !_userNameCache.containsKey(id)).toList();
    if (missing.isEmpty) return;
    final names = await GroceryFirestoreService.getUserNamesByIds(missing);
    if (!mounted) return;
    setState(() {
      _userNameCache.addAll(names);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: _selectedListId == null
          ? null
          : FloatingActionButton(
              onPressed: () => _openAddItemSheet(_selectedListId!),
              child: const Icon(Icons.add),
            ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                      );
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: const AssetImage('assets/images/me.jpeg'),
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
                  Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 40,
                        width: 40,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'PREPIFY',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileScreen()),
                      );
                    },
                    child: const Icon(Icons.settings, size: 28, color: Colors.black),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios, color: Colors.green, size: 20),
              ),

              const SizedBox(height: 20),

              const Text(
                "Grocery List",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: GroceryFirestoreService.streamUserLists(),
                  builder: (context, listSnapshot) {
                    if (listSnapshot.hasError) {
                      return const Center(
                        child: Text('Failed to load grocery lists.'),
                      );
                    }
                    if (!listSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final lists = listSnapshot.data!.docs;
                    if (lists.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('No grocery list found.'),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _showCreateListDialog,
                              child: const Text('Create Your First List'),
                            ),
                          ],
                        ),
                      );
                    }

                    _selectedListId ??= lists.first.id;
                    if (!lists.any((doc) => doc.id == _selectedListId)) {
                      _selectedListId = lists.first.id;
                    }
                    final selected = lists.firstWhere(
                      (doc) => doc.id == _selectedListId,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedListId,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                items: lists
                                    .map(
                                      (doc) => DropdownMenuItem<String>(
                                        value: doc.id,
                                        child: Text(
                                          (doc.data()['name'] as String?) ??
                                              'Untitled',
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() => _selectedListId = value);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _showCreateListDialog,
                              icon: const Icon(Icons.playlist_add),
                            ),
                            IconButton(
                              onPressed: () => _showInviteMemberDialog(selected.id),
                              icon: const Icon(Icons.person_add_alt_1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: GroceryFirestoreService.streamItems(selected.id),
                          builder: (context, itemSnapshot) {
                            if (itemSnapshot.hasError) {
                              return const Expanded(
                                child: Center(
                                  child: Text('Failed to load grocery items.'),
                                ),
                              );
                            }
                            if (!itemSnapshot.hasData) {
                              return const Expanded(
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final items = [...itemSnapshot.data!.docs]
                              ..sort((a, b) {
                                final aChecked =
                                    (a.data()['isChecked'] as bool?) ?? false;
                                final bChecked =
                                    (b.data()['isChecked'] as bool?) ?? false;
                                if (aChecked == bChecked) return 0;
                                return aChecked ? 1 : -1;
                              });

                            final checkedCount = items
                                .where(
                                  (doc) =>
                                      (doc.data()['isChecked'] as bool?) ??
                                      false,
                                )
                                .length;
                            final addedByIds = items
                                .map((doc) => (doc.data()['addedBy'] as String?) ?? '')
                                .where((id) => id.isNotEmpty)
                                .toSet()
                                .toList();
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _preloadUserNames(addedByIds);
                            });

                            return Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$checkedCount of ${items.length} purchased',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: items.length,
                                      itemBuilder: (context, index) {
                                        final itemDoc = items[index];
                                        final item = itemDoc.data();
                                        final isChecked =
                                            (item['isChecked'] as bool?) ??
                                            false;
                                        final itemName =
                                            (item['itemName'] as String?) ?? '';
                                        final quantity =
                                            (item['quantity'] as String?) ?? '';
                                        final addedBy =
                                            (item['addedBy'] as String?) ?? '';
                                        final addedByLabel = addedBy ==
                                                FirebaseAuth.instance.currentUser?.uid
                                            ? 'You'
                                            : (_userNameCache[addedBy] ?? addedBy);

                                        return Dismissible(
                                          key: Key(itemDoc.id),
                                          direction: DismissDirection.endToStart,
                                          background: Container(
                                            alignment: Alignment.centerRight,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                            ),
                                            color: Colors.red,
                                            child: const Icon(
                                              Icons.delete,
                                              color: Colors.white,
                                            ),
                                          ),
                                          onDismissed: (_) async {
                                            await GroceryFirestoreService
                                                .deleteItem(
                                              listId: selected.id,
                                              itemId: itemDoc.id,
                                            );
                                          },
                                          child: Card(
                                            elevation: 0,
                                            color: Colors.grey[100],
                                            child: CheckboxListTile(
                                              value: isChecked,
                                              onChanged: (value) async {
                                                await GroceryFirestoreService
                                                    .toggleItemChecked(
                                                  listId: selected.id,
                                                  itemId: itemDoc.id,
                                                  isChecked: value ?? false,
                                                );
                                              },
                                              title: Text(
                                                itemName,
                                                style: TextStyle(
                                                  decoration: isChecked
                                                      ? TextDecoration.lineThrough
                                                      : null,
                                                ),
                                              ),
                                              subtitle: Text(
                                                'Qty: $quantity • Added by: $addedByLabel',
                                              ),
                                              controlAffinity:
                                                  ListTileControlAffinity.leading,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
