import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.profileImage,
    required this.householdId,
    this.createdAt,
    this.completedRecipes = 0,
    this.badges = const [],
  });

  final String uid;
  final String name;
  final String email;
  final String profileImage;
  final String householdId;
  final Timestamp? createdAt;
  final int completedRecipes;
  final List<String> badges;

  factory AppUser.fromFirestore(
    String uid,
    Map<String, dynamic> data,
  ) {
    final resolvedName = ((data['name'] as String?) ?? (data['username'] as String?) ?? '').trim();
    final resolvedProfileImage =
        ((data['profileImage'] as String?) ?? (data['photoUrl'] as String?) ?? '').trim();

    return AppUser(
      uid: uid,
      name: resolvedName,
      email: (data['email'] as String?) ?? '',
      profileImage: resolvedProfileImage,
      householdId: (data['householdId'] as String?) ?? '',
      createdAt: data['createdAt'] as Timestamp?,
      completedRecipes: (data['completedRecipes'] as num?)?.toInt() ?? 0,
      badges: (data['badges'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'username': name,
      'email': email,
      'profileImage': profileImage,
      'photoUrl': profileImage,
      'householdId': householdId,
      'createdAt': createdAt,
      'completedRecipes': completedRecipes,
      'badges': badges,
    };
  }

  AppUser copyWith({
    String? name,
    String? email,
    String? profileImage,
    String? householdId,
    Timestamp? createdAt,
    int? completedRecipes,
    List<String>? badges,
  }) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      householdId: householdId ?? this.householdId,
      createdAt: createdAt ?? this.createdAt,
      completedRecipes: completedRecipes ?? this.completedRecipes,
      badges: badges ?? this.badges,
    );
  }
}
