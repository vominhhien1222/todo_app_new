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

  // 🔄 Chuyển dark/light
  void toggleTheme() {
    _currentTheme = _currentTheme == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    _saveThemeToPrefs();
    notifyListeners();
  }

  // 🎨 Đổi màu chủ đạo
  void setPrimaryColor(MaterialColor color) {
    _primaryColor = color;
    _saveThemeToPrefs();
    notifyListeners();
  }

  // 🌞 Giao diện sáng
  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor.shade500,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.grey.shade50,
    appBarTheme: AppBarTheme(
      backgroundColor: _primaryColor.shade500,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _primaryColor.shade500,
      foregroundColor: Colors.white,
    ),
    cardColor: _primaryColor.shade50,
  );

  // 🌙 Giao diện tối
  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor.shade500,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: Colors.grey.shade900,
    appBarTheme: AppBarTheme(
      backgroundColor: _primaryColor.shade500,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _primaryColor.shade500,
      foregroundColor: Colors.white,
    ),
    cardColor: Colors.grey.shade800,
  );

  // 💾 Lưu vào SharedPreferences
  Future<void> _saveThemeToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDark', _currentTheme == ThemeMode.dark);
    prefs.setInt('color', _primaryColor.value);
  }

  // 📥 Tải theme đã lưu
  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDark') ?? false;
    final colorValue = prefs.getInt('color') ?? Colors.teal.value;

    _currentTheme = isDark ? ThemeMode.dark : ThemeMode.light;
    _primaryColor = _colorFromValue(colorValue);
    notifyListeners();
  }

  // 🎨 Chuyển int thành MaterialColor
  MaterialColor _colorFromValue(int value) {
    return _colorMap.entries
        .firstWhere(
          (e) => e.value.value == value,
          orElse: () => const MapEntry('teal', Colors.teal),
        )
        .value;
  }

  // 🗺️ Map màu để lưu/đọc
  static final Map<String, MaterialColor> _colorMap = {
    'teal': Colors.teal,
    'blue': Colors.blue,
    'orange': Colors.orange,
    'deepPurple': Colors.deepPurple,
    'pink': Colors.pink,
    'green': Colors.green,
    'red': Colors.red,
  };

  // 🎨 Danh sách màu + icon hiển thị trong UI
  static final List<ColorOption> colorOptions = [
    ColorOption('Teal', Colors.teal, Icons.water_drop),
    ColorOption('Blue', Colors.blue, Icons.cloud),
    ColorOption('Orange', Colors.orange, Icons.sunny),
    ColorOption('Deep Purple', Colors.deepPurple, Icons.nightlight_round),
    ColorOption('Pink', Colors.pink, Icons.favorite),
    ColorOption('Green', Colors.green, Icons.eco),
    ColorOption('Red', Colors.red, Icons.fireplace),
  ];
}

// 🌈 Class chứa dữ liệu màu + icon
class ColorOption {
  final String name;
  final MaterialColor color;
  final IconData icon;
  const ColorOption(this.name, this.color, this.icon);
}
