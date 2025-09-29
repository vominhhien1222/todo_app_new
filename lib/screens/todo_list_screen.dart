import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';
import 'add_todo_screen.dart';
import 'profile_screen.dart';
import 'package:intl/intl.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  String selectedCategory = "Tất cả";
  String searchKeyword = "";

  final categories = [
    "Tất cả",
    "Công việc",
    "Học tập",
    "Cá nhân",
    "Mua sắm",
    "Khác",
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TodoProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách công việc"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔽 Dropdown chọn category
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedCategory,
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedCategory = val!;
                });
              },
            ),
          ),

          // 🔍 Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Tìm kiếm công việc...",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchKeyword = value.trim();
                });
              },
            ),
          ),

          const SizedBox(height: 8),

          // 📋 Danh sách công việc
          Expanded(
            child: StreamBuilder<List<Todo>>(
              stream: provider.getTodosByCategory(selectedCategory),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Không có công việc nào"));
                }

                // ✅ Lọc kết quả theo searchKeyword
                final filteredTodos = snapshot.data!.where((todo) {
                  final lower = searchKeyword.toLowerCase();
                  return todo.title.toLowerCase().contains(lower) ||
                      todo.description.toLowerCase().contains(lower);
                }).toList();

                if (filteredTodos.isEmpty) {
                  return const Center(child: Text("Không tìm thấy kết quả"));
                }

                return ListView.builder(
                  itemCount: filteredTodos.length,
                  itemBuilder: (context, index) {
                    final todo = filteredTodos[index];
                    final isOverdue =
                        todo.deadline != null &&
                        todo.deadline!.isBefore(DateTime.now());

                    Color priorityColor;
                    switch (todo.priority) {
                      case 'High':
                        priorityColor = Colors.red;
                        break;
                      case 'Medium':
                        priorityColor = Colors.orange;
                        break;
                      case 'Low':
                        priorityColor = Colors.green;
                        break;
                      default:
                        priorityColor = Colors.grey;
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.task_alt, color: Colors.teal),
                        title: Text(
                          todo.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (todo.category.isNotEmpty)
                              Text(
                                "Danh mục: ${todo.category}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.teal,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            if (todo.description.isNotEmpty)
                              Text(todo.description),

                            // 🕒 Deadline
                            if (todo.deadline != null)
                              Text(
                                "Hạn: ${DateFormat('dd/MM/yyyy').format(todo.deadline!)}",
                                style: TextStyle(
                                  color: isOverdue
                                      ? Colors.red
                                      : Colors.grey.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                            // 🔺 Priority
                            Text(
                              "Ưu tiên: ${todo.priority}",
                              style: TextStyle(
                                color: priorityColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                todo.isCompleted
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: Colors.teal,
                              ),
                              onPressed: () {
                                provider.toggleTodoStatus(
                                  todo.id,
                                  todo.isCompleted,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                provider.deleteTodo(todo.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTodoScreen()),
          );
        },
      ),
    );
  }
}
