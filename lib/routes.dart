import 'package:flutter/material.dart';
import 'auth/login_via_email.dart';
import 'auth/signup_page.dart';
import 'auth/forget_password.dart';
import 'user/user_todos_screen.dart';
import 'user/user_announcements_screen.dart'; // 👈 import thêm
import 'admin/admin_panel_screen.dart';
import 'splash/splash_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forget = '/forget';
  static const String todos = '/todos';
  static const String userAnnouncements =
      '/userAnnouncements'; // 👈 thêm route này
  static const String admin = '/admin';

  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginViaEmail(),
    signup: (_) => const SignupPage(),
    forget: (_) => const ForgetPassword(),
    todos: (_) => const UserTodosScreen(),
    userAnnouncements: (_) => const UserAnnouncementsScreen(), // 👈 map vào đây
    admin: (_) => const AdminPanelScreen(),
  };
}
