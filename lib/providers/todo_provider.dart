import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo.dart';

class TodoProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  Stream<List<Todo>> getTodos() {
    return _firestore
        .collection('todos')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Todo.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Stream<List<Todo>> getTodosByCategory(String category) {
    if (category == "Tất cả") return getTodos();
    return _firestore
        .collection('todos')
        .where("category", isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Todo.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Future<void> addTodo(
    String title,
    String description,
    String category,
    DateTime? deadline,
    String priority,
  ) async {
    await _firestore.collection('todos').add({
      'title': title,
      'description': description,
      'category': category,
      'isCompleted': false,
      'imageUrl': '',
      'createdAt': FieldValue.serverTimestamp(),
      'deadline': deadline,
      'priority': priority,
    });
  }

  Future<void> toggleTodoStatus(String id, bool currentStatus) async {
    await _firestore.collection('todos').doc(id).update({
      'isCompleted': !currentStatus,
    });
  }

  Future<void> deleteTodo(String id) async {
    await _firestore.collection('todos').doc(id).delete();
  }

  Future<void> updateTodo(Todo todo) async {
    await _firestore.collection('todos').doc(todo.id).update({
      'title': todo.title,
      'description': todo.description,
      'category': todo.category,
      'isCompleted': todo.isCompleted,
      if (todo.imageUrl != null) 'imageUrl': todo.imageUrl,
    });
  }
}
