import 'package:flutter/material.dart';

enum ChatMode { household, bot }

class FabMenu extends StatefulWidget {
  const FabMenu({
    super.key,
    required this.currentMode,
    required this.onModeSelected,
  });

  final ChatMode currentMode;
  final ValueChanged<ChatMode> onModeSelected;

  @override
  State<FabMenu> createState() => _FabMenuState();
}

class _FabMenuState extends State<FabMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    setState(() => _isOpen = !_isOpen);
    if (_isOpen) {
      await _controller.forward();
    } else {
      await _controller.reverse();
    }
  }

  Future<void> _select(ChatMode mode) async {
    widget.onModeSelected(mode);
    await _toggle();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizeTransition(
          sizeFactor: _expandAnimation,
          axisAlignment: -1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _OptionButton(
                icon: Icons.home_work_outlined,
                label: 'Household Chat',
                selected: widget.currentMode == ChatMode.household,
                onTap: () => _select(ChatMode.household),
              ),
              const SizedBox(height: 8),
              _OptionButton(
                icon: Icons.smart_toy_outlined,
                label: 'Chatbot',
                selected: widget.currentMode == ChatMode.bot,
                onTap: () => _select(ChatMode.bot),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        FloatingActionButton(
          heroTag: 'chat_mode_fab',
          backgroundColor: const Color(0xFF128C7E),
          onPressed: _toggle,
          child: AnimatedRotation(
            turns: _isOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color:
                    selected ? const Color(0xFF128C7E) : const Color(0xFF424242),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? const Color(0xFF128C7E)
                      : const Color(0xFF424242),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
