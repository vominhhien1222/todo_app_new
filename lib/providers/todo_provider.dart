import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/todo.dart';

class TodoProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// 🔹 Lấy tất cả todos của user hiện tại
  Stream<List<Todo>> getTodos() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('todos')
        .where(
          Filter.or(
            Filter('userId', isEqualTo: user.uid),
            Filter('shared', isEqualTo: true),
          ),
        )
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) =>
                    Todo.fromMap(Map<String, dynamic>.from(doc.data()), doc.id),
              )
              .toList();
        });
  }

  /// 🔹 Lấy todos theo category (của user hiện tại)
  Stream<List<Todo>> getTodosByCategory(String category) {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    Query query = _firestore
        .collection('todos')
        .orderBy('createdAt', descending: true);

    if (category != "Tất cả") {
      query = query.where("category", isEqualTo: category);
    }

    // ✅ Lọc theo userId hoặc shared = true
    query = query.where(
      Filter.or(
        Filter('userId', isEqualTo: user.uid),
        Filter('shared', isEqualTo: true),
      ),
    );

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => Todo.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    });
  }

  /// 🔹 Thêm todo mới
  Future<void> addTodo(
    String title,
    String description,
    String category,
    DateTime? deadline,
    String priority,
  ) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Chưa đăng nhập");

    await _firestore.collection('todos').add({
      'title': title,
      'description': description,
      'category': category,
      'isCompleted': false,
      'imageUrl': '',
      'createdAt': FieldValue.serverTimestamp(), // đồng bộ server time
      'deadline': deadline,
      'priority': priority,
      'userId': user.uid, // bắt buộc cho Firestore Rules
    });
  }

  /// 🔹 Toggle complete
  Future<void> toggleTodoStatus(String id, bool currentStatus) async {
    await _firestore.collection('todos').doc(id).update({
      'isCompleted': !currentStatus,
    });
  }

  /// 🔹 Xóa todo
  Future<void> deleteTodo(String id) async {
    await _firestore.collection('todos').doc(id).delete();
  }

  /// 🔹 Cập nhật todo (giữ nguyên userId)
  Future<void> updateTodo(Todo todo) async {
    await _firestore.collection('todos').doc(todo.id).update({
      'title': todo.title,
      'description': todo.description,
      'category': todo.category,
      'isCompleted': todo.isCompleted,
      if (todo.imageUrl != null) 'imageUrl': todo.imageUrl,
      'deadline': todo.deadline,
      'priority': todo.priority,
      // không update userId
    });
  }
}
