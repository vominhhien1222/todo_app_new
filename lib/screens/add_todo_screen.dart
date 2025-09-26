import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import 'package:intl/intl.dart';

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = "Công việc";
  String _selectedPriority = "Medium";
  DateTime? _selectedDeadline;

  final List<String> categories = [
    "Công việc",
    "Học tập",
    "Cá nhân",
    "Mua sắm",
    "Khác",
  ];

  final List<String> priorities = ["Low", "Medium", "High"];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TodoProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Thêm công việc")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Tiêu đề"),
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: "Mô tả"),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) {
                setState(() => _selectedCategory = val!);
              },
              decoration: const InputDecoration(labelText: "Danh mục"),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              items: priorities
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (val) {
                setState(() => _selectedPriority = val!);
              },
              decoration: const InputDecoration(labelText: "Ưu tiên"),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _selectedDeadline == null
                    ? "Chọn hạn chót"
                    : "Hạn: ${DateFormat('dd/MM/yyyy').format(_selectedDeadline!)}",
              ),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => _selectedDeadline = picked);
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isNotEmpty) {
                  await provider.addTodo(
                    _titleController.text,
                    _descController.text,
                    _selectedCategory,
                    _selectedDeadline,
                    _selectedPriority,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text("Thêm"),
            ),
          ],
        ),
      ),
    );
  }
}
