import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../routes.dart';

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
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passController.text.trim(),
          );

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user!.uid)
          .set({
            "uid": userCredential.user!.uid,
            "email": _emailController.text.trim(),
            "username": "Người dùng mới",
            "role": "user", // 👈 mặc định user
            "avatarUrl": null,
            "createdAt": FieldValue.serverTimestamp(),
          });

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.todos,
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi: ${e.message}")));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.greenAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.person_add,
                        size: 80,
                        color: Colors.teal,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Đăng ký User",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val == null || !val.contains("@")
                            ? "Email không hợp lệ"
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Mật khẩu",
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val != null && val.length >= 6
                            ? null
                            : "Mật khẩu ít nhất 6 ký tự",
                      ),
                      const SizedBox(height: 24),
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
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (route) => false,
                        ),
                        child: const Text("Đã có tài khoản? Đăng nhập"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
