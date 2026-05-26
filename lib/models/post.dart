import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String recipeId;
  final String username;
  final String imageUrl;
  final String description;
  final String category;
  final Timestamp? timestamp;
  final int likesCount;

  Post({
    required this.id,
    required this.userId,
    this.recipeId = '',
    required this.username,
    required this.imageUrl,
    required this.description,
    this.category = '',
    this.timestamp,
    this.likesCount = 0,
  });

  factory Post.fromFirestore(String id, Map<String, dynamic> data) {
    return Post(
      id: id,
      userId: data['userId'] ?? '',
      recipeId: data['recipeId'] ?? '',
      username: data['username'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      timestamp: data['timestamp'] as Timestamp?,
      category: (data['category'] as String?) ?? '',
      likesCount: (data['likesCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'recipeId': recipeId,
      'username': username,
      'imageUrl': imageUrl,
      'description': description,
      'category': category,
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),
      'likesCount': likesCount,
    };
  }

  Post copyWith({
    String? id,
    String? userId,
    String? recipeId,
    String? username,
    String? imageUrl,
    String? description,
    String? category,
    Timestamp? timestamp,
    int? likesCount,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      recipeId: recipeId ?? this.recipeId,
      username: username ?? this.username,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      likesCount: likesCount ?? this.likesCount,
    );
  }
}

class Comment {
  final String id;
  final String userId;
  final String username;
  final String commentText;
  final Timestamp? timestamp;

  Comment({
    required this.id,
    required this.userId,
    required this.username,
    required this.commentText,
    this.timestamp,
  });

  factory Comment.fromFirestore(String id, Map<String, dynamic> data) {
    return Comment(
      id: id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      commentText: data['commentText'] ?? '',
      timestamp: data['timestamp'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'username': username,
      'commentText': commentText,
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),
    };
  }
}
