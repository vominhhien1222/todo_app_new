import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminTodosScreen extends StatefulWidget {
  const AdminTodosScreen({super.key});

  @override
  State<AdminTodosScreen> createState() => _AdminTodosScreenState();
}

class _AdminTodosScreenState extends State<AdminTodosScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  Future<void> _addTodo() async {
    await FirebaseFirestore.instance.collection("todos").add({
      "title": _titleController.text,
      "description": _descController.text,
      "createdAt": FieldValue.serverTimestamp(),
    });
    _titleController.clear();
    _descController.clear();
    Navigator.pop(context);
  }

  Future<void> _editTodo(String id, Map<String, dynamic> data) async {
    _titleController.text = data["title"] ?? "";
    _descController.text = data["description"] ?? "";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Sửa Todo"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Tiêu đề"),
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: "Mô tả"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection("todos")
                  .doc(id)
                  .update({
                    "title": _titleController.text,
                    "description": _descController.text,
                  });
              Navigator.pop(context);
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  void _openAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Thêm Todo"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Tiêu đề"),
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: "Mô tả"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(onPressed: _addTodo, child: const Text("Thêm")),
        ],
      ),
    );
  }

  Future<void> _deleteTodo(String id, String title) async {
    await FirebaseFirestore.instance.collection("todos").doc(id).delete();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Đã xóa todo: $title")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Todos"),
        backgroundColor: Colors.red.shade700,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red.shade700,
        onPressed: _openAddDialog,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("todos")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final todos = snapshot.data!.docs;

          if (todos.isEmpty)
            return const Center(child: Text("Chưa có todo nào"));

          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final doc = todos[index];
              final data = doc.data() as Map<String, dynamic>;
              final title = data["title"] ?? "";

              return Card(
                child: ListTile(
                  title: Text(title),
                  subtitle: Text(data["description"] ?? ""),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editTodo(doc.id, data),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTodo(doc.id, title),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
