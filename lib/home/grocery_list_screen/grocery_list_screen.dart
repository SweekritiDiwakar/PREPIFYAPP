import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prepify/home/profile_screen/profile_screen.dart';
import 'package:prepify/home/profile_screen/edit_profile_screen.dart';
import 'package:prepify/home/grocery_list_screen/add_item_widget.dart';
import 'package:prepify/home/grocery_list_screen/firestore_service.dart';
import 'package:prepify/home/household_screen/firestore_service.dart';
import 'package:prepify/services/nepali_calendar_service.dart';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  String? _selectedListId;
  final Map<String, String> _userNameCache = {};
  List<String> _festivalSuggestions = [];
  bool _showSuggestions = false;

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

  Future<void> _openAddItemSheet(String listId, {String? itemName}) async {
    if (listId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid grocery list selected'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    
    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => AddItemWidget(
          prefillItemName: itemName,
          onAdd: (itemName, quantity, {num? amount}) {
            return GroceryFirestoreService.addItem(
              listId: listId,
              itemName: itemName,
              quantity: quantity,
              amount: amount,
            );
          },
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening add item form: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _showInviteMemberDialog(String listId) async {
    final joinCodeController = TextEditingController();
    bool isJoining = false;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Household Options'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Invite members', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Share this code with your household members:'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: FutureBuilder<String>(
                    future: _getHouseholdInviteCode(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            snapshot.data!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          if (snapshot.data! != 'NO HOUSEHOLD')
                            IconButton(
                              icon: const Icon(Icons.copy, size: 20),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: snapshot.data!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Copied!')),
                                );
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Join a Household', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: joinCodeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    hintText: 'Enter code',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: isJoining
                        ? null
                        : () async {
                            final code = joinCodeController.text.trim().toUpperCase();
                            if (code.isEmpty) return;
                            setState(() => isJoining = true);
                            try {
                              await HouseholdFirestoreService.joinHouseholdByInviteCode(code);
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Successfully joined household!')),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => isJoining = false);
                            }
                          },
                    child: Text(isJoining ? 'Joining...' : 'Join Household'),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        });
      },
    );
  }

  Future<String> _getHouseholdInviteCode() async {
    try {
      final householdDoc = await HouseholdFirestoreService.fetchUserHousehold();
      if (householdDoc != null) {
        return (householdDoc.data()?['inviteCode'] as String?) ?? 'NO CODE';
      }
    } catch (_) {}
    return 'NO HOUSEHOLD';
  }

  @override
void initState() {
  super.initState();
  // Set up global error handler for this screen
  FlutterError.onError = (FlutterErrorDetails details) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  };
  _loadFestivalSuggestions();
}

Future<void> _loadFestivalSuggestions() async {
    try {
      final suggestions = NepaliCalendarService.fetchFestivalGrocerySuggestions();
      if (mounted) {
        setState(() {
          _festivalSuggestions = suggestions;
          _showSuggestions = suggestions.isNotEmpty;
        });
      }
    } catch (e) {
      // Silently fail if suggestions can't be loaded, but log for debugging
      debugPrint('Error loading festival suggestions: $e');
      if (mounted) {
        setState(() {
          _festivalSuggestions = [];
          _showSuggestions = false;
        });
      }
    }
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
              onPressed: () {
                if (_selectedListId != null && _selectedListId!.isNotEmpty) {
                  _openAddItemSheet(_selectedListId!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a grocery list first'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                }
              },
              child: const Icon(Icons.add),
            ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Grocery List",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Serif',
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Nepali Calendar and Festival Suggestions
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F8E8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF9CCC65), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Color(0xFF9CCC65), size: 20),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              try {
                                final nepaliDate = NepaliCalendarService.getTodayNepaliDate();
                                return Text(
                                  'आजको मिति: $nepaliDate',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2E7D32),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                );
                              } catch (e) {
                                return const Text(
                                  'आजको मिति: Loading...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2E7D32),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    if (_showSuggestions && _festivalSuggestions.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'आगामी पर्वका लागि सुझावहरू:',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF558B2F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: _festivalSuggestions.take(5).map((suggestion) {
                          return GestureDetector(
                            onTap: () {
                              if (_selectedListId != null) {
                                _openAddItemSheet(_selectedListId!, itemName: suggestion);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please select a grocery list first')),
                                );
                              }
                            },
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 120),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFF9CCC65), width: 0.5),
                              ),
                              child: Text(
                                suggestion,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF2E7D32),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
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
                    // Sort client-side by createdAt descending (avoids composite index requirement)
                    final sortedLists = [...lists]..sort((a, b) {
                        final aTs = a.data()['createdAt'];
                        final bTs = b.data()['createdAt'];
                        if (aTs == null && bTs == null) return 0;
                        if (aTs == null) return 1;
                        if (bTs == null) return -1;
                        return (bTs as dynamic).compareTo(aTs as dynamic);
                      });
                    final lists2 = sortedLists;
                    if (lists2.isEmpty) {
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

                    _selectedListId ??= lists2.first.id;
                    if (!lists2.any((doc) => doc.id == _selectedListId)) {
                      _selectedListId = lists2.first.id;
                    }
                    final selected = lists2.firstWhere(
                      (doc) => doc.id == _selectedListId,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedListId,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                ),
                                items: lists
                                    .map(
                                      (doc) => DropdownMenuItem<String>(
                                        value: doc.id,
                                        child: Text(
                                          (doc.data()['name'] as String?) ??
                                              'Untitled',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
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
                            const SizedBox(width: 4),
                            IconButton(
                              onPressed: _showCreateListDialog,
                              icon: const Icon(Icons.playlist_add),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(8),
                            ),
                            IconButton(
                              onPressed: () => _showInviteMemberDialog(selected.id),
                              icon: const Icon(Icons.person_add_alt_1),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(8),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Active members indicator
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance.collection('grocery_lists').doc(selected.id).collection('items').limit(5).snapshots(),
                          builder: (context, activitySnapshot) {
                            if (!activitySnapshot.hasData) return const SizedBox.shrink();
                            
                            final recentItems = activitySnapshot.data!.docs;
                            final activeMembers = <String>{};
                            
                            for (final item in recentItems) {
                              final addedBy = item.data()['addedBy'] as String?;
                              if (addedBy != null) {
                                activeMembers.add(addedBy);
                              }
                            }
                            
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.people, size: 16, color: Colors.blue),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${activeMembers.length} active member${activeMembers.length == 1 ? '' : 's'}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
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
                                                  itemName: itemName,
                                                  quantity: quantity,
                                                  amount: (item['amount'] as num?),
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
