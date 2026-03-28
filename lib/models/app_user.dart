import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.profileImage,
    required this.householdId,
    this.createdAt,
  });

  final String uid;
  final String name;
  final String email;
  final String profileImage;
  final String householdId;
  final Timestamp? createdAt;

  factory AppUser.fromFirestore(
    String uid,
    Map<String, dynamic> data,
  ) {
    return AppUser(
      uid: uid,
      name: (data['name'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      profileImage: (data['profileImage'] as String?) ?? '',
      householdId: (data['householdId'] as String?) ?? '',
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'householdId': householdId,
      'createdAt': createdAt,
    };
  }

  AppUser copyWith({
    String? name,
    String? email,
    String? profileImage,
    String? householdId,
    Timestamp? createdAt,
  }) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      householdId: householdId ?? this.householdId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
