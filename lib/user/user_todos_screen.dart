import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';
import 'user_detail_screen.dart';
import 'user_profile_screen.dart';
import 'user_announcements_screen.dart';

class UserTodosScreen extends StatefulWidget {
  const UserTodosScreen({super.key});

  @override
  State<UserTodosScreen> createState() => _UserTodosScreenState();
}

class _UserTodosScreenState extends State<UserTodosScreen> {
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
        title: const Text("Danh Sách Công Việc"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 240, 96, 185),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: "Thông báo",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UserAnnouncementsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: "Hồ Sơ Cá Nhân",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserProfileScreen()),
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
              decoration: InputDecoration(
                hintText: "Tìm kiếm công việc đi em...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
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
                      elevation: todo.shared ? 4 : 2,
                      color: todo.shared ? Colors.teal.shade50 : Colors.white,
                      child: ListTile(
                        leading: Icon(
                          todo.shared ? Icons.campaign_rounded : Icons.task_alt,
                          color: todo.shared ? Colors.teal : Colors.pink,
                        ),
                        title: Text(
                          todo.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: todo.shared
                                ? Colors.teal.shade800
                                : Colors.black87,
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
                            if (todo.deadline != null)
                              Text(
                                "Hạn: ${DateFormat('dd/MM/yyyy').format(todo.deadline!)}",
                                style: TextStyle(
                                  color: todo.deadline!.isBefore(DateTime.now())
                                      ? Colors.red
                                      : Colors.grey.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            Text(
                              "Ưu tiên: ${todo.priority}",
                              style: TextStyle(
                                color: priorityColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (todo.shared)
                              const Padding(
                                padding: EdgeInsets.only(top: 4.0),
                                child: Text(
                                  "📢 Được chia sẻ bởi Admin",
                                  style: TextStyle(
                                    color: Colors.teal,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        trailing:
                            (todo.userId ==
                                FirebaseAuth.instance.currentUser?.uid)
                            ? Icon(
                                todo.isCompleted
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: Colors.teal,
                              )
                            : const Text(
                                "👁️ Chia sẻ",
                                style: TextStyle(
                                  color: Colors.teal,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserDetailScreen(todo: todo),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
