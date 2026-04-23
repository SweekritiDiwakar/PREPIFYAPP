import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  Future<void> _send(String text) async {
    if (_householdId.isEmpty) return;
    await ChatService.sendHouseholdMessage(
      householdId: _householdId,
      messageText: text,
    );
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
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Join or create a household to start household chat.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: ChatService.streamHouseholdMessages(_householdId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];
              _scrollToLatest();

              if (docs.isEmpty) {
                return const Center(
                  child: Text('No messages yet. Start the conversation.'),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data();
                  final senderId = (data['senderId'] as String?) ?? '';
                  final senderName = (data['senderName'] as String?) ?? 'User';
                  final messageText = (data['messageText'] as String?) ?? '';
                  final ts = data['createdAt'];
                  final timestamp = ts is Timestamp ? ts.toDate() : null;

                  return MessageBubble(
                    messageText: messageText,
                    senderName: senderName,
                    timestamp: timestamp,
                    isCurrentUser: senderId == _auth.currentUser?.uid,
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
