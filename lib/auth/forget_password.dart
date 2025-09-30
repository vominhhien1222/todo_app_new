import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../routes.dart';
import '../widgets/custom_toast.dart';
import '../widgets/validate_btn.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final auth = FirebaseAuth.instance;
  bool _loading = false;

  Future<void> _resetPassword() async {
    setState(() => _loading = true);
    try {
      await auth.sendPasswordResetEmail(email: emailController.text.trim());
      if (mounted) {
        CustomToast().Toastt("📩 Đã gửi liên kết đặt lại mật khẩu đến email");
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) CustomToast().Toastt("Lỗi: ${e.message}");
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
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock_reset,
                        size: 80,
                        color: Colors.teal,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Quên mật khẩu",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? "Nhập email"
                            : (!value.contains('@')
                                  ? "Email không hợp lệ"
                                  : null),
                      ),
                      const SizedBox(height: 24),
                      _loading
                          ? const CircularProgressIndicator()
                          : ValidateBtn(
                              title: "Gửi liên kết",
                              ontap: () {
                                if (_formKey.currentState!.validate()) {
                                  _resetPassword();
                                }
                              },
                            ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (route) => false,
                        ),
                        child: const Text("Quay lại đăng nhập"),
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
