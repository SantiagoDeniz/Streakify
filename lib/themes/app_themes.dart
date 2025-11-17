import 'package:flutter/material.dart';

/// Tema Claro - Colores alegres y motivadores
class BrightTheme {
  static final ThemeData theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Colores principales
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFFF6B35), // Naranja vibrante
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFFFDAD1),
      onPrimaryContainer: Color(0xFF410002),

      secondary: Color(0xFFFFC857), // Amarillo energético
      onSecondary: Color(0xFF3D2E00),
      secondaryContainer: Color(0xFFFFEDB3),
      onSecondaryContainer: Color(0xFF2A1F00),

      tertiary: Color(0xFF06D6A0), // Verde éxito
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFC7F9E3),
      onTertiaryContainer: Color(0xFF003825),

      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),

      background: Color(0xFFFFFBFF), // Blanco cálido
      onBackground: Color(0xFF201A19),

      surface: Color(0xFFFFFBFF),
      onSurface: Color(0xFF201A19),
      surfaceVariant: Color(0xFFF5DDDA),
      onSurfaceVariant: Color(0xFF534341),

      outline: Color(0xFF857371),
      outlineVariant: Color(0xFFD8C2BE),

      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF362F2E),
      onInverseSurface: Color(0xFFFBEEEC),
      inversePrimary: Color(0xFFFFB4A0),
    ),

    // Tarjetas con sombra suave
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.1),
    ),

    // AppBar con gradiente sutil
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Color(0xFFFF6B35),
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),

    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF06D6A0),
      foregroundColor: Colors.white,
      elevation: 4,
    ),

    // Botones
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5DDDA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 2),
      ),
    ),
  );
}

/// Tema Chill - Colores suaves y pasteles
class ChillTheme {
  static final ThemeData theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Colores principales
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFB8A9C9), // Lavanda suave
      onPrimary: Color(0xFF2D1F3D),
      primaryContainer: Color(0xFFE8DFF5),
      onPrimaryContainer: Color(0xFF1A0E2E),

      secondary: Color(0xFFC7CEEA), // Menta pastel
      onSecondary: Color(0xFF1F2D47),
      secondaryContainer: Color(0xFFE3E9FF),
      onSecondaryContainer: Color(0xFF0F1A33),

      tertiary: Color(0xFFFFDAC1), // Rosa empolvado
      onTertiary: Color(0xFF4A2800),
      tertiaryContainer: Color(0xFFFFEFE0),
      onTertiaryContainer: Color(0xFF2D1600),

      error: Color(0xFFD9A5A5),
      onError: Color(0xFF5C2020),
      errorContainer: Color(0xFFF8E5E5),
      onErrorContainer: Color(0xFF3D1414),

      background: Color(0xFFFAF8FC), // Blanco lavanda muy suave
      onBackground: Color(0xFF2C2831),

      surface: Color(0xFFFAF8FC),
      onSurface: Color(0xFF2C2831),
      surfaceVariant: Color(0xFFEFE8F3),
      onSurfaceVariant: Color(0xFF4A4458),

      outline: Color(0xFF7B7485),
      outlineVariant: Color(0xFFD3CAD9),

      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF413D47),
      onInverseSurface: Color(0xFFF4F0F5),
      inversePrimary: Color(0xFFD4C4E3),
    ),

    // Tarjetas con bordes redondeados
    cardTheme: CardTheme(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: const Color(0xFFFFFFFF),
      shadowColor: const Color(0xFFB8A9C9).withOpacity(0.15),
    ),

    // AppBar suave
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Color(0xFFB8A9C9),
      foregroundColor: Color(0xFF2D1F3D),
      titleTextStyle: TextStyle(
        color: Color(0xFF2D1F3D),
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFFFDAC1),
      foregroundColor: Color(0xFF4A2800),
      elevation: 3,
    ),

    // Botones
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 1,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),

    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFEFE8F3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFB8A9C9), width: 2),
      ),
    ),
  );
}

/// Tema Oscuro - Elegante con acentos brillantes
class DarkTheme {
  static final ThemeData theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Colores principales
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF00B4D8), // Azul eléctrico
      onPrimary: Color(0xFF003544),
      primaryContainer: Color(0xFF004D61),
      onPrimaryContainer: Color(0xFFB8E8F5),

      secondary: Color(0xFF7209B7), // Púrpura vibrante
      onSecondary: Color(0xFF3D0066),
      secondaryContainer: Color(0xFF560085),
      onSecondaryContainer: Color(0xFFEAD1FF),

      tertiary: Color(0xFF06FFA5), // Turquesa brillante
      onTertiary: Color(0xFF003828),
      tertiaryContainer: Color(0xFF00513A),
      onTertiaryContainer: Color(0xFFB0FFC8),

      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),

      background: Color(0xFF121212), // Negro suave
      onBackground: Color(0xFFE6E1E5),

      surface: Color(0xFF1E1E1E), // Gris oscuro
      onSurface: Color(0xFFE6E1E5),
      surfaceVariant: Color(0xFF2A2A2A),
      onSurfaceVariant: Color(0xFFCAC4D0),

      outline: Color(0xFF938F99),
      outlineVariant: Color(0xFF49454F),

      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFE6E1E5),
      onInverseSurface: Color(0xFF313033),
      inversePrimary: Color(0xFF006780),
    ),

    // Tarjetas con elevación sutil
    cardTheme: CardTheme(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF2A2A2A),
      shadowColor: Colors.black.withOpacity(0.5),
    ),

    // AppBar oscura con acento
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Color(0xFF00B4D8),
      titleTextStyle: TextStyle(
        color: Color(0xFF00B4D8),
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),

    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF06FFA5),
      foregroundColor: Color(0xFF003828),
      elevation: 6,
    ),

    // Botones
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00B4D8), width: 2),
      ),
    ),
  );
}

/// Enumeración para los modos de tema
enum AppThemeMode {
  bright, // Tema claro y alegre
  chill, // Tema suave y relajante
  dark, // Tema oscuro
}

/// Clase helper para obtener el tema según el modo
class AppThemes {
  static ThemeData getTheme(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.bright:
        return BrightTheme.theme;
      case AppThemeMode.chill:
        return ChillTheme.theme;
      case AppThemeMode.dark:
        return DarkTheme.theme;
    }
  }

  static String getThemeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.bright:
        return 'Alegre';
      case AppThemeMode.chill:
        return 'Chill';
      case AppThemeMode.dark:
        return 'Oscuro';
    }
  }

  static IconData getThemeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.bright:
        return Icons.wb_sunny;
      case AppThemeMode.chill:
        return Icons.spa;
      case AppThemeMode.dark:
        return Icons.nights_stay;
    }
  }
}
