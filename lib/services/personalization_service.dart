import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enumeration for information density
enum InformationDensity {
  compact,
  normal,
  spacious,
}

/// Enumeration for date formats
enum DateFormatType {
  ddMMyyyy, // 23/11/2025
  mmDDyyyy, // 11/23/2025
  yyyyMMdd, // 2025-11-23
  ddMMMMyyyy, // 23 November 2025
}

/// Service to manage personalization settings
class PersonalizationService extends ChangeNotifier {
  static const String _keyFontFamily = 'personalization_font_family';
  static const String _keyTextSizeMultiplier = 'personalization_text_size';
  static const String _keyDensity = 'personalization_density';
  static const String _keyLocale = 'personalization_locale';
  static const String _keyDateFormat = 'personalization_date_format';
  static const String _keyDayStartHour = 'personalization_day_start_hour';

  String _fontFamily = 'Roboto';
  double _textSizeMultiplier = 1.0;
  InformationDensity _density = InformationDensity.normal;
  String _localeCode = 'es'; // Default to Spanish
  DateFormatType _dateFormat = DateFormatType.ddMMyyyy;
  int _dayStartHour = 0; // Midnight by default

  // Getters
  String get fontFamily => _fontFamily;
  double get textSizeMultiplier => _textSizeMultiplier;
  InformationDensity get density => _density;
  String get localeCode => _localeCode;
  Locale get locale => Locale(_localeCode);
  DateFormatType get dateFormat => _dateFormat;
  int get dayStartHour => _dayStartHour;

  /// Initialize and load settings
  Future<void> init() async {
    await _loadSettings();
  }

  /// Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    _fontFamily = prefs.getString(_keyFontFamily) ?? 'Roboto';
    _textSizeMultiplier = prefs.getDouble(_keyTextSizeMultiplier) ?? 1.0;
    
    final densityIndex = prefs.getInt(_keyDensity) ?? InformationDensity.normal.index;
    _density = InformationDensity.values[densityIndex];
    
    _localeCode = prefs.getString(_keyLocale) ?? 'es';
    
    final dateFormatIndex = prefs.getInt(_keyDateFormat) ?? DateFormatType.ddMMyyyy.index;
    _dateFormat = DateFormatType.values[dateFormatIndex];
    
    _dayStartHour = prefs.getInt(_keyDayStartHour) ?? 0;
    
    notifyListeners();
  }

  /// Set font family
  Future<void> setFontFamily(String fontFamily) async {
    _fontFamily = fontFamily;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFontFamily, fontFamily);
    notifyListeners();
  }

  /// Set text size multiplier (0.8 to 1.5)
  Future<void> setTextSizeMultiplier(double multiplier) async {
    _textSizeMultiplier = multiplier.clamp(0.8, 1.5);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyTextSizeMultiplier, _textSizeMultiplier);
    notifyListeners();
  }

  /// Set information density
  Future<void> setDensity(InformationDensity density) async {
    _density = density;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDensity, density.index);
    notifyListeners();
  }

  /// Set locale
  Future<void> setLocale(String localeCode) async {
    _localeCode = localeCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, localeCode);
    notifyListeners();
  }

  /// Set date format
  Future<void> setDateFormat(DateFormatType format) async {
    _dateFormat = format;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDateFormat, format.index);
    notifyListeners();
  }

  /// Set day start hour (0-23)
  Future<void> setDayStartHour(int hour) async {
    _dayStartHour = hour.clamp(0, 23);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDayStartHour, _dayStartHour);
    notifyListeners();
  }

  /// Get padding based on density
  EdgeInsets getPadding({
    double compact = 8.0,
    double normal = 12.0,
    double spacious = 16.0,
  }) {
    switch (_density) {
      case InformationDensity.compact:
        return EdgeInsets.all(compact);
      case InformationDensity.normal:
        return EdgeInsets.all(normal);
      case InformationDensity.spacious:
        return EdgeInsets.all(spacious);
    }
  }

  /// Get spacing based on density
  double getSpacing({
    double compact = 8.0,
    double normal = 12.0,
    double spacious = 16.0,
  }) {
    switch (_density) {
      case InformationDensity.compact:
        return compact;
      case InformationDensity.normal:
        return normal;
      case InformationDensity.spacious:
        return spacious;
    }
  }

  /// Get card height based on density
  double getCardHeight({
    double compact = 80.0,
    double normal = 100.0,
    double spacious = 120.0,
  }) {
    switch (_density) {
      case InformationDensity.compact:
        return compact;
      case InformationDensity.normal:
        return normal;
      case InformationDensity.spacious:
        return spacious;
    }
  }

  /// Format date according to selected format
  String formatDate(DateTime date) {
    switch (_dateFormat) {
      case DateFormatType.ddMMyyyy:
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      case DateFormatType.mmDDyyyy:
        return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
      case DateFormatType.yyyyMMdd:
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      case DateFormatType.ddMMMMyyyy:
        final months = _localeCode == 'es'
            ? ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 
               'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre']
            : ['January', 'February', 'March', 'April', 'May', 'June',
               'July', 'August', 'September', 'October', 'November', 'December'];
        return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }

  /// Get the current "day" considering custom day start hour
  /// For example, if day starts at 4 AM, then 3 AM is still "yesterday"
  DateTime getCurrentDay() {
    final now = DateTime.now();
    if (now.hour < _dayStartHour) {
      // Still in "yesterday"
      return DateTime(now.year, now.month, now.day - 1);
    }
    return DateTime(now.year, now.month, now.day);
  }

  /// Check if a datetime is in the current day (considering custom day start)
  bool isInCurrentDay(DateTime dateTime) {
    final currentDay = getCurrentDay();
    final checkDay = dateTime.hour < _dayStartHour
        ? DateTime(dateTime.year, dateTime.month, dateTime.day - 1)
        : DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    return currentDay.year == checkDay.year &&
           currentDay.month == checkDay.month &&
           currentDay.day == checkDay.day;
  }

  /// Get density name for display
  String getDensityName(InformationDensity density) {
    switch (density) {
      case InformationDensity.compact:
        return _localeCode == 'es' ? 'Compacto' : 'Compact';
      case InformationDensity.normal:
        return _localeCode == 'es' ? 'Normal' : 'Normal';
      case InformationDensity.spacious:
        return _localeCode == 'es' ? 'Espacioso' : 'Spacious';
    }
  }

  /// Get date format name for display
  String getDateFormatName(DateFormatType format) {
    switch (format) {
      case DateFormatType.ddMMyyyy:
        return 'DD/MM/YYYY';
      case DateFormatType.mmDDyyyy:
        return 'MM/DD/YYYY';
      case DateFormatType.yyyyMMdd:
        return 'YYYY-MM-DD';
      case DateFormatType.ddMMMMyyyy:
        return _localeCode == 'es' ? 'DD Mes YYYY' : 'DD Month YYYY';
    }
  }

  /// Get available font families
  static List<String> getAvailableFonts() {
    return [
      'Roboto',
      'Open Sans',
      'Lato',
      'Montserrat',
      'Poppins',
      'Raleway',
      'Ubuntu',
      'Nunito',
    ];
  }
}
