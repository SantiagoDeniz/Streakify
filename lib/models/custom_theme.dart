import 'dart:convert';
import 'package:flutter/material.dart';

/// Represents a custom user-created theme
class CustomTheme {
  final String id;
  final String name;
  final String? description;
  final bool isDark;
  
  // Primary colors
  final Color primaryColor;
  final Color onPrimaryColor;
  final Color primaryContainerColor;
  final Color onPrimaryContainerColor;
  
  // Secondary colors
  final Color secondaryColor;
  final Color onSecondaryColor;
  final Color secondaryContainerColor;
  final Color onSecondaryContainerColor;
  
  // Tertiary colors
  final Color tertiaryColor;
  final Color onTertiaryColor;
  final Color tertiaryContainerColor;
  final Color onTertiaryContainerColor;
  
  // Surface colors
  final Color backgroundColor;
  final Color onBackgroundColor;
  final Color surfaceColor;
  final Color onSurfaceColor;
  
  // Error colors
  final Color errorColor;
  final Color onErrorColor;
  
  final DateTime createdAt;
  final DateTime? modifiedAt;

  CustomTheme({
    required this.id,
    required this.name,
    this.description,
    required this.isDark,
    required this.primaryColor,
    required this.onPrimaryColor,
    required this.primaryContainerColor,
    required this.onPrimaryContainerColor,
    required this.secondaryColor,
    required this.onSecondaryColor,
    required this.secondaryContainerColor,
    required this.onSecondaryContainerColor,
    required this.tertiaryColor,
    required this.onTertiaryColor,
    required this.tertiaryContainerColor,
    required this.onTertiaryContainerColor,
    required this.backgroundColor,
    required this.onBackgroundColor,
    required this.surfaceColor,
    required this.onSurfaceColor,
    required this.errorColor,
    required this.onErrorColor,
    required this.createdAt,
    this.modifiedAt,
  });

