import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminTodosScreen extends StatefulWidget {
  const AdminTodosScreen({super.key});

  @override
  State<AdminTodosScreen> createState() => _AdminTodosScreenState();
}

class _AdminTodosScreenState extends State<AdminTodosScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _priority = "Medium";
  DateTime? _deadline;

  Future<void> _addTodo() async {
    await FirebaseFirestore.instance.collection("todos").add({
      "title": _titleController.text,
      "description": _descController.text,
      "priority": _priority,
      "deadline": _deadline,
      "isCompleted": false,
      "createdAt": FieldValue.serverTimestamp(),
    });
    _titleController.clear();
    _descController.clear();
    _priority = "Medium";
    _deadline = null;
    Navigator.pop(context);
  }

  Future<void> _editTodo(String id, Map<String, dynamic> data) async {
    _titleController.text = data["title"] ?? "";
    _descController.text = data["description"] ?? "";
    _priority = data["priority"] ?? "Medium";
    _deadline = (data["deadline"] as Timestamp?)?.toDate();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Sửa Todo"),
        content: SingleChildScrollView(
          child: Column(
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
              DropdownButton<String>(
                value: _priority,
                items: ["High", "Medium", "Low"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => _priority = val!),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _deadline == null
                          ? "Chưa có deadline"
                          : "Deadline: ${DateFormat('dd/MM/yyyy').format(_deadline!)}",
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.date_range,
                      color: Colors.deepOrange,
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _deadline ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _deadline = picked);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection("todos")
                  .doc(id)
                  .update({
                    "title": _titleController.text,
                    "description": _descController.text,
                    "priority": _priority,
                    "deadline": _deadline,
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
        content: SingleChildScrollView(
          child: Column(
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
              DropdownButton<String>(
                value: _priority,
                items: ["High", "Medium", "Low"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => _priority = val!),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _deadline == null
                          ? "Chưa có deadline"
                          : "Deadline: ${DateFormat('dd/MM/yyyy').format(_deadline!)}",
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.date_range,
                      color: Colors.deepOrange,
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _deadline = picked);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: _addTodo,
            child: const Text("Thêm"),
          ),
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

  Future<void> _toggleComplete(String id, bool current) async {
    await FirebaseFirestore.instance.collection("todos").doc(id).update({
      "isCompleted": !current,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Todos"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.orange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
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
              final desc = data["description"] ?? "";
              final priority = data["priority"] ?? "Medium";
              final isCompleted = data["isCompleted"] ?? false;
              final deadline = (data["deadline"] as Timestamp?)?.toDate();

              Color priorityColor = Colors.grey;
              if (priority == "High") priorityColor = Colors.red;
              if (priority == "Medium") priorityColor = Colors.orange;
              if (priority == "Low") priorityColor = Colors.green;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: isCompleted ? Colors.grey : Colors.black,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (desc.isNotEmpty) Text(desc),
                      Text(
                        "Ưu tiên: $priority",
                        style: TextStyle(
                          color: priorityColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (deadline != null)
                        Text(
                          "Hạn: ${DateFormat('dd/MM/yyyy').format(deadline)}",
                          style: TextStyle(
                            color: deadline.isBefore(DateTime.now())
                                ? Colors.red.shade800
                                : Colors.grey[700],
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          isCompleted
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: Colors.teal,
                        ),
                        onPressed: () => _toggleComplete(doc.id, isCompleted),
                      ),
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
