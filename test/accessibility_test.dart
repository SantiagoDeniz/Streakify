import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streakify/services/accessibility_service.dart';
import 'package:streakify/themes/app_themes.dart';

void main() {
  group('AccessibilityService Tests', () {
    test('Should initialize with default values', () async {
      SharedPreferences.setMockInitialValues({});
      final service = AccessibilityService();
      await service.init();

      expect(service.reduceMotion, false);
      expect(service.textScaleFactor, 1.0);
    });

    test('Should load saved values', () async {
      SharedPreferences.setMockInitialValues({
        'reduceMotion': true,
        'textScaleFactor': 1.5,
      });
      final service = AccessibilityService();
      await service.init();

      expect(service.reduceMotion, true);
      expect(service.textScaleFactor, 1.5);
    });

    test('Should update values', () async {
      SharedPreferences.setMockInitialValues({});
      final service = AccessibilityService();
      await service.init();

      await service.setReduceMotion(true);
      expect(service.reduceMotion, true);

      await service.setTextScaleFactor(1.2);
      expect(service.textScaleFactor, 1.2);
    });
  });

  group('HighContrastTheme Tests', () {
    test('Should have high contrast colors', () {
      final theme = HighContrastTheme.theme;
      expect(theme.colorScheme.primary, const Color(0xFF0000FF));
      expect(theme.colorScheme.onPrimary, Colors.white);
      expect(theme.colorScheme.background, Colors.white);
      expect(theme.colorScheme.onBackground, Colors.black);
    });

    test('AppThemes should return HighContrastTheme', () {
      final theme = AppThemes.getTheme(AppThemeMode.highContrast);
      expect(theme.colorScheme.primary, const Color(0xFF0000FF));
    });

    test('AppThemes should return correct name and icon', () {
      expect(AppThemes.getThemeName(AppThemeMode.highContrast), 'Alto Contraste');
      expect(AppThemes.getThemeIcon(AppThemeMode.highContrast), Icons.contrast);
    });
  });
}
