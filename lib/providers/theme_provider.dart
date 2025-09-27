import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeType { light, dark, system }

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'selected_theme';
  static const String _cheatModeKey = 'cheat_mode_enabled';
  ThemeType _currentTheme = ThemeType.system;
  bool _isCheatModeEnabled = false;

  ThemeType get currentTheme => _currentTheme;
  bool get isCheatModeEnabled => _isCheatModeEnabled;

  ThemeProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme
    final themeString = prefs.getString(_themeKey) ?? 'system';
    _currentTheme = ThemeType.values.firstWhere(
      (e) => e.toString().split('.').last == themeString,
      orElse: () => ThemeType.system,
    );

    // Load cheat mode
    _isCheatModeEnabled = prefs.getBool(_cheatModeKey) ?? false;

    notifyListeners();
  }

  Future<void> setTheme(ThemeType theme) async {
    _currentTheme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme.toString().split('.').last);
    notifyListeners();
  }

  Future<void> toggleCheatMode() async {
    _isCheatModeEnabled = !_isCheatModeEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_cheatModeKey, _isCheatModeEnabled);
    notifyListeners();
  }

  ThemeMode get themeMode {
    switch (_currentTheme) {
      case ThemeType.light:
        return ThemeMode.light;
      case ThemeType.dark:
        return ThemeMode.dark;
      case ThemeType.system:
        return ThemeMode.system;
    }
  }

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    primaryColor: Colors.blue.shade600,
    scaffoldBackgroundColor: Colors.grey.shade50,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue.shade600,
      elevation: 2,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    iconTheme: IconThemeData(color: Colors.blue.shade600),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.black54,
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: Colors.blue.shade600,
      secondary: Colors.blue.shade400,
      surface: Colors.white,
      error: Colors.red.shade400,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
      onError: Colors.white,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    primaryColor: Colors.blue.shade400,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 0,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade400,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    iconTheme: IconThemeData(color: Colors.blue.shade400),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.white70,
      ),
    ),
    colorScheme: ColorScheme.dark(
      primary: Colors.blue.shade400,
      secondary: Colors.blue.shade300,
      surface: const Color(0xFF1E1E1E),
      error: Colors.red.shade400,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onError: Colors.white,
    ),
  );
}