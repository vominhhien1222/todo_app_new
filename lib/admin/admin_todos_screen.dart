import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// import component widgets
import '../components/custom_btn.dart';
import '../components/validate_btn.dart';

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

  /// 🔹 Thêm Todo mới
  Future<void> _addTodo() async {
    final user = FirebaseAuth.instance.currentUser;

    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("⚠️ Vui lòng nhập tiêu đề")));
      return;
    }

    await FirebaseFirestore.instance.collection("todos").add({
      "title": _titleController.text,
      "description": _descController.text,
      "priority": _priority,
      "deadline": _deadline,
      "isCompleted": false,
      "createdAt": FieldValue.serverTimestamp(),
      "userId": user?.uid, // ✅ fix permission
    });

    _titleController.clear();
    _descController.clear();
    _priority = "Medium";
    _deadline = null;

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Đã thêm Todo mới")));
    }
  }

  /// 🔹 Mở dialog sửa Todo
  Future<void> _editTodo(String id, Map<String, dynamic> data) async {
    _titleController.text = data["title"] ?? "";
    _descController.text = data["description"] ?? "";
    _priority = data["priority"] ?? "Medium";
    _deadline = (data["deadline"] as Timestamp?)?.toDate();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("✏️ Sửa Todo"),
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
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _deadline == null
                          ? "⏰ Chưa có deadline"
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
          ValidateBtn(
            title: "Lưu thay đổi",
            color: Colors.orange,
            ontap: () async {
              await FirebaseFirestore.instance
                  .collection("todos")
                  .doc(id)
                  .update({
                    "title": _titleController.text,
                    "description": _descController.text,
                    "priority": _priority,
                    "deadline": _deadline,
                  });
              if (mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  /// 🔹 Mở dialog thêm Todo
  void _openAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("➕ Thêm Todo"),
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
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _deadline == null
                          ? "⏰ Chưa có deadline"
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
          ValidateBtn(title: "Thêm", color: Colors.orange, ontap: _addTodo),
        ],
      ),
    );
  }

  /// 🔹 Xóa Todo
  Future<void> _deleteTodo(String id, String title) async {
    await FirebaseFirestore.instance.collection("todos").doc(id).delete();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("🗑️ Đã xóa Todo: $title")));
    }
  }

  /// 🔹 Toggle trạng thái hoàn thành
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
      floatingActionButton: CustomBtn(
        title: "Thêm Todo",
        icon: const Icon(Icons.add, color: Colors.white),
        color: Colors.deepOrange,
        ontap: _openAddDialog,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("todos")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("📭 Chưa có Todo nào"));
          }

          final todos = snapshot.data!.docs;

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
