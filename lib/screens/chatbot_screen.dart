import 'package:flutter/material.dart';
import 'package:prepify/services/ai_chatbot_service.dart';
import 'package:prepify/widgets/chat_input.dart';
import 'package:prepify/widgets/message_bubble.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final AiChatbotService _aiService = AiChatbotService();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMessage> _messages = <_ChatMessage>[
    _ChatMessage(
      senderId: 'assistant',
      senderName: 'Prepify Assistant',
      text: 'Hi! Ask me about groceries, recipes, or app help.',
      createdAt: DateTime.now(),
    ),
  ];

  bool _isLoading = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _onSend(String text) async {
    final userMessage = _ChatMessage(
      senderId: 'me',
      senderName: 'You',
      text: text,
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });
    _scrollToLatest();

    final response = await _aiService.sendMessage(text);

    if (!mounted) return;
    setState(() {
      _messages.add(
        _ChatMessage(
          senderId: 'assistant',
          senderName: 'Prepify Assistant',
          text: response,
          createdAt: DateTime.now(),
        ),
      );
      _isLoading = false;
    });
    _scrollToLatest();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            itemCount: _messages.length + (_isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (_isLoading && index == _messages.length) {
                return const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 8, top: 8),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }

              final message = _messages[index];
              return MessageBubble(
                messageText: message.text,
                senderName: message.senderName,
                timestamp: message.createdAt,
                isCurrentUser: message.senderId == 'me',
              );
            },
          ),
        ),
        ChatInput(
          hintText: 'Ask the assistant...',
          enabled: !_isLoading,
          onSend: _onSend,
        ),
      ],
    );
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
  });

  final String senderId;
  final String senderName;
  final String text;
  final DateTime createdAt;
}
