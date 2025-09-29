import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_panel_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _loading = false;

  Future<void> _loginAdmin() async {
    setState(() => _loading = true);

    try {
      // ✅ Đăng nhập bằng FirebaseAuth
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passController.text.trim(),
          );

      final user = userCredential.user;
      if (user == null) {
        throw Exception("Không thể đăng nhập admin");
      }

      // ✅ Check role trong Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        throw Exception("Không tìm thấy thông tin admin trong DB");
      }

      final data = doc.data() as Map<String, dynamic>;
      final role = data['role'] ?? 'user';

      if (role == 'admin') {
        // Đúng admin → sang Admin Panel
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
          );
        }
      } else {
        // Không phải admin
        await FirebaseAuth.instance.signOut(); // sign out lại cho an toàn
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tài khoản này không có quyền Admin ❌")),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi đăng nhập: ${e.message}")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Login"),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email Admin"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passController,
              decoration: const InputDecoration(labelText: "Mật khẩu"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _loginAdmin,
                    child: const Text("Đăng nhập"),
                  ),
          ],
        ),
      ),
    );
  }
}
