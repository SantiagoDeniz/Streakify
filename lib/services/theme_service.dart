import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/custom_theme.dart';
import '../themes/app_themes.dart';

/// Service to manage themes and automatic theme switching
class ThemeService extends ChangeNotifier {
  static const String _keyCustomThemes = 'theme_service_custom_themes';
  static const String _keyAutoSwitch = 'theme_service_auto_switch';
  static const String _keyLightThemeStart = 'theme_service_light_start';
  static const String _keyLightThemeEnd = 'theme_service_light_end';
  static const String _keyLightThemeMode = 'theme_service_light_mode';
  static const String _keyDarkThemeMode = 'theme_service_dark_mode';

  List<CustomTheme> _customThemes = [];
  bool _autoSwitchEnabled = false;
  int _lightThemeStartHour = 6; // 6 AM
  int _lightThemeEndHour = 18; // 6 PM
  AppThemeMode _lightThemeMode = AppThemeMode.bright;
  AppThemeMode _darkThemeMode = AppThemeMode.dark;

  // Getters
  List<CustomTheme> get customThemes => List.unmodifiable(_customThemes);
  bool get autoSwitchEnabled => _autoSwitchEnabled;
  int get lightThemeStartHour => _lightThemeStartHour;
  int get lightThemeEndHour => _lightThemeEndHour;
  AppThemeMode get lightThemeMode => _lightThemeMode;
  AppThemeMode get darkThemeMode => _darkThemeMode;

  /// Initialize and load settings
  Future<void> init() async {
    await _loadSettings();
  }

  /// Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load custom themes
    final customThemesJson = prefs.getStringList(_keyCustomThemes) ?? [];
    _customThemes = customThemesJson
        .map((json) => CustomTheme.fromJson(jsonDecode(json)))
        .toList();
    
    // Load auto-switch settings
    _autoSwitchEnabled = prefs.getBool(_keyAutoSwitch) ?? false;
    _lightThemeStartHour = prefs.getInt(_keyLightThemeStart) ?? 6;
    _lightThemeEndHour = prefs.getInt(_keyLightThemeEnd) ?? 18;
    
    final lightThemeIndex = prefs.getInt(_keyLightThemeMode) ?? AppThemeMode.bright.index;
    _lightThemeMode = AppThemeMode.values[lightThemeIndex];
    
    final darkThemeIndex = prefs.getInt(_keyDarkThemeMode) ?? AppThemeMode.dark.index;
    _darkThemeMode = AppThemeMode.values[darkThemeIndex];
    
    notifyListeners();
  }

  /// Save custom themes to storage
  Future<void> _saveCustomThemes() async {
    final prefs = await SharedPreferences.getInstance();
    final themesJson = _customThemes
        .map((theme) => jsonEncode(theme.toJson()))
        .toList();
    await prefs.setStringList(_keyCustomThemes, themesJson);
  }

  /// Add a custom theme
  Future<void> addCustomTheme(CustomTheme theme) async {
    _customThemes.add(theme);
    await _saveCustomThemes();
    notifyListeners();
  }

  /// Update a custom theme
  Future<void> updateCustomTheme(String id, CustomTheme updatedTheme) async {
    final index = _customThemes.indexWhere((t) => t.id == id);
    if (index != -1) {
      _customThemes[index] = updatedTheme;
      await _saveCustomThemes();
      notifyListeners();
    }
  }

  /// Delete a custom theme
  Future<void> deleteCustomTheme(String id) async {
    _customThemes.removeWhere((t) => t.id == id);
    await _saveCustomThemes();
    notifyListeners();
  }

  /// Get a custom theme by ID
  CustomTheme? getCustomTheme(String id) {
    try {
      return _customThemes.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Set auto-switch enabled
  Future<void> setAutoSwitchEnabled(bool enabled) async {
    _autoSwitchEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoSwitch, enabled);
    notifyListeners();
  }

  /// Set light theme time range
  Future<void> setLightThemeHours(int startHour, int endHour) async {
    _lightThemeStartHour = startHour.clamp(0, 23);
    _lightThemeEndHour = endHour.clamp(0, 23);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLightThemeStart, _lightThemeStartHour);
    await prefs.setInt(_keyLightThemeEnd, _lightThemeEndHour);
    notifyListeners();
  }

  /// Set theme modes for auto-switch
  Future<void> setAutoSwitchThemes(AppThemeMode lightMode, AppThemeMode darkMode) async {
    _lightThemeMode = lightMode;
    _darkThemeMode = darkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLightThemeMode, lightMode.index);
    await prefs.setInt(_keyDarkThemeMode, darkMode.index);
    notifyListeners();
  }

  /// Get the appropriate theme based on current time
  AppThemeMode getAutoTheme() {
    if (!_autoSwitchEnabled) {
      return _lightThemeMode; // Default
    }

    final now = DateTime.now();
    final currentHour = now.hour;

    // Check if current time is within light theme hours
    if (_lightThemeStartHour < _lightThemeEndHour) {
      // Normal case: e.g., 6 AM to 6 PM
      if (currentHour >= _lightThemeStartHour && currentHour < _lightThemeEndHour) {
        return _lightThemeMode;
      } else {
        return _darkThemeMode;
      }
    } else {
      // Wrap-around case: e.g., 8 PM to 6 AM (next day)
      if (currentHour >= _lightThemeStartHour || currentHour < _lightThemeEndHour) {
        return _lightThemeMode;
      } else {
        return _darkThemeMode;
      }
    }
  }

  /// Export a custom theme as JSON string
  String exportTheme(String id) {
    final theme = getCustomTheme(id);
    if (theme == null) {
      throw Exception('Theme not found');
    }
    return theme.exportAsJson();
  }

  /// Import a custom theme from JSON string
  Future<void> importTheme(String jsonString) async {
    try {
      final theme = CustomTheme.importFromJson(jsonString);
      await addCustomTheme(theme);
    } catch (e) {
      throw Exception('Failed to import theme: $e');
    }
  }

  /// Get all available themes (built-in + custom)
  int getTotalThemeCount() {
    return AppThemeMode.values.length + _customThemes.length;
  }

  /// Check if a theme name already exists
  bool themeNameExists(String name) {
    return _customThemes.any((t) => t.name.toLowerCase() == name.toLowerCase());
  }
}
