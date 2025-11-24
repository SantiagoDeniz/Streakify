import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'themes/app_themes.dart';
import 'services/accessibility_service.dart';
import 'services/personalization_service.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final accessibilityService = AccessibilityService();
  await accessibilityService.init();
  
  final personalizationService = PersonalizationService();
  await personalizationService.init();
  
  final themeService = ThemeService();
  await themeService.init();
  
  runApp(StreakifyApp(
    accessibilityService: accessibilityService,
    personalizationService: personalizationService,
    themeService: themeService,
  ));
}

class StreakifyApp extends StatefulWidget {
  final AccessibilityService accessibilityService;
  final PersonalizationService personalizationService;
  final ThemeService themeService;
  
  const StreakifyApp({
    super.key, 
    required this.accessibilityService,
    required this.personalizationService,
    required this.themeService,
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
    widget.personalizationService.addListener(_onPersonalizationChanged);
    widget.themeService.addListener(_onThemeServiceChanged);
    
    // Check if auto-theme is enabled and apply it
    if (widget.themeService.autoSwitchEnabled) {
      _themeMode = widget.themeService.getAutoTheme();
    }
  }

  @override
  void dispose() {
    widget.accessibilityService.removeListener(_onAccessibilityChanged);
    widget.personalizationService.removeListener(_onPersonalizationChanged);
    widget.themeService.removeListener(_onThemeServiceChanged);
    super.dispose();
  }

  void _onAccessibilityChanged() {
    setState(() {});
  }

  void _onPersonalizationChanged() {
    setState(() {});
  }

  void _onThemeServiceChanged() {
    if (widget.themeService.autoSwitchEnabled) {
      final autoTheme = widget.themeService.getAutoTheme();
      if (autoTheme != _themeMode) {
        _changeTheme(autoTheme);
      }
    }
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
    // Combine text scale from both accessibility and personalization
    final combinedTextScale = widget.accessibilityService.textScaleFactor * 
                              widget.personalizationService.textSizeMultiplier;
    
    return AnimatedTheme(
      data: AppThemes.getTheme(_themeMode),
      duration: widget.accessibilityService.reduceMotion 
          ? Duration.zero 
          : const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: MediaQuery(
        data: MediaQueryData.fromView(View.of(context)).copyWith(
          textScaler: TextScaler.linear(combinedTextScale),
        ),
        child: MaterialApp(
          title: 'Streakify',
          debugShowCheckedModeBanner: false,
          theme: AppThemes.getTheme(_themeMode).copyWith(
            textTheme: AppThemes.getTheme(_themeMode).textTheme.apply(
              fontFamily: widget.personalizationService.fontFamily,
            ),
          ),
          locale: widget.personalizationService.locale,
          home: HomeScreen(
            onThemeChanged: _changeTheme,
            personalizationService: widget.personalizationService,
            themeService: widget.themeService,
          ),
          builder: (context, child) {
            // Ensure text scale is applied globally
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(combinedTextScale),
              ),
              child: child!,
            );
          },
        ),
      ),
    );
  }
}

