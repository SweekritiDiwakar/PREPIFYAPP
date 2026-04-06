import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.category,
    required this.ingredients,
    required this.steps,
    required this.imageUrl,
    required this.createdBy,
    required this.householdId,
    this.createdAt,
    required this.likes,
  });

  final String id;
  final String title;
  final String category;
  final List<String> ingredients;
  final String steps;
  final String imageUrl;
  final String createdBy;
  final String householdId;
  final Timestamp? createdAt;
  final int likes;

  factory Recipe.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return Recipe(
      id: id,
      title: (data['title'] as String?) ?? '',
      category: (data['category'] as String?) ?? '',
      ingredients: ((data['ingredients'] as List<dynamic>?) ?? [])
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList(),
      steps: (data['steps'] as String?) ?? '',
      imageUrl: (data['imageUrl'] as String?) ?? '',
      createdBy: (data['createdBy'] as String?) ?? '',
      householdId: (data['householdId'] as String?) ?? '',
      createdAt: data['createdAt'] as Timestamp?,
      likes: (data['likes'] as int?) ?? 0,
    );
  }

  Recipe copyWith({
    String? id,
    String? title,
    String? category,
    List<String>? ingredients,
    String? steps,
    String? imageUrl,
    String? createdBy,
    String? householdId,
    Timestamp? createdAt,
    int? likes,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      imageUrl: imageUrl ?? this.imageUrl,
      createdBy: createdBy ?? this.createdBy,
      householdId: householdId ?? this.householdId,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
    );
  }
}
