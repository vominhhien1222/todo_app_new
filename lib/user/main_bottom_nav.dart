import 'package:flutter/material.dart';
import 'user_home_screen.dart';
import 'user_todos_screen.dart';
import 'user_announcements_screen.dart';
import 'user_profile_screen.dart';

/// ----------------------------
/// MAIN BOTTOM NAV (USER APP)
/// ----------------------------
/// Dùng NavigationBar (Material 3)
/// + AnimatedSwitcher để chuyển tab có hiệu ứng Fade + Slide.
/// + Màu pastel teal/cyan đồng bộ style "tươi tươi" của toàn app.
/// + Giữ state khi chuyển tab (mỗi màn hình không bị reload).
class MainBottomNav extends StatefulWidget {
  const MainBottomNav({super.key});

  @override
  State<MainBottomNav> createState() => _MainBottomNavState();
}

class _MainBottomNavState extends State<MainBottomNav> {
  int _currentIndex = 0;

  // Danh sách 4 màn hình chính của User App
  final _screens = const [
    UserHomeScreen(), // 🏠 Trang chính (bản tin)
    UserTodosScreen(), // ✅ Danh sách Todos
    UserAnnouncementsScreen(), // 📢 Thông báo
    UserProfileScreen(), // 👤 Hồ sơ cá nhân
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Màu pastel đồng bộ (teal + cyan)
    final Color primary = isDark ? Colors.tealAccent : Colors.teal;
    final Color navBg = isDark ? Colors.blueGrey.shade900 : Colors.white;
    final Color inactive = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      // AnimatedSwitcher tạo hiệu ứng chuyển trang mượt
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0.05, 0.02), // trượt nhẹ khi chuyển tab
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        child: _screens[_currentIndex],
      ),

      // ----------------------------
      // BOTTOM NAVIGATION BAR
      // ----------------------------
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: primary.withOpacity(0.15),
          labelTextStyle: WidgetStatePropertyAll(
            theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        child: NavigationBar(
          backgroundColor: navBg,
          elevation: 6,
          height: 68,
          animationDuration: const Duration(milliseconds: 300),
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: inactive),
              selectedIcon: Icon(Icons.home_rounded, color: primary),
              label: 'Trang chính',
            ),
            NavigationDestination(
              icon: Icon(Icons.check_circle_outline, color: inactive),
              selectedIcon: Icon(Icons.check_circle_rounded, color: primary),
              label: 'Todos',
            ),
            NavigationDestination(
              icon: Icon(Icons.campaign_outlined, color: inactive),
              selectedIcon: Icon(Icons.campaign, color: primary),
              label: 'Thông báo',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: inactive),
              selectedIcon: Icon(Icons.person, color: primary),
              label: 'Tài khoản',
            ),
          ],
        ),
      ),
    );
  }
}
