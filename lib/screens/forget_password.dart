import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/validate_btn.dart';
import '../widgets/custom_toast.dart';
import 'login_via_email.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final auth = FirebaseAuth.instance;

  void _resetPassword() {
    auth
        .sendPasswordResetEmail(email: emailController.text.trim())
        .then((_) {
          CustomToast().Toastt("Đã gửi liên kết đặt lại mật khẩu đến email");
        })
        .onError((error, _) {
          CustomToast().Toastt(error.toString());
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Icon(Icons.lock_reset, size: 100, color: Colors.teal),
              const SizedBox(height: 20),
              const Text(
                "Quên mật khẩu",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email, color: Colors.teal),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? "Nhập email"
                      : (!value.contains('@') ? "Email không hợp lệ" : null),
                ),
              ),
              const SizedBox(height: 30),
              ValidateBtn(
                title: "Gửi liên kết",
                ontap: () {
                  if (_formKey.currentState!.validate()) _resetPassword();
                },
              ),
              const SizedBox(height: 20),
              TextButton(
                child: const Text("Quay lại đăng nhập"),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginViaEmail()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
