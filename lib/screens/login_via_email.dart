import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_page.dart';
import 'forget_password.dart';
import '../widgets/validate_btn.dart';
import '../widgets/custom_toast.dart';
import '../screens/todo_list_screen.dart';

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

  void _login() {
    auth
        .signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        )
        .then((value) {
          CustomToast().Toastt('Đăng nhập thành công');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const TodoListScreen()),
            (route) => false,
          );
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
              const Icon(Icons.lock, size: 100, color: Colors.teal),
              const SizedBox(height: 20),
              const Text(
                'Đăng nhập',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email, color: Colors.teal),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Nhập email" : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Mật khẩu",
                        prefixIcon: Icon(Icons.lock, color: Colors.teal),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.length < 4
                          ? "Mật khẩu ít nhất 4 ký tự"
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  child: const Text("Quên mật khẩu?"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ForgetPassword()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              ValidateBtn(
                title: "Đăng nhập",
                ontap: () {
                  if (_formKey.currentState!.validate()) _login();
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Chưa có tài khoản?"),
                  TextButton(
                    child: const Text("Đăng ký"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpPage()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
