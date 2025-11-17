import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'themes/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StreakifyApp());
}

class StreakifyApp extends StatefulWidget {
  const StreakifyApp({super.key});

  @override
  State<StreakifyApp> createState() => _StreakifyAppState();
}

class _StreakifyAppState extends State<StreakifyApp> {
  AppThemeMode _themeMode = AppThemeMode.bright;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('appThemeMode') ?? 0;
    setState(() {
      _themeMode = AppThemeMode.values[themeIndex];
    });
  }

  Future<void> _changeTheme(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('appThemeMode', mode.index);
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
      data: AppThemes.getTheme(_themeMode),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: MaterialApp(
        title: 'Streakify',
        debugShowCheckedModeBanner: false,
        theme: AppThemes.getTheme(_themeMode),
        home: HomeScreen(onThemeChanged: _changeTheme),
      ),
    );
  }
}
