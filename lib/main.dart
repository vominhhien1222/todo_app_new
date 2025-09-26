import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // file này do flutterfire configure sinh ra
import 'providers/todo_provider.dart';
import 'screens/login_via.dart'; // 👈 thay vì todo_list_screen

// 👇 Khai báo navigatorKey toàn cục
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ cần cho async
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // ✅ khởi tạo Firebase
  );
  runApp(
    ChangeNotifierProvider(create: (_) => TodoProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // 👈 để CustomToast dùng được
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const LoginVia(), // 👈 màn hình khởi động là Login
    );
  }
}
