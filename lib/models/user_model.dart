import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String photoUrl;
  final String bio;
  final bool isPrivate;
  final bool showFavoritesPublicly;
  final DateTime createdAt;

  // Backward-compatible aliases used in other parts of the app.
  String get name => username;
  String get profileImage => photoUrl;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.photoUrl,
    this.bio = '',
    this.isPrivate = false,
    this.showFavoritesPublicly = true,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      username: (data['username'] ?? data['name'] ?? '').toString(),
      email: data['email'] ?? '',
      photoUrl: (data['photoUrl'] ?? data['profileImage'] ?? '').toString(),
      bio: (data['bio'] ?? '').toString(),
      isPrivate: (data['isPrivate'] as bool?) ?? false,
      showFavoritesPublicly: (data['showFavoritesPublicly'] as bool?) ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'name': username,
      'email': email,
      'photoUrl': photoUrl,
      'profileImage': photoUrl,
      'bio': bio,
      'isPrivate': isPrivate,
      'showFavoritesPublicly': showFavoritesPublicly,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? username,
    String? name,
    String? email,
    String? photoUrl,
    String? profileImage,
    String? bio,
    bool? isPrivate,
    bool? showFavoritesPublicly,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid,
      username: username ?? name ?? this.username,
      email: email ?? this.email,
      photoUrl: photoUrl ?? profileImage ?? this.photoUrl,
      bio: bio ?? this.bio,
      isPrivate: isPrivate ?? this.isPrivate,
      showFavoritesPublicly:
          showFavoritesPublicly ?? this.showFavoritesPublicly,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
