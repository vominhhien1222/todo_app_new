import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../toast/custom_toast.dart';
import 'login_via_email.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formfield = GlobalKey<FormState>();
  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  final auth = FirebaseAuth.instance;

  @override
  void dispose() {
    emailcontroller.dispose();
    passwordcontroller.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formfield.currentState!.validate()) return;

    try {
      final value = await auth.createUserWithEmailAndPassword(
        email: emailcontroller.text.trim(),
        password: passwordcontroller.text.trim(),
      );

      // 👉 Lưu user vào Firestore với role mặc định là "user"
      await FirebaseFirestore.instance
          .collection("users")
          .doc(value.user!.uid)
          .set({
            "email": emailcontroller.text.trim(),
            "username": emailcontroller.text.trim().split("@")[0],
            "role": "user",
            "avatarUrl": null,
          });

      CustomToast().Toastt('Tạo tài khoản thành công ✅');

      // 👉 Chuyển về Login
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginViaEmail(),
          transitionsBuilder: (_, animation, __, child) {
            const begin = Offset(-1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } on FirebaseAuthException catch (e) {
      CustomToast().Toastt(e.message ?? "Đăng ký thất bại");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng ký")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formfield,
          child: Column(
            children: [
              TextFormField(
                controller: emailcontroller,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Nhập email";
                  if (!value.contains('@')) return "Email không hợp lệ";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordcontroller,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Mật khẩu"),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Nhập mật khẩu";
                  if (value.length < 6) return "Mật khẩu ≥ 6 ký tự";
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _signUp, child: const Text("Đăng ký")),
            ],
          ),
        ),
      ),
    );
  }
}
