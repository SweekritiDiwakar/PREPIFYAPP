import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.imageUrl,
    required this.createdBy,
    this.createdAt,
    required this.likes,
    required this.tags,
  });

  final String id;
  final String title;
  final String description;
  final List<String> ingredients;
  final List<String> steps;
  final String imageUrl;
  final String createdBy;
  final Timestamp? createdAt;
  final int likes;
  final List<String> tags;

  factory Recipe.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return Recipe(
      id: id,
      title: (data['title'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      ingredients: ((data['ingredients'] as List<dynamic>?) ?? [])
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList(),
      steps: ((data['steps'] as List<dynamic>?) ?? [])
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList(),
      imageUrl: (data['imageUrl'] as String?) ?? '',
      createdBy: (data['createdBy'] as String?) ?? '',
      createdAt: data['createdAt'] as Timestamp?,
      likes: (data['likes'] as int?) ?? 0,
      tags: ((data['tags'] as List<dynamic>?) ?? [])
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'steps': steps,
      'imageUrl': imageUrl,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'likes': likes,
      'tags': tags,
    };
  }

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? ingredients,
    List<String>? steps,
    String? imageUrl,
    String? createdBy,
    Timestamp? createdAt,
    int? likes,
    List<String>? tags,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      imageUrl: imageUrl ?? this.imageUrl,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      tags: tags ?? this.tags,
    );
  }
}
