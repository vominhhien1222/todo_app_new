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

  /// ✅ Thêm Todo (có bắt lỗi)
  Future<void> _addTodo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      print("📡 Current user: ${user?.uid}");

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
      });

      print("✅ Add success");

      _clearFields();
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("✅ Đã thêm Todo mới")));
      }
    } catch (e, s) {
      print("❌ Add error: $e\n$s");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi khi thêm Todo: $e")));
    }
  }

  /// ✅ Cập nhật Todo
  Future<void> _editTodo(String id, Map<String, dynamic> data) async {
    _titleController.text = data["title"] ?? "";
    _descController.text = data["description"] ?? "";
    _priority = data["priority"] ?? "Medium";
    _deadline = (data["deadline"] as Timestamp?)?.toDate();

    _showPastelDialog(
      title: "Sửa Todo",
      confirmText: "Lưu",
      onConfirm: () async {
        await FirebaseFirestore.instance.collection("todos").doc(id).update({
          "title": _titleController.text.trim(),
          "description": _descController.text.trim(),
          "priority": _priority,
          "deadline": _deadline,
        });
        _clearFields();
        if (mounted) Navigator.pop(context);
      },
    );
  }

  /// ✅ Dialog thêm/sửa (có scroll fix overflow)
  void _showPastelDialog({
    required String title,
    required String confirmText,
    required VoidCallback onConfirm,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.blueGrey.shade900 : Colors.teal.shade50;
    final accent = isDark ? Colors.tealAccent.shade200 : Colors.teal;

    showGeneralDialog(
      context: context,
      barrierLabel: "TodoDialog",
      barrierDismissible: true,
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (_, __, ___) => const SizedBox(),
      transitionBuilder: (_, anim, __, ___) {
        final curved = Curves.elasticOut.transform(anim.value);
        return Opacity(
          opacity: anim.value,
          child: Transform.scale(
            scale: 0.9 + curved * 0.1,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  constraints: const BoxConstraints(
                    maxWidth: 420,
                    maxHeight: 420,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(0.4),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    // ✅ Fix tràn layout
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (title.isNotEmpty) ...[
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: accent,
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        Card(
                          color: isDark ? Colors.grey.shade900 : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Wrap(
                              runSpacing: 10,
                              children: [
                                _buildTextField(_titleController, "Tiêu đề"),
                                _buildTextField(
                                  _descController,
                                  "Mô tả",
                                  maxLines: 2,
                                ),
                                _buildPriorityDropdown(),
                                _buildDeadlinePicker(),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                _clearFields();
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "HỦY",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ValidateBtn(
                              title: confirmText,
                              color: accent,
                              ontap: onConfirm,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// ✅ Mở dialog thêm Todo
  void _openAddDialog() => _showPastelDialog(
    title: "Tạo Todo mới",
    confirmText: "Thêm",
    onConfirm: _addTodo,
  );

  /// ✅ Xóa Todo
  Future<void> _deleteTodo(String id, String title) async {
    await FirebaseFirestore.instance.collection("todos").doc(id).delete();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("🗑️ Đã xóa Todo: $title")));
    }
  }

  /// ✅ Toggle hoàn thành
  Future<void> _toggleComplete(String id, bool current) async {
    await FirebaseFirestore.instance.collection("todos").doc(id).update({
      "isCompleted": !current,
    });
  }

  void _clearFields() {
    _titleController.clear();
    _descController.clear();
    _priority = "Medium";
    _deadline = null;
  }

  /// 🧱 Widget Input
  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? Colors.tealAccent.shade100
        : Colors.teal.shade200;
    final focusColor = isDark ? Colors.tealAccent : Colors.teal;

    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: isDark ? Colors.grey.shade800 : Colors.white,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: focusColor, width: 1.5),
        ),
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
        isDense: true,
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

  /// 🧩 UI chính
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
        elevation: 2,
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
              final deadline = (data["deadline"] as Timestamp?)?.toDate();

              Color priorityColor = Colors.grey;
              if (priority == "High") priorityColor = Colors.red;
              if (priority == "Medium") priorityColor = Colors.orange;
              if (priority == "Low") priorityColor = Colors.green;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 3,
                color: cardColor,
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
