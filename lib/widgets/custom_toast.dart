import 'package:flutter/material.dart';

class CustomToast {
  void Toastt(String message) {
    // ignore: use_build_context_synchronously
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.teal,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// 👇 Để dùng được global context, thêm navigatorKey vào MaterialApp
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
