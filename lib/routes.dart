import 'package:flutter/material.dart';
import 'auth/login_via_email.dart';
import 'auth/signup_page.dart';
import 'auth/forget_password.dart';
import 'user/user_todos_screen.dart';
import 'user/user_announcements_screen.dart';
import 'admin/admin_panel_screen.dart';
import 'admin/admin_users_screen.dart';
import 'splash/splash_screen.dart';
import 'admin/admin_todos_screen.dart';
import 'user/user_main_screen.dart';
import 'admin/admin_dashboard_screen.dart'; // ✅ Thêm route Dashboard mới

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forget = '/forget';
  static const String todos = '/todos';
  static const String userAnnouncements = '/userAnnouncements';
  static const String admin = '/admin';
  static const String adminUsers = '/admin/users';
  static const String userMain = '/userMain';
  static const String adminTodos = '/adminTodos';
  static const String adminPanel = '/adminPanel'; // ✅ Dashboard admin mới

  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginViaEmail(),
    signup: (_) => const SignupPage(),
    forget: (_) => const ForgetPassword(),
    todos: (_) => const UserTodosScreen(),
    userAnnouncements: (_) => const UserAnnouncementsScreen(),

    // 🔹 Các màn hình admin
    admin: (_) => const AdminPanelScreen(),
    adminUsers: (_) => const AdminUsersScreen(),
    adminTodos: (_) => const AdminTodosScreen(),
    adminPanel: (_) =>
        const AdminDashboardScreen(), // ✅ Mở dashboard sidebar trái
    // 🔹 Các màn hình user
    userMain: (_) => const UserMainScreen(),
  };
}
