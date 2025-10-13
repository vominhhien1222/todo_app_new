import 'package:flutter/material.dart';
import 'user_home_screen.dart';
import 'user_cars_screen.dart';
import 'cart_screen.dart';
import 'user_orders_screen.dart';
import 'user_announcements_screen.dart';
import 'user_profile_screen.dart';
import 'user_todos_screen.dart';

class UserPanelScreen extends StatefulWidget {
  const UserPanelScreen({super.key});

  @override
  State<UserPanelScreen> createState() => _UserPanelScreenState();
}

class _UserPanelScreenState extends State<UserPanelScreen> {
  int _currentIndex = 0;

  // Danh sách đầy đủ các màn hình cho người dùng
  final List<Widget> _screens = const [
    UserHomeScreen(), // Trang chủ
    UserCarsScreen(), // Danh sách xe
    CartScreen(), //  Giỏ hàng
    UserOrdersScreen(), // Đơn hàng
    UserAnnouncementsScreen(), // Tin tức / thông báo
    UserTodosScreen(), // Công việc cá nhân
    UserProfileScreen(), // Hồ sơ cá nhân
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: "Xe",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Giỏ hàng",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Đơn hàng",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: "Tin tức"),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "Công việc",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Hồ sơ"),
        ],
      ),
    );
  }
}
