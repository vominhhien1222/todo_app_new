import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAnnouncementsScreen extends StatefulWidget {
  const AdminAnnouncementsScreen({super.key});

  @override
  State<AdminAnnouncementsScreen> createState() =>
      _AdminAnnouncementsScreenState();
}

class _AdminAnnouncementsScreenState extends State<AdminAnnouncementsScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  /// 🔹 Thêm thông báo
  Future<void> _addAnnouncement() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Vui lòng nhập đủ tiêu đề và nội dung"),
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection("announcements").add({
        "title": title,
        "content": content,
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Thêm thông báo thành công")),
        );
      }

      _titleController.clear();
      _contentController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Lỗi khi thêm: $e")));
      }
    }
  }

  /// 🔹 Dialog thêm thông báo
  void _openAddDialog() {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          "Thêm thông báo",
          style: TextStyle(color: colorScheme.onSurface),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Tiêu đề"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Nội dung"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            onPressed: _addAnnouncement,
            child: const Text("Thêm"),
          ),
        ],
      ),
    );
  }

  /// 🔹 Xóa thông báo
  Future<void> _deleteAnnouncement(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection("announcements")
          .doc(id)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("🗑️ Đã xóa thông báo")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Lỗi khi xóa: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý thông báo"),
        backgroundColor: colorScheme.primary, // ✅ đồng bộ màu theme
        foregroundColor: colorScheme.onPrimary, // ✅ chữ trắng/dark tự động
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary, // ✅ đồng bộ theme
        onPressed: _openAddDialog,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("announcements")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("⚠️ Lỗi: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("📭 Chưa có thông báo nào"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final title = data["title"] ?? "Không có tiêu đề";
              final content = data["content"] ?? "";
              final createdAt = (data["createdAt"] as Timestamp?)?.toDate();

              return Card(
                color: colorScheme.surface, // ✅ đồng bộ màu nền card
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        content,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      if (createdAt != null)
                        Text(
                          "📅 ${createdAt.day}/${createdAt.month}/${createdAt.year}",
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: colorScheme.error),
                    onPressed: () => _deleteAnnouncement(doc.id),
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
