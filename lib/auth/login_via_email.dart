import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

import '../routes.dart';
import '../widgets/custom_toast.dart';
import '../auth/ensure_user_doc.dart'; // ⬅️ thêm import

class LoginViaEmail extends StatefulWidget {
  const LoginViaEmail({super.key});

  @override
  State<LoginViaEmail> createState() => _LoginViaEmailState();
}

class _LoginViaEmailState extends State<LoginViaEmail> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final auth = FirebaseAuth.instance;

  bool _obscurePassword = true;
  bool _loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception("Không tìm thấy user");
      }

      // 🔹 Refresh token để lấy custom claims mới nhất
      await user.getIdToken(true);

      // 🔹 Đảm bảo có users/{uid} trong Firestore với status=active
      await ensureUserDoc();

      // 🔹 Lấy roles từ custom claims
      final idTokenResult = await user.getIdTokenResult(true);
      final claims = idTokenResult.claims ?? {};
      final roles =
          (claims['roles'] as List?)?.map((e) => e.toString()).toList() ?? [];
      final isAdmin = roles.contains('admin') || roles.contains('super_admin');

      if (!mounted) return;
      if (isAdmin) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.admin,
          (route) => false,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.todos,
          (route) => false,
        );
      }

      CustomToast().Toastt("Đăng nhập thành công");
    } on FirebaseAuthException catch (e) {
      CustomToast().Toastt("Lỗi: ${e.message}");
    } catch (e) {
      CustomToast().Toastt("Lỗi: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00897B), Color(0xFF26A69A), Color(0xFF80CBC4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🖼 Logo
                Image.asset(
                  "assets/images/logo_car.png",
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 16),
                const Text(
                  "CAR RENTAL APP",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),

                // 📋 Form login
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Colors.white,
                          ),
                          hintText: "Email",
                          hintStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Nhập email";
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return "Email không hợp lệ";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Colors.white,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          hintText: "Mật khẩu",
                          hintStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) => value == null || value.length < 6
                            ? "Mật khẩu ít nhất 6 ký tự"
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Quên mật khẩu
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    child: const Text(
                      "Quên mật khẩu?",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.forget),
                  ),
                ),
                const SizedBox(height: 20),

                // Nút login
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _login();
                      }
                    },
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.teal)
                        : const Text(
                            "Đăng nhập",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Đăng ký
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Chưa có tài khoản?",
                      style: TextStyle(color: Colors.white),
                    ),
                    TextButton(
                      child: const Text(
                        "Đăng ký ngay",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.signup),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