  /// Convert to ThemeData
  ThemeData toThemeData() {
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: primaryColor,
        onPrimary: onPrimaryColor,
        primaryContainer: primaryContainerColor,
        onPrimaryContainer: onPrimaryContainerColor,
        secondary: secondaryColor,
        onSecondary: onSecondaryColor,
        secondaryContainer: secondaryContainerColor,
        onSecondaryContainer: onSecondaryContainerColor,
        tertiary: tertiaryColor,
        onTertiary: onTertiaryColor,
        tertiaryContainer: tertiaryContainerColor,
        onTertiaryContainer: onTertiaryContainerColor,
        error: errorColor,
        onError: onErrorColor,
        errorContainer: isDark ? const Color(0xFF93000A) : const Color(0xFFFFDAD6),
        onErrorContainer: isDark ? const Color(0xFFFFDAD6) : const Color(0xFF410002),
        background: backgroundColor,
        onBackground: onBackgroundColor,
        surface: surfaceColor,
        onSurface: onSurfaceColor,
        surfaceVariant: isDark 
            ? Color.alphaBlend(primaryColor.withOpacity(0.1), surfaceColor)
            : Color.alphaBlend(primaryColor.withOpacity(0.05), surfaceColor),
        onSurfaceVariant: onSurfaceColor.withOpacity(0.7),
        outline: onSurfaceColor.withOpacity(0.5),
        outlineVariant: onSurfaceColor.withOpacity(0.2),
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: onSurfaceColor,
        onInverseSurface: surfaceColor,
        inversePrimary: primaryColor.withOpacity(0.7),
      ),
      cardTheme: CardTheme(
        elevation: isDark ? 3 : 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: surfaceColor,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: surfaceColor,
        foregroundColor: primaryColor,
        titleTextStyle: TextStyle(
          color: primaryColor,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: tertiaryColor,
        foregroundColor: onTertiaryColor,
        elevation: 4,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark 
            ? Color.alphaBlend(primaryColor.withOpacity(0.1), surfaceColor)
            : Color.alphaBlend(primaryColor.withOpacity(0.05), surfaceColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isDark': isDark,
      'primaryColor': primaryColor.value,
      'onPrimaryColor': onPrimaryColor.value,
      'primaryContainerColor': primaryContainerColor.value,
      'onPrimaryContainerColor': onPrimaryContainerColor.value,
      'secondaryColor': secondaryColor.value,
      'onSecondaryColor': onSecondaryColor.value,
      'secondaryContainerColor': secondaryContainerColor.value,
      'onSecondaryContainerColor': onSecondaryContainerColor.value,
      'tertiaryColor': tertiaryColor.value,
      'onTertiaryColor': onTertiaryColor.value,
      'tertiaryContainerColor': tertiaryContainerColor.value,
      'onTertiaryContainerColor': onTertiaryContainerColor.value,
      'backgroundColor': backgroundColor.value,
      'onBackgroundColor': onBackgroundColor.value,
      'surfaceColor': surfaceColor.value,
      'onSurfaceColor': onSurfaceColor.value,
      'errorColor': errorColor.value,
      'onErrorColor': onErrorColor.value,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory CustomTheme.fromJson(Map<String, dynamic> json) {
    return CustomTheme(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      isDark: json['isDark'] as bool,
      primaryColor: Color(json['primaryColor'] as int),
      onPrimaryColor: Color(json['onPrimaryColor'] as int),
      primaryContainerColor: Color(json['primaryContainerColor'] as int),
      onPrimaryContainerColor: Color(json['onPrimaryContainerColor'] as int),
      secondaryColor: Color(json['secondaryColor'] as int),
      onSecondaryColor: Color(json['onSecondaryColor'] as int),
      secondaryContainerColor: Color(json['secondaryContainerColor'] as int),
      onSecondaryContainerColor: Color(json['onSecondaryContainerColor'] as int),
      tertiaryColor: Color(json['tertiaryColor'] as int),
      onTertiaryColor: Color(json['onTertiaryColor'] as int),
      tertiaryContainerColor: Color(json['tertiaryContainerColor'] as int),
      onTertiaryContainerColor: Color(json['onTertiaryContainerColor'] as int),
      backgroundColor: Color(json['backgroundColor'] as int),
      onBackgroundColor: Color(json['onBackgroundColor'] as int),
      surfaceColor: Color(json['surfaceColor'] as int),
      onSurfaceColor: Color(json['onSurfaceColor'] as int),
      errorColor: Color(json['errorColor'] as int),
      onErrorColor: Color(json['onErrorColor'] as int),
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: json['modifiedAt'] != null 
          ? DateTime.parse(json['modifiedAt'] as String) 
          : null,
    );
  }

  /// Export as JSON string
  String exportAsJson() {
    return jsonEncode(toJson());
  }

  /// Import from JSON string
  static CustomTheme importFromJson(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return CustomTheme.fromJson(json);
  }

  /// Create a copy with modifications
  CustomTheme copyWith({
    String? id,
    String? name,
    String? description,
    bool? isDark,
    Color? primaryColor,
    Color? onPrimaryColor,
    Color? primaryContainerColor,
    Color? onPrimaryContainerColor,
    Color? secondaryColor,
    Color? onSecondaryColor,
    Color? secondaryContainerColor,
    Color? onSecondaryContainerColor,
    Color? tertiaryColor,
    Color? onTertiaryColor,
    Color? tertiaryContainerColor,
    Color? onTertiaryContainerColor,
    Color? backgroundColor,
    Color? onBackgroundColor,
    Color? surfaceColor,
    Color? onSurfaceColor,
    Color? errorColor,
    Color? onErrorColor,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) {
    return CustomTheme(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isDark: isDark ?? this.isDark,
      primaryColor: primaryColor ?? this.primaryColor,
      onPrimaryColor: onPrimaryColor ?? this.onPrimaryColor,
      primaryContainerColor: primaryContainerColor ?? this.primaryContainerColor,
      onPrimaryContainerColor: onPrimaryContainerColor ?? this.onPrimaryContainerColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      onSecondaryColor: onSecondaryColor ?? this.onSecondaryColor,
      secondaryContainerColor: secondaryContainerColor ?? this.secondaryContainerColor,
      onSecondaryContainerColor: onSecondaryContainerColor ?? this.onSecondaryContainerColor,
      tertiaryColor: tertiaryColor ?? this.tertiaryColor,
      onTertiaryColor: onTertiaryColor ?? this.onTertiaryColor,
      tertiaryContainerColor: tertiaryContainerColor ?? this.tertiaryContainerColor,
      onTertiaryContainerColor: onTertiaryContainerColor ?? this.onTertiaryContainerColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      onBackgroundColor: onBackgroundColor ?? this.onBackgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      onSurfaceColor: onSurfaceColor ?? this.onSurfaceColor,
      errorColor: errorColor ?? this.errorColor,
      onErrorColor: onErrorColor ?? this.onErrorColor,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }
}
