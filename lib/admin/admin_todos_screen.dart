import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
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
  bool _shared = false;

  /// ✅ Thêm Todo (đã fix lỗi "Bad state: No element")
  Future<void> _addTodo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (_titleController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠️ Vui lòng nhập tiêu đề")),
        );
        return;
      }

      await FirebaseFirestore.instance.collection("todos").add({
        "title": _titleController.text.trim(),
        "description": _descController.text.trim(),
        "priority": _priority,
        "deadline": _deadline,
        "isCompleted": false,
        "createdAt": FieldValue.serverTimestamp(),
        "userId": user?.uid,
        "shared": _shared,
      });

      _clearFields();

      if (!mounted) return;

      // ✅ Chỉ pop khi đang trong dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Đã thêm Todo mới")));
    } catch (e, s) {
      print("❌ Add error: $e\n$s");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi khi thêm Todo: $e")));
      }
    }
  }

  /// ✅ Cập nhật Todo
  Future<void> _editTodo(String id, Map<String, dynamic> data) async {
    _titleController.text = data["title"] ?? "";
    _descController.text = data["description"] ?? "";
    _priority = data["priority"] ?? "Medium";
    _deadline = (data["deadline"] as Timestamp?)?.toDate();
    _shared = data["shared"] ?? false;

    _showPastelDialog(
      title: "Sửa Todo",
      confirmText: "Lưu",
      onConfirm: () async {
        await FirebaseFirestore.instance.collection("todos").doc(id).update({
          "title": _titleController.text.trim(),
          "description": _descController.text.trim(),
          "priority": _priority,
          "deadline": _deadline,
          "shared": _shared,
        });
        _clearFields();
        if (mounted) Navigator.pop(context);
      },
    );
  }

  /// ✅ Dialog thêm/sửa Todo
  void _showPastelDialog({
    required String title,
    required String confirmText,
    required VoidCallback onConfirm,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.blueGrey.shade900 : Colors.teal.shade50;
    final accent = isDark ? Colors.tealAccent.shade200 : Colors.teal;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: TextStyle(color: accent)),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(_titleController, "Tiêu đề"),
              const SizedBox(height: 8),
              _buildTextField(_descController, "Mô tả", maxLines: 2),
              const SizedBox(height: 8),
              _buildPriorityDropdown(),
              const SizedBox(height: 8),
              _buildDeadlinePicker(),
              const Divider(),
              SwitchListTile(
                title: const Text(
                  "Chia sẻ với người dùng",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                value: _shared,
                activeColor: accent,
                onChanged: (val) => setState(() => _shared = val),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearFields();
              Navigator.pop(context);
            },
            child: const Text("HỦY"),
          ),
          ValidateBtn(title: confirmText, color: accent, ontap: onConfirm),
        ],
      ),
    );
  }

  void _openAddDialog() => _showPastelDialog(
    title: "Tạo Todo mới",
    confirmText: "Thêm",
    onConfirm: _addTodo,
  );

  Future<void> _deleteTodo(String id, String title) async {
    await FirebaseFirestore.instance.collection("todos").doc(id).delete();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("🗑️ Đã xóa Todo: $title")));
    }
  }

  Future<void> _toggleComplete(String id, bool current) async {
    await FirebaseFirestore.instance.collection("todos").doc(id).update({
      "isCompleted": !current,
    });
  }

  Future<void> _toggleShare(String id, bool currentShared) async {
    await FirebaseFirestore.instance.collection("todos").doc(id).update({
      "shared": !currentShared,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          !currentShared
              ? "📢 Đã chia sẻ Todo với người dùng!"
              : "🔒 Đã ngừng chia sẻ Todo",
        ),
      ),
    );
  }

  void _clearFields() {
    _titleController.clear();
    _descController.clear();
    _priority = "Medium";
    _deadline = null;
    _shared = false;
  }

  Widget _buildTextField(
    TextEditingController c,
    String label, {
    int maxLines = 1,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: c,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: isDark ? Colors.grey.shade800 : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildPriorityDropdown() {
    const priorities = ["High", "Medium", "Low"];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DropdownButtonFormField<String>(
      value: _priority,
      items: priorities
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (val) => setState(() => _priority = val!),
      dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
      decoration: InputDecoration(
        labelText: "Mức ưu tiên",
        filled: true,
        fillColor: isDark ? Colors.grey.shade800 : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDeadlinePicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.tealAccent : Colors.teal;
    return Row(
      children: [
        Expanded(
          child: Text(
            _deadline == null
                ? "⏰ Chưa có deadline"
                : "Deadline: ${DateFormat('dd/MM/yyyy').format(_deadline!)}",
          ),
        ),
        IconButton(
          icon: Icon(Icons.date_range, color: iconColor),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _deadline ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            );
            if (picked != null) setState(() => _deadline = picked);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.tealAccent : Colors.teal;
    final cardColor = isDark ? Colors.blueGrey.shade900 : Colors.teal.shade50;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Todos"),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: _openAddDialog,
        child: const Icon(Icons.add, size: 30, color: Colors.white),
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
              final shared = data["shared"] ?? false;
              final deadline = (data["deadline"] as Timestamp?)?.toDate();

              Color priorityColor = Colors.grey;
              if (priority == "High") priorityColor = Colors.red;
              if (priority == "Medium") priorityColor = Colors.orange;
              if (priority == "Low") priorityColor = Colors.green;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: shared ? 5 : 2,
                color: shared ? Colors.teal.shade50 : cardColor,
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
                      color: isCompleted
                          ? Colors.grey
                          : (isDark ? Colors.white : Colors.black),
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
                      if (shared)
                        Text(
                          "📢 Đang chia sẻ với người dùng",
                          style: TextStyle(
                            color: Colors.teal.shade700,
                            fontWeight: FontWeight.w600,
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
                          color: primaryColor,
                        ),
                        onPressed: () => _toggleComplete(doc.id, isCompleted),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editTodo(doc.id, data),
                      ),
                      IconButton(
                        icon: Icon(
                          shared
                              ? Icons.public_off_rounded
                              : Icons.public_rounded,
                          color: shared ? Colors.orange : Colors.teal,
                        ),
                        tooltip: shared
                            ? "Bỏ chia sẻ"
                            : "Chia sẻ với người dùng",
                        onPressed: () => _toggleShare(doc.id, shared),
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
