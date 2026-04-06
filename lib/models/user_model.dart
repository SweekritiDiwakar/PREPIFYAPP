import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String bio;
  final String photoUrl;
  final List<String> followers;
  final List<String> following;
  final bool isPrivate;
  final bool showFavoritesPublicly;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.bio,
    required this.photoUrl,
    required this.followers,
    required this.following,
    required this.isPrivate,
    required this.showFavoritesPublicly,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      bio: data['bio'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      followers: List<String>.from(data['followers'] ?? []),
      following: List<String>.from(data['following'] ?? []),
      isPrivate: data['isPrivate'] ?? false,
      showFavoritesPublicly: data['showFavoritesPublicly'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'email': email,
      'bio': bio,
      'photoUrl': photoUrl,
      'followers': followers,
      'following': following,
      'isPrivate': isPrivate,
      'showFavoritesPublicly': showFavoritesPublicly,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? username,
    String? email,
    String? bio,
    String? photoUrl,
    List<String>? followers,
    List<String>? following,
    bool? isPrivate,
    bool? showFavoritesPublicly,
  }) {
    return UserModel(
      uid: uid,
      username: username ?? this.username,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      isPrivate: isPrivate ?? this.isPrivate,
      showFavoritesPublicly: showFavoritesPublicly ?? this.showFavoritesPublicly,
      createdAt: createdAt,
    );
  }
}
