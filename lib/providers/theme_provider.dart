import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _currentTheme = ThemeMode.light;
  MaterialColor _primaryColor = Colors.teal;

  ThemeMode get currentTheme => _currentTheme;
  MaterialColor get primaryColor => _primaryColor;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  void toggleTheme() {
    _currentTheme = _currentTheme == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    _saveThemeToPrefs();
    notifyListeners();
  }

  void setPrimaryColor(MaterialColor color) {
    _primaryColor = color;
    _saveThemeToPrefs();
    notifyListeners();
  }

  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.light,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _primaryColor.shade500, // ✅ AppBar đồng bộ màu
      foregroundColor: Colors.white, // chữ/icon sáng
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _primaryColor.shade500,
      foregroundColor: Colors.white,
    ),
    cardColor: _primaryColor.shade50,
  );

  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: Colors.grey.shade900,
    appBarTheme: AppBarTheme(
      backgroundColor: _primaryColor.shade700, // ✅ AppBar tối hơn chút
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _primaryColor.shade400,
      foregroundColor: Colors.black,
    ),
    cardColor: Colors.grey.shade800,
  );

  Future<void> _saveThemeToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDark', _currentTheme == ThemeMode.dark);
    prefs.setInt('color', _primaryColor.value);
  }

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDark') ?? false;
    final colorValue = prefs.getInt('color') ?? Colors.teal.value;

    _currentTheme = isDark ? ThemeMode.dark : ThemeMode.light;
    _primaryColor = _colorFromValue(colorValue);
    notifyListeners();
  }

  MaterialColor _colorFromValue(int value) {
    return _colorMap.entries
        .firstWhere(
          (e) => e.value.value == value,
          orElse: () => const MapEntry('teal', Colors.teal),
        )
        .value;
  }

  static final Map<String, MaterialColor> _colorMap = {
    'teal': Colors.teal,
    'blue': Colors.blue,
    'orange': Colors.orange,
    'deepPurple': Colors.deepPurple,
    'pink': Colors.pink,
  };
}
