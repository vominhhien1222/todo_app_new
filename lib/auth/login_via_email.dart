import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../routes.dart';
import '../widgets/custom_toast.dart';
import '../auth/ensure_user_doc.dart';

class LoginViaEmail extends StatefulWidget {
  const LoginViaEmail({super.key});

  @override
  State<LoginViaEmail> createState() => _LoginViaEmailState();
}

class _LoginViaEmailState extends State<LoginViaEmail>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final auth = FirebaseAuth.instance;

  bool _obscurePassword = true;
  bool _loading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      final user = userCredential.user;
      if (user == null) throw Exception("Không tìm thấy user");

      await user.getIdToken(true);
      await ensureUserDoc();

      final idTokenResult = await user.getIdTokenResult(true);
      final claims = idTokenResult.claims ?? {};
      final roles =
          (claims['roles'] as List?)?.map((e) => e.toString()).toList() ?? [];

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final firestoreRole = userDoc.data()?['role'] ?? 'user';

      final isAdmin =
          roles.contains('admin') ||
          roles.contains('super_admin') ||
          firestoreRole == 'admin' ||
          firestoreRole == 'super_admin';

      CustomToast().Toastt("Đăng nhập thành công 🎉");
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      if (isAdmin) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.adminPanel,
          (route) => false,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.userMain,
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'user-not-found':
          msg = "Không tìm thấy tài khoản này 😢";
          break;
        case 'wrong-password':
          msg = "Sai mật khẩu, thử lại nhé 🔐";
          break;
        case 'invalid-email':
          msg = "Email không hợp lệ";
          break;
        default:
          msg = "Lỗi: ${e.message}";
      }
      CustomToast().Toastt(msg);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final primary = colorScheme.primary;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity, // ✅ phủ kín toàn màn hình
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primary.withOpacity(0.9),
              isDark ? Colors.black : Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 48,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 450,
                  ), // ✅ giới hạn chiều ngang
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 🖼 Logo app
                      Image.asset(
                        "assets/images/logo_car.png",
                        width: 120,
                        height: 120,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "CAR RENTAL APP",
                        style: theme.textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 📋 Form login
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // ✉️ Email
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: primary,
                                ),
                                labelText: "Email",
                                filled: true,
                                fillColor: isDark
                                    ? Colors.grey.shade900
                                    : Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Nhập email";
                                }
                                if (!value.contains('@') ||
                                    !value.contains('.')) {
                                  return "Email không hợp lệ";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // 🔒 Password
                            TextFormField(
                              controller: passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: primary,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: primary,
                                  ),
                                  onPressed: () => setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  }),
                                ),
                                labelText: "Mật khẩu",
                                filled: true,
                                fillColor: isDark
                                    ? Colors.grey.shade900
                                    : Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              validator: (value) =>
                                  value == null || value.length < 6
                                  ? "Mật khẩu ít nhất 6 ký tự"
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 🔁 Quên mật khẩu
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          child: Text(
                            "Quên mật khẩu?",
                            style: TextStyle(color: primary),
                          ),
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.forget),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 🚪 Nút đăng nhập
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: primary,
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
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Đăng nhập",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 🆕 Đăng ký
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Chưa có tài khoản?",
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            child: Text(
                              "Đăng ký ngay",
                              style: TextStyle(
                                color: primary,
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
          ),
        ),
      ),
    );
  }
}
