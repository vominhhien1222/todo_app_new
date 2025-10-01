import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserAnnouncementsScreen extends StatelessWidget {
  const UserAnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông báo"),
        backgroundColor: Colors.teal,
        centerTitle: true,
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
              final data = docs[index].data() as Map<String, dynamic>;
              final title = data["title"] ?? "Không có tiêu đề";
              final content = data["content"] ?? "";
              final createdAt = (data["createdAt"] as Timestamp?)?.toDate();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        content,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      if (createdAt != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Ngày: ${createdAt.day}/${createdAt.month}/${createdAt.year}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
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
