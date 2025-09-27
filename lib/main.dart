import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(const GambitApp());
}

class GambitApp extends StatefulWidget {
  const GambitApp({super.key});

  @override
  State<GambitApp> createState() => _GambitAppState();
}

class _GambitAppState extends State<GambitApp> {
  late ThemeProvider _themeProvider;

  @override
  void initState() {
    super.initState();
    _themeProvider = ThemeProvider();
    _themeProvider.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _themeProvider.removeListener(_onThemeChanged);
    _themeProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gambit',
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      themeMode: _themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      home: SplashScreen(themeProvider: _themeProvider),
    );
  }
}
