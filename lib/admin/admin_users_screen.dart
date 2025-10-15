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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  // ========================= CRUD =========================

  Future<void> _addUser() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final role = _roleController.text.trim().isEmpty
        ? "user"
        : _roleController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email không được để trống")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection("users").add({
      "name": name,
      "email": email,
      "role": role,
      "status": "active",
      "createdAt": FieldValue.serverTimestamp(),
    });

    _nameController.clear();
    _emailController.clear();
    _roleController.clear();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _editUser(String id, Map<String, dynamic> data) async {
    _nameController.text = (data["name"] ?? "").toString();
    _emailController.text = (data["email"] ?? "").toString();
    _roleController.text = (data["role"] ?? "user").toString();

    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text("Sửa User", style: TextStyle(color: colorScheme.onSurface)),
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
                labelText: "Role (user/admin/super_admin)",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            onPressed: () async {
              final name = _nameController.text.trim();
              final email = _emailController.text.trim();
              final role = _roleController.text.trim().isEmpty
                  ? "user"
                  : _roleController.text.trim();

              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(id)
                  .update({"name": name, "email": email, "role": role});
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(String id, String email) async {
    final colorScheme = Theme.of(context).colorScheme;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          "Xóa user?",
          style: TextStyle(color: colorScheme.onSurface),
        ),
        content: Text(
          "Bạn có chắc muốn xóa user: $email ?",
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Xóa"),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await FirebaseFirestore.instance.collection("users").doc(id).delete();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Đã xóa user: $email")));
    }
  }

  Future<void> _toggleLockUser({
    required String id,
    required bool currentlyLocked,
    required String email,
  }) async {
    final newStatus = currentlyLocked ? 'active' : 'locked';
    await FirebaseFirestore.instance.collection("users").doc(id).update({
      "status": newStatus,
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(currentlyLocked ? "Đã mở khóa $email" : "Đã khóa $email"),
      ),
    );
  }

  void _openAddDialog() {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          "Thêm User",
          style: TextStyle(color: colorScheme.onSurface),
        ),
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            onPressed: _addUser,
            child: const Text("Thêm"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Users"),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        onPressed: _openAddDialog,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
              final data = doc.data();

              final name = (data["name"] ?? "").toString();
              final email = (data["email"] ?? "Không có email").toString();
              final role = (data["role"] ?? "user").toString();
              final status = (data["status"] ?? "active").toString();
              final locked = status == 'locked';
              final isProtectedAdmin = role == 'admin' || role == 'super_admin';

              return Card(
                color: colorScheme.surface,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primary.withOpacity(0.15),
                    child: Text(
                      (name.isNotEmpty ? name[0] : email[0]).toUpperCase(),
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    email,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  subtitle: Text(
                    "Tên: ${name.isEmpty ? '(Không tên)' : name} • Role: $role • Trạng thái: $status",
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isProtectedAdmin)
                        IconButton(
                          tooltip: locked ? 'Mở khóa' : 'Khóa',
                          icon: Icon(
                            locked ? Icons.lock_open : Icons.lock,
                            color: locked ? Colors.green : Colors.orangeAccent,
                          ),
                          onPressed: () => _toggleLockUser(
                            id: doc.id,
                            currentlyLocked: locked,
                            email: email,
                          ),
                        ),
                      IconButton(
                        tooltip: 'Sửa',
                        icon: Icon(Icons.edit, color: colorScheme.secondary),
                        onPressed: () => _editUser(doc.id, data),
                      ),
                      IconButton(
                        tooltip: 'Xóa',
                        icon: Icon(Icons.delete, color: colorScheme.error),
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
