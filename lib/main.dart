import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

// 🔹 Import các provider của bạn
import 'package:todo_app_new/providers/car_provider.dart';
import 'package:todo_app_new/providers/cart_provider.dart';
import 'package:todo_app_new/providers/dashboard_provider.dart';
import 'package:todo_app_new/providers/order_provider.dart';
import 'package:todo_app_new/providers/todo_provider.dart';
import 'package:todo_app_new/providers/admin_users_provider.dart';
import 'package:todo_app_new/providers/theme_provider.dart';

// 🔹 Firebase config
import 'firebase_options.dart';

// 🔹 Routes
import 'routes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TodoProvider()),
        ChangeNotifierProvider(create: (_) => AdminUsersProvider()),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ), // ✅ ThemeProvider
        ChangeNotifierProvider(create: (_) => CarProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AnimatedTheme(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      data: themeProvider.currentTheme == ThemeMode.dark
          ? themeProvider.darkTheme
          : themeProvider.lightTheme,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Todo + Car Admin',

        // ✅ Dùng theme động từ ThemeProvider
        theme: themeProvider.lightTheme,
        darkTheme: themeProvider.darkTheme,
        themeMode: themeProvider.currentTheme,

        // ✅ Đường dẫn khởi động & route
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      ),
    );
  }
}
