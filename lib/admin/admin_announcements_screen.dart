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
    await FirebaseFirestore.instance.collection("announcements").add({
      "title": _titleController.text,
      "content": _contentController.text,
      "createdAt": FieldValue.serverTimestamp(),
    });
    _titleController.clear();
    _contentController.clear();
    Navigator.pop(context);
  }

  /// 🔹 Dialog thêm thông báo
  void _openAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Thêm thông báo"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Tiêu đề"),
            ),
            TextField(
              controller: _contentController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Nội dung"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: _addAnnouncement,
            child: const Text("Thêm"),
          ),
        ],
      ),
    );
  }

  /// 🔹 Xóa thông báo
  Future<void> _deleteAnnouncement(String id) async {
    await FirebaseFirestore.instance
        .collection("announcements")
        .doc(id)
        .delete();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Đã xóa thông báo")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý thông báo"),
        backgroundColor: Colors.red.shade700,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red.shade700,
        onPressed: _openAddDialog,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("announcements")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Chưa có thông báo nào"));
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
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(content),
                      if (createdAt != null)
                        Text(
                          "Ngày: ${createdAt.day}/${createdAt.month}/${createdAt.year}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
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
