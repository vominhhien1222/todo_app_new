import 'package:flutter/material.dart';
import 'auth/login_via_email.dart';
import 'auth/signup_page.dart';
import 'auth/forget_password.dart';
import 'user/user_todos_screen.dart';
import 'user/user_announcements_screen.dart'; // 👈 đã có
import 'admin/admin_panel_screen.dart';
import 'admin/admin_users_screen.dart'; // 👈 THÊM import màn User Management
import 'splash/splash_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forget = '/forget';
  static const String todos = '/todos';
  static const String userAnnouncements = '/userAnnouncements';
  static const String admin = '/admin';
  static const String adminUsers =
      '/admin/users'; // 👉 THÊM hằng số route cho User Management

  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginViaEmail(),
    signup: (_) => const SignupPage(),
    forget: (_) => const ForgetPassword(),
    todos: (_) => const UserTodosScreen(),
    userAnnouncements: (_) => const UserAnnouncementsScreen(),
    admin: (_) => const AdminPanelScreen(),
    adminUsers: (_) => const AdminUsersScreen(), // 👉 MAP route User Management
  };
}
