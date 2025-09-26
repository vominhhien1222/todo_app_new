import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';

class TodoEditScreen extends StatefulWidget {
  final Todo todo;
  const TodoEditScreen({super.key, required this.todo});

  @override
  State<TodoEditScreen> createState() => _TodoEditScreenState();
}

class _TodoEditScreenState extends State<TodoEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late String _selectedCategory;
  late String _selectedPriority;
  DateTime? _selectedDeadline;
  late bool _isCompleted;

  final List<String> categories = [
    "Công việc",
    "Học tập",
    "Cá nhân",
    "Mua sắm",
    "Khác",
  ];

  final List<String> priorities = ["Low", "Medium", "High"];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _descController = TextEditingController(text: widget.todo.description);
    _selectedCategory = widget.todo.category;
    _selectedPriority = widget.todo.priority;
    _selectedDeadline = widget.todo.deadline;
    _isCompleted = widget.todo.isCompleted;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TodoProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Chỉnh sửa công việc")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Tiêu đề"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descController,
                decoration: const InputDecoration(labelText: "Mô tả"),
              ),
              const SizedBox(height: 12),
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
                    initialDate: _selectedDeadline ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => _selectedDeadline = picked);
                  }
                },
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                title: const Text("Hoàn thành"),
                value: _isCompleted,
                onChanged: (val) {
                  setState(() => _isCompleted = val ?? false);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final updated = Todo(
                    id: widget.todo.id,
                    title: _titleController.text,
                    description: _descController.text,
                    isCompleted: _isCompleted,
                    imageUrl: widget.todo.imageUrl,
                    category: _selectedCategory,
                    createdAt: widget.todo.createdAt,
                    priority: _selectedPriority,
                    deadline: _selectedDeadline,
                  );
                  await provider.updateTodo(updated);
                  Navigator.pop(context);
                },
                child: const Text("Lưu thay đổi"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
