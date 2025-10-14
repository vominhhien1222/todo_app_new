import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../auth/login_via_email.dart'; // 👈 để logout quay lại login
import 'my_orders_screen.dart'; // ✅ THÊM DÒNG NÀY

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final auth = FirebaseAuth.instance;
  final picker = ImagePicker();

  /// 🔹 Đổi avatar
  Future<void> _pickAndUploadAvatar() async {
    final user = auth.currentUser;
    if (user == null) return;

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked == null) return;

    final file = File(picked.path);

    try {
      final ref = FirebaseStorage.instance.ref().child(
        "avatars/${user.uid}.jpg",
      );
      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection("users").doc(user.uid).update(
        {"avatarUrl": url},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật avatar thành công ✅")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi khi upload: $e")));
      }
    }
  }

  /// 🔹 Đăng xuất
  Future<void> _logout() async {
    await auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginViaEmail()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Chưa đăng nhập")));
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 235, 202, 228),
              Color.fromARGB(255, 250, 211, 247),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(
                  child: Text("Không tìm thấy thông tin user"),
                );
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;
              final email = data["email"] ?? user.email ?? "Không có email";
              final username = data["username"] ?? "Người dùng";
              final avatarUrl = data["avatarUrl"];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.teal.shade200,
                      backgroundImage: avatarUrl != null
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: avatarUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      email,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // 🔹 Nút đổi ảnh đại diện
                    ElevatedButton.icon(
                      onPressed: _pickAndUploadAvatar,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Đổi ảnh đại diện"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ✅ Nút “Đơn hàng của tôi”
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyOrdersScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: const Text("Đơn hàng của tôi"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🔹 Nút đăng xuất
                    ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text("Đăng xuất"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
