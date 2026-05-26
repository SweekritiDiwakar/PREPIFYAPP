import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prepify/home/grocery_list_screen/firestore_service.dart';
import 'package:prepify/home/household_screen/firestore_service.dart';
import 'package:prepify/models/app_user.dart';
import 'package:prepify/services/chat_service.dart';
import 'package:prepify/widgets/chat_input.dart';
import 'package:prepify/widgets/message_bubble.dart';

class HouseholdChatScreen extends StatefulWidget {
  const HouseholdChatScreen({super.key});

  @override
  State<HouseholdChatScreen> createState() => _HouseholdChatScreenState();
}

class _HouseholdChatScreenState extends State<HouseholdChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<_ChatMessage> _pendingMessages = <_ChatMessage>[];

  String _householdId = '';
  bool _loadingHousehold = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadHousehold();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadHousehold() async {
    try {
      final householdId = await ChatService.getCurrentUserHouseholdId();
      if (!mounted) return;
      setState(() {
        _householdId = householdId;
        _loadingHousehold = false;
      });
      debugPrint('HouseholdChat: loaded householdId=$_householdId');
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load household chat.';
        _loadingHousehold = false;
      });
    }
  }

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  String _displayNameForUser(AppUser user) {
    final name = user.name.trim();
    if (name.isNotEmpty) return name;

    final email = user.email.trim();
    if (email.isNotEmpty) return email;

    return 'Member';
  }

  Widget _buildMemberChip({
    required AppUser user,
    required VoidCallback onTap,
  }) {
    final isCurrentUser = user.uid == _auth.currentUser?.uid;
    final displayName = _displayNameForUser(user);
    final initials = displayName.isNotEmpty ? displayName.characters.first.toUpperCase() : 'M';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Chip(
        avatar: CircleAvatar(
          radius: 10,
          backgroundColor: isCurrentUser ? Colors.green.shade200 : Colors.blueGrey.shade200,
          child: Text(
            initials,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ),
        label: Text(
          isCurrentUser ? '$displayName (You)' : displayName,
          overflow: TextOverflow.ellipsis,
        ),
        visualDensity: VisualDensity.compact,
        side: BorderSide(color: isCurrentUser ? Colors.green.shade200 : Colors.grey.shade300),
        backgroundColor: isCurrentUser ? Colors.green.shade50 : Colors.white,
      ),
    );
  }

  Future<void> _confirmRemoveMember(AppUser user) async {
    if (_householdId.isEmpty) return;
    if (user.uid == _auth.currentUser?.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot remove yourself from this screen.')),
      );
      return;
    }

    final displayName = _displayNameForUser(user);
    final shouldRemove = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Remove member',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text('Remove $displayName from this household and its grocery lists?'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Remove'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldRemove != true) return;

    try {
      await GroceryFirestoreService.removeMemberFromHousehold(_householdId, user.uid);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$displayName removed from the household.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove member: $e')),
      );
    }
  }

  Widget _buildHouseholdMembersHeader() {
    if (_householdId.isEmpty) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: GroceryFirestoreService.streamUserLists(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final memberIds = <String>{};
        for (final doc in docs) {
          final members = List<String>.from(doc.data()['members'] ?? const <String>[]);
          memberIds.addAll(members.where((memberId) => memberId.trim().isNotEmpty));
        }

        final displayTitle = docs.length == 1
            ? '${((docs.first.data()['name'] as String?) ?? 'Grocery list').trim()} members'
            : 'Grocery list members';

        if (snapshot.hasError) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.shade100),
            ),
            child: Text(
              'Could not load household members.',
              style: TextStyle(color: Colors.red.shade700),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Loading household members...'),
              ],
            ),
          );
        }

        return FutureBuilder<List<AppUser>>(
          future: HouseholdFirestoreService.getMembersByIds(memberIds.toList()),
          builder: (context, memberSnapshot) {
            final users = memberSnapshot.data ?? <AppUser>[];

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.groups_outlined, size: 18, color: Colors.grey.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          displayTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${users.length} member${users.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (memberSnapshot.connectionState == ConnectionState.waiting && users.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: LinearProgressIndicator(minHeight: 2),
                    )
                  else if (users.isEmpty)
                    Text(
                      'No members found.',
                      style: TextStyle(color: Colors.grey.shade600),
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: users
                            .map(
                              (user) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _buildMemberChip(
                                  user: user,
                                  onTap: () => _confirmRemoveMember(user),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _send(String text) async {
    if (_householdId.isEmpty) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final pendingId = DateTime.now().microsecondsSinceEpoch.toString();
    final senderName = currentUser.displayName?.trim().isNotEmpty == true
        ? currentUser.displayName!.trim()
        : (currentUser.email?.trim().isNotEmpty == true
            ? currentUser.email!.trim()
            : 'You');

    setState(() {
      _pendingMessages.add(
        _ChatMessage(
          messageId: pendingId,
          senderId: currentUser.uid,
          senderName: senderName,
          messageText: trimmed,
          createdAt: DateTime.now(),
        ),
      );
    });
    _scrollToLatest();

    try {
      debugPrint('HouseholdChat: sending message pendingId=$pendingId text="$trimmed"');
      // Pass the client-generated pendingId as the document id so the server
      // write uses the same id. This prevents a brief optimistic flicker where
      // the pending message is removed because a different server id appears.
      final sentId = await ChatService.sendHouseholdMessage(
        householdId: _householdId,
        messageText: trimmed,
        messageId: pendingId,
      );
      debugPrint('HouseholdChat: send completed pendingId=$pendingId sentId=$sentId');
      // Do not remove the pending message here; wait for the Firestore
      // snapshot to include the saved document (it will have the same id),
      // at which point the UI will render the server-backed message from
      // the stream and the pending item will be filtered out automatically.
    } catch (e) {
      debugPrint('HouseholdChat: send failed pendingId=$pendingId error=$e');
      if (!mounted) return;
      // Keep the pending message visible so it doesn't briefly flash away.
      // Show a SnackBar with a Retry action so the user can attempt again.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: $e'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () async {
              try {
                debugPrint('HouseholdChat: retrying send pendingId=$pendingId');
                await ChatService.sendHouseholdMessage(
                  householdId: _householdId,
                  messageText: trimmed,
                  messageId: pendingId,
                );
                debugPrint('HouseholdChat: retry send completed pendingId=$pendingId');
              } catch (err) {
                debugPrint('HouseholdChat: retry failed pendingId=$pendingId error=$err');
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Retry failed: $err')));
              }
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingHousehold) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(child: Text(_error));
    }

    if (_householdId.isEmpty) {
      // Show a small debug panel so the user can inspect their profile
      // document and see whether a householdId is set.
      return Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: Row(
              children: [
                const Text('Household ID:', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _householdId.isEmpty ? '<empty>' : _householdId,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final user = _auth.currentUser;
                    if (user == null) return;
                    try {
                      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
                      if (!mounted) return;
                      showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('User document'),
                          content: SingleChildScrollView(
                            child: Text(doc.data()?.toString() ?? '<no data>'),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
                          ],
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load user doc: $e')));
                    }
                  },
                  child: const Text('Show user doc'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () async {
                    final user = _auth.currentUser;
                    if (user == null) return;
                    try {
                      QuerySnapshot<Map<String, dynamic>> snap;
                      if (_householdId.isNotEmpty) {
                        snap = await FirebaseFirestore.instance
                            .collection('messages')
                            .where('householdId', isEqualTo: _householdId)
                            .orderBy('createdAt', descending: true)
                            .limit(50)
                            .get();
                      } else {
                        snap = await FirebaseFirestore.instance
                            .collection('messages')
                            .where('senderId', isEqualTo: user.uid)
                            .orderBy('createdAt', descending: true)
                            .limit(50)
                            .get();
                      }
                      if (!mounted) return;
                      final items = snap.docs.map((d) => d.data().toString()).join('\n\n');
                      showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Recent messages (debug)'),
                          content: SingleChildScrollView(child: Text(items.isEmpty ? '<no messages>' : items)),
                          actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close'))],
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to fetch messages: $e')));
                    }
                  },
                  child: const Text('Fetch recent messages'),
                ),
              ],
            ),
          ),
          const Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Join or create a household to start household chat.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildHouseholdMembersHeader(),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: ChatService.streamHouseholdMessages(_householdId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Unable to load chat messages for this account.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              debugPrint('HouseholdChat: snapshot has ${snapshot.data?.docs.length ?? 0} docs');

              final docs = snapshot.data?.docs ?? [];
              final remoteMessageIds = docs
                  .map((doc) => (doc.data()['messageId'] as String?) ?? doc.id)
                  .toSet();
              final visiblePending = _pendingMessages
                  .where((message) => !remoteMessageIds.contains(message.messageId))
                  .toList();
              _scrollToLatest();

              if (docs.isEmpty && visiblePending.isEmpty) {
                return const Center(
                  child: Text('No messages yet. Start the conversation.'),
                );
              }

              final combined = <_ChatMessage>[
                ...docs.map((doc) {
                  final data = doc.data();
                  final senderId = (data['senderId'] as String?) ?? '';
                  final senderName = (data['senderName'] as String?) ?? 'User';
                  final messageText = (data['messageText'] as String?) ?? '';
                  final ts = data['createdAt'];
                  final timestamp = ts is Timestamp ? ts.toDate() : null;
                  return _ChatMessage(
                    messageId: (data['messageId'] as String?) ?? doc.id,
                    senderId: senderId,
                    senderName: senderName,
                    messageText: messageText,
                    createdAt: timestamp,
                  );
                }),
                ...visiblePending,
              ]..sort((a, b) {
                  final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
                  final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
                  return aTime.compareTo(bTime);
                });

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                itemCount: combined.length,
                itemBuilder: (context, index) {
                  final message = combined[index];

                  return MessageBubble(
                    messageText: message.messageText,
                    senderName: message.senderName,
                    timestamp: message.createdAt,
                    isCurrentUser: message.senderId == _auth.currentUser?.uid,
                  );
                },
              );
            },
          ),
        ),
        ChatInput(
          hintText: 'Message household...',
          onSend: _send,
        ),
      ],
    );
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.messageText,
    required this.createdAt,
  });

  final String messageId;
  final String senderId;
  final String senderName;
  final String messageText;
  final DateTime? createdAt;
}
