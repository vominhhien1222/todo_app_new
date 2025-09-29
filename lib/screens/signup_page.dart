import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'todo_list_screen.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _loading = false;

  Future<void> _signupUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      // Tạo user với FirebaseAuth
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passController.text.trim(),
          );

      // Lưu thông tin vào Firestore
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user!.uid)
          .set({
            "uid": userCredential.user!.uid,
            "email": _emailController.text.trim(),
            "username": "Người dùng mới",
            "role": "user", // 👈 user mặc định
            "avatarUrl": null,
            "createdAt": FieldValue.serverTimestamp(),
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Đăng ký thành công ✅")));

      // Vào TodoList sau khi đăng ký thành công
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TodoListScreen()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi: ${e.message}")));
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
        title: const Text("Đăng ký User"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (val) => val == null || !val.contains("@")
                    ? "Email không hợp lệ"
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Mật khẩu"),
                validator: (val) => val != null && val.length >= 6
                    ? null
                    : "Mật khẩu ít nhất 6 ký tự",
              ),
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _signupUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text("Đăng ký"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
