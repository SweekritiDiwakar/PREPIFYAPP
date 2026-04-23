import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.messageText,
    required this.senderName,
    required this.timestamp,
    required this.isCurrentUser,
  });

  final String messageText;
  final String senderName;
  final DateTime? timestamp;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final timeText = timestamp == null
        ? 'sending...'
        : DateFormat('h:mm a').format(timestamp!);

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: isCurrentUser ? const Color(0xFFDCF8C6) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isCurrentUser ? 14 : 2),
            bottomRight: Radius.circular(isCurrentUser ? 2 : 14),
          ),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              senderName,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF616161),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              messageText,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              timeText,
              style: const TextStyle(fontSize: 10, color: Color(0xFF757575)),
            ),
          ],
        ),
      ),
    );
  }
}
