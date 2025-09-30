import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _roleController = TextEditingController();

  /// Thêm User
  Future<void> _addUser() async {
    await FirebaseFirestore.instance.collection("users").add({
      "name": _nameController.text,
      "email": _emailController.text,
      "role": _roleController.text.isEmpty ? "user" : _roleController.text,
      "createdAt": FieldValue.serverTimestamp(),
    });

    _nameController.clear();
    _emailController.clear();
    _roleController.clear();
    Navigator.pop(context);
  }

  /// Sửa User
  Future<void> _editUser(String id, Map<String, dynamic> data) async {
    _nameController.text = data["name"] ?? "";
    _emailController.text = data["email"] ?? "";
    _roleController.text = data["role"] ?? "user";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Sửa User"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Tên"),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _roleController,
              decoration: const InputDecoration(labelText: "Role"),
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
                  .collection("users")
                  .doc(id)
                  .update({
                    "name": _nameController.text,
                    "email": _emailController.text,
                    "role": _roleController.text,
                  });
              Navigator.pop(context);
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  /// Dialog thêm User
  void _openAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Thêm User"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Tên"),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _roleController,
              decoration: const InputDecoration(
                labelText: "Role (mặc định user)",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(onPressed: _addUser, child: const Text("Thêm")),
        ],
      ),
    );
  }

  /// Xóa User
  Future<void> _deleteUser(String id, String email) async {
    await FirebaseFirestore.instance.collection("users").doc(id).delete();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Đã xóa user: $email")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Users"),
        backgroundColor: Colors.red.shade700,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red.shade700,
        onPressed: _openAddDialog,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Chưa có user nào"));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final doc = users[index];
              final data = doc.data() as Map<String, dynamic>;
              final email = data["email"] ?? "Không có email";
              final role = data["role"] ?? "user";

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.red),
                  title: Text(email),
                  subtitle: Text("Role: $role"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editUser(doc.id, data),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteUser(doc.id, email),
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
