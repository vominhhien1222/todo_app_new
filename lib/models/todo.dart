import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final String? imageUrl;
  final String category;
  final DateTime createdAt;

  final DateTime? deadline; // 🆕
  final String priority; // 🆕

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    this.imageUrl,
    required this.category,
    required this.createdAt,
    this.deadline,
    required this.priority,
  });

  factory Todo.fromMap(Map<String, dynamic> data, String id) {
    return Todo(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      imageUrl: data['imageUrl'],
      category: data['category'] ?? 'Khác',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      deadline: data['deadline'] != null
          ? (data['deadline'] as Timestamp).toDate()
          : null,
      priority: data['priority'] ?? 'Medium',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'imageUrl': imageUrl,
      'category': category,
      'createdAt': createdAt,
      'deadline': deadline,
      'priority': priority,
    };
  }
}
