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

  Future<void> _editAnnouncement(String id, Map<String, dynamic> data) async {
    _titleController.text = data["title"] ?? "";
    _contentController.text = data["content"] ?? "";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Sửa Announcement"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Tiêu đề"),
            ),
            TextField(
              controller: _contentController,
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
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection("announcements")
                  .doc(id)
                  .update({
                    "title": _titleController.text,
                    "content": _contentController.text,
                  });
              Navigator.pop(context);
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  void _openAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Thêm Announcement"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Tiêu đề"),
            ),
            TextField(
              controller: _contentController,
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

  Future<void> _deleteAnnouncement(String id, String title) async {
    await FirebaseFirestore.instance
        .collection("announcements")
        .doc(id)
        .delete();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Đã xóa announcement: $title")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Announcements"),
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
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final anns = snapshot.data!.docs;

          if (anns.isEmpty)
            return const Center(child: Text("Chưa có announcement nào"));

          return ListView.builder(
            itemCount: anns.length,
            itemBuilder: (context, index) {
              final doc = anns[index];
              final data = doc.data() as Map<String, dynamic>;
              final title = data["title"] ?? "";

              return Card(
                child: ListTile(
                  title: Text(title),
                  subtitle: Text(data["content"] ?? ""),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editAnnouncement(doc.id, data),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteAnnouncement(doc.id, title),
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
