import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'themes/app_themes.dart';
import 'services/accessibility_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final accessibilityService = AccessibilityService();
  await accessibilityService.init();
  
  runApp(StreakifyApp(accessibilityService: accessibilityService));
}

class StreakifyApp extends StatefulWidget {
  final AccessibilityService accessibilityService;
  
  const StreakifyApp({
    super.key, 
    required this.accessibilityService,
  });

  @override
  State<StreakifyApp> createState() => _StreakifyAppState();
}

class _StreakifyAppState extends State<StreakifyApp> {
  AppThemeMode _themeMode = AppThemeMode.bright;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    widget.accessibilityService.addListener(_onAccessibilityChanged);
  }

  @override
  void dispose() {
    widget.accessibilityService.removeListener(_onAccessibilityChanged);
    super.dispose();
  }

  void _onAccessibilityChanged() {
    setState(() {});
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('appThemeMode') ?? 0;
    setState(() {
      if (themeIndex < AppThemeMode.values.length) {
        _themeMode = AppThemeMode.values[themeIndex];
      } else {
        _themeMode = AppThemeMode.bright;
      }
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
    // Apply text scale factor from accessibility service
    return AnimatedTheme(
      data: AppThemes.getTheme(_themeMode),
      duration: widget.accessibilityService.reduceMotion 
          ? Duration.zero 
          : const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: MediaQuery(
        data: MediaQueryData.fromView(View.of(context)).copyWith(
          textScaler: TextScaler.linear(widget.accessibilityService.textScaleFactor),
        ),
        child: MaterialApp(
          title: 'Streakify',
          debugShowCheckedModeBanner: false,
          theme: AppThemes.getTheme(_themeMode),
          home: HomeScreen(onThemeChanged: _changeTheme),
          builder: (context, child) {
            // Ensure text scale is applied globally
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(widget.accessibilityService.textScaleFactor),
              ),
              child: child!,
            );
          },
        ),
      ),
    );
  }
}
