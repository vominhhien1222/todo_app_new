import 'package:flutter/material.dart';
import 'user_todos_screen.dart';
import 'user_profile_screen.dart';

class UserPanelScreen extends StatefulWidget {
  const UserPanelScreen({super.key});

  @override
  State<UserPanelScreen> createState() => _UserPanelScreenState();
}

class _UserPanelScreenState extends State<UserPanelScreen> {
  int _currentIndex = 0;

  // Danh sách các tab (Công việc + Hồ sơ)
  final List<Widget> _screens = const [UserTodosScreen(), UserProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
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
