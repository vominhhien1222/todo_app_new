import 'package:flutter/material.dart';
import 'user_home_screen.dart';
import 'user_todos_screen.dart';
import 'user_announcements_screen.dart';
import 'cart_screen.dart';
import 'user_cars_screen.dart';
import 'user_profile_screen.dart'; // ✅ THÊM import này

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({super.key});

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _onItemTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.teal.shade50,

      // ✅ Thêm UserProfileScreen vào cuối PageView
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: _onPageChanged,
        children: const [
          UserHomeScreen(), // 🏠 Trang chủ
          UserTodosScreen(), // ✅ Công việc
          UserAnnouncementsScreen(), // 📢 Thông báo
          CartScreen(), // 🛒 Giỏ hàng
          UserCarsScreen(), // 🚗 Danh mục xe
          UserProfileScreen(), // 👤 Hồ sơ người dùng ✅ MỚI
        ],
      ),

      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: isDark
              ? Colors.tealAccent.shade700
              : Colors.teal.shade100,
          labelTextStyle: MaterialStateProperty.all(
            TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.tealAccent : Colors.teal,
            ),
          ),
        ),
        child: NavigationBar(
          height: 68,
          elevation: 2,
          backgroundColor: isDark
              ? Colors.grey.shade900.withOpacity(0.95)
              : Colors.white,
          selectedIndex: _currentIndex,
          onDestinationSelected: _onItemTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: Colors.teal),
              label: "Trang chủ",
            ),
            NavigationDestination(
              icon: Icon(Icons.check_circle_outline),
              selectedIcon: Icon(Icons.check_circle, color: Colors.teal),
              label: "Công việc",
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              selectedIcon: Icon(
                Icons.notifications_active,
                color: Colors.teal,
              ),
              label: "Thông báo",
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_cart_outlined),
              selectedIcon: Icon(Icons.shopping_cart, color: Colors.teal),
              label: "Giỏ hàng",
            ),
            NavigationDestination(
              icon: Icon(Icons.directions_car_outlined),
              selectedIcon: Icon(Icons.directions_car, color: Colors.teal),
              label: "Danh mục xe",
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: Colors.teal),
              label: "Tài khoản", // 👤 Mục mới
            ),
          ],
        ),
      ),
    );
  }
}
