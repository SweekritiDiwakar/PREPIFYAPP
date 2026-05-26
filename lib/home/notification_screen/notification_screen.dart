import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prepify/home/profile_screen/profile_screen.dart';
import 'package:prepify/home/profile_screen/edit_profile_screen.dart';
import 'package:prepify/services/user_profile_service.dart';

class AppNotificationScreen extends StatelessWidget {
  const AppNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage:
                              const AssetImage('assets/images/me.jpeg'),
                          backgroundColor: Colors.grey[200],
                        ),
                      ),
                      Column(
                        children: [
                          Image.asset('assets/images/logo.png',
                              height: 40, width: 40),
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
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProfileScreen()),
                        ),
                        child: const Icon(Icons.settings,
                            size: 28, color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(Icons.arrow_back_ios,
                          size: 18, color: Color(0xFF9CCC65)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Serif',
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const Expanded(child: _NotificationsFeed()),
          ],
        ),
      ),
    );
  }
}

class _NotificationsFeed extends StatefulWidget {
  const _NotificationsFeed();

  @override
  State<_NotificationsFeed> createState() => _NotificationsFeedState();
}

class _NotificationsFeedState extends State<_NotificationsFeed> {
  String? _currentUserId;
  String? _householdId;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _userNotificationsStream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _householdEventsStream;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final currentUserId = user?.uid;
      final id = await UserProfileService.getCurrentUserHouseholdId();
      if (!mounted) return;
      setState(() {
        _currentUserId = currentUserId;
        _householdId = id.isNotEmpty ? id : null;
        if (_currentUserId != null) {
          _userNotificationsStream = FirebaseFirestore.instance
              .collection('notifications')
              .where('userId', isEqualTo: _currentUserId)
              .snapshots();
        }
        if (_householdId != null) {
          _householdEventsStream = FirebaseFirestore.instance
              .collection('household_events')
              .where('householdId', isEqualTo: _householdId)
              .snapshots();
        }
        _loading = false;
      });
    } catch (e) {
      debugPrint("Init error: $e");
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildSectionTitle('New for you'),
        const SizedBox(height: 12),
        _buildUserNotifications(),
        if (_householdId != null && _householdEventsStream != null) ...[
          const SizedBox(height: 24),
          _buildSectionTitle('Household activity'),
          const SizedBox(height: 12),
          _buildHouseholdEvents(),
        ],
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildUserNotifications() {
    if (_currentUserId == null || _userNotificationsStream == null) {
      return _buildEmpty(
        title: 'No personal notifications yet.',
        subtitle: 'You will see list invitations and direct updates here.',
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _userNotificationsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Could not load notifications: ${snapshot.error}'),
          );
        }

        final docs = _sortedDocs(snapshot.data?.docs ?? []);
        if (docs.isEmpty) {
          return _buildEmpty(
            title: 'No personal notifications yet.',
            subtitle: 'You will see list invitations and direct updates here.',
          );
        }

        return Column(
          children: docs.map((d) => _NotificationTile(data: d.data())).toList(),
        );
      },
    );
  }

  Widget _buildHouseholdEvents() {
    if (_householdId == null || _householdEventsStream == null) {
      return _buildEmpty(
        title: 'No household activity yet.',
        subtitle: 'Join a household to see shared updates here.',
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _householdEventsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Could not load notifications: ${snapshot.error}'),
          );
        }

        final docs = _sortedDocs(snapshot.data?.docs ?? []);
        if (docs.isEmpty) {
          return _buildEmpty(
            title: 'No household activity yet.',
            subtitle: 'Join a household to see shared updates here.',
          );
        }

        return Column(
          children: docs.map((d) => _NotificationTile(data: d.data())).toList(),
        );
      },
    );
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sortedDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final sorted = [...docs];
    sorted.sort((a, b) {
      final aTs = (a.data()['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
      final bTs = (b.data()['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
      return bTs.compareTo(aTs);
    });
    return sorted;
  }

  Widget _buildEmpty({
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_none_outlined,
                size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final type = (data['type'] as String?) ?? '';
    final title = (data['title'] as String?) ?? _titleForType(type);
    final body = (data['body'] as String?) ??
      (data['message'] as String?) ??
      '';
    final ts = data['createdAt'];
    final timeStr = (ts is Timestamp)
        ? DateFormat('MMM d, h:mm a').format(ts.toDate())
        : '';

    final icon = _iconForType(type);
    final color = _colorForType(type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
                if (timeStr.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(timeStr,
                      style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'low_stock_alert':
        return Icons.warning_amber_rounded;
      case 'grocery_item_added':
        return Icons.add_shopping_cart;
      case 'grocery_item_purchased':
        return Icons.check_circle_outline;
      case 'household_member_joined':
        return Icons.group_add_outlined;
      case 'grocery_list_member_added':
        return Icons.person_add_alt_1;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _titleForType(String type) {
    switch (type) {
      case 'grocery_list_member_added':
        return 'Added to grocery list';
      case 'grocery_item_added':
        return 'New grocery item';
      case 'grocery_item_purchased':
        return 'Item purchased';
      case 'household_member_joined':
        return 'New household member';
      case 'low_stock_alert':
        return 'Low stock alert';
      default:
        return 'Notification';
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'low_stock_alert':
        return Colors.red;
      case 'grocery_item_added':
        return const Color(0xFFD84315);
      case 'grocery_item_purchased':
        return const Color(0xFF558B2F);
      case 'household_member_joined':
        return Colors.blue;
      case 'grocery_list_member_added':
        return const Color(0xFF1565C0);
      default:
        return Colors.grey;
    }
  }
}