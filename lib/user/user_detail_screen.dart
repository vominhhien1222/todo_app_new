import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';

class UserDetailScreen extends StatelessWidget {
  final Todo todo;

  const UserDetailScreen({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    final createdAt = DateFormat('dd/MM/yyyy HH:mm').format(todo.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết công việc"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  todo.imageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
              ),

            const SizedBox(height: 16),

            Text(
              todo.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              "Danh mục: ${todo.category}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.teal,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              todo.description.isNotEmpty ? todo.description : "Không có mô tả",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Text(
                  "Trạng thái: ",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  todo.isCompleted ? "✅ Hoàn thành" : "⏳ Chưa hoàn thành",
                  style: TextStyle(
                    fontSize: 16,
                    color: todo.isCompleted ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              "Ngày tạo: $createdAt",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
