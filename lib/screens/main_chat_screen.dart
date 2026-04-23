import 'package:flutter/material.dart';
import 'package:prepify/screens/chatbot_screen.dart';
import 'package:prepify/screens/household_chat_screen.dart';
import 'package:prepify/widgets/fab_menu.dart';

class MainChatScreen extends StatefulWidget {
  const MainChatScreen({super.key});

  @override
  State<MainChatScreen> createState() => _MainChatScreenState();
}

class _MainChatScreenState extends State<MainChatScreen> {
  ChatMode _currentMode = ChatMode.household;

  @override
  Widget build(BuildContext context) {
    final isHousehold = _currentMode == ChatMode.household;

    return Scaffold(
      backgroundColor: const Color(0xFFEDE5DD),
      appBar: AppBar(
        title: Text(isHousehold ? 'Household Chat' : 'Prepify Chatbot'),
        backgroundColor: const Color(0xFF075E54),
        foregroundColor: Colors.white,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: isHousehold
            ? const HouseholdChatScreen(key: ValueKey('household_chat'))
            : const ChatbotScreen(key: ValueKey('bot_chat')),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70.0),
        child: FabMenu(
          currentMode: _currentMode,
          onModeSelected: (mode) {
            if (_currentMode == mode) return;
            setState(() => _currentMode = mode);
          },
        ),
      ),
    );
  }
}
