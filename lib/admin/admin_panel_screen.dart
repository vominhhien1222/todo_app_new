import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart'; // ✅ nhớ import thêm dashboard
import 'admin_users_screen.dart';
import 'admin_todos_screen.dart';
import 'admin_announcements_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_cart_view.dart';
import 'admin_profile_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    AdminDashboardScreen(), // 0
    AdminUsersScreen(), // 1
    AdminTodosScreen(), // 2
    AdminAnnouncementsScreen(), // 3
    AdminOrdersScreen(), // 4
    AdminCartViewScreen(), // 5
    AdminProfileScreen(), // 6
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red.shade700,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Users"),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: "Todos"),
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: "News"),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Orders",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Carts",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
