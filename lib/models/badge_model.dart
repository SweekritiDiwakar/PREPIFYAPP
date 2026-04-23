import 'package:cloud_firestore/cloud_firestore.dart';

class AppBadge {
  final String badgeId;
  final String title;
  final String description;
  final String icon;

  AppBadge({
    required this.badgeId,
    required this.title,
    required this.description,
    required this.icon,
  });

  factory AppBadge.fromFirestore(String id, Map<String, dynamic> data) {
    return AppBadge(
      badgeId: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'icon': icon,
    };
  }
}

class UserBadge {
  final String userBadgeId;
  final String userId;
  final String badgeId;
  final DateTime earnedAt;

  UserBadge({
    required this.userBadgeId,
    required this.userId,
    required this.badgeId,
    required this.earnedAt,
  });

  factory UserBadge.fromFirestore(String id, Map<String, dynamic> data) {
    return UserBadge(
      userBadgeId: id,
      userId: data['userId'] ?? '',
      badgeId: data['badgeId'] ?? '',
      earnedAt: (data['earnedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'badgeId': badgeId,
      'earnedAt': Timestamp.fromDate(earnedAt),
    };
  }
}
