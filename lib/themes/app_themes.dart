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

/// Tema Alto Contraste - Accesibilidad máxima
class HighContrastTheme {
  static final ThemeData theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Colores principales - Alto contraste
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0000FF), // Azul puro
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE0E0FF),
      onPrimaryContainer: Color(0xFF000000),

      secondary: Color(0xFF008000), // Verde oscuro puro
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFE0FFE0),
      onSecondaryContainer: Color(0xFF000000),

      tertiary: Color(0xFF800080), // Púrpura oscuro
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFFFE0FF),
      onTertiaryContainer: Color(0xFF000000),

      error: Color(0xFFB00020),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),

      background: Colors.white,
      onBackground: Colors.black,

      surface: Colors.white,
      onSurface: Colors.black,
      surfaceVariant: Color(0xFFE0E0E0),
      onSurfaceVariant: Colors.black,

      outline: Colors.black,
      outlineVariant: Color(0xFF404040),

      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Colors.black,
      onInverseSurface: Colors.white,
      inversePrimary: Color(0xFF8080FF),
    ),

    // Tarjetas con bordes definidos
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.black, width: 2),
      ),
      color: Colors.white,
    ),

    // AppBar alto contraste
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      iconTheme: IconThemeData(color: Colors.black, size: 28),
      actionsIconTheme: IconThemeData(color: Colors.black, size: 28),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      shape: Border(bottom: BorderSide(color: Colors.black, width: 2)),
    ),

    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF0000FF),
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: Colors.black, width: 2),
      ),
    ),

    // Botones
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      floatingLabelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF0000FF), width: 3),
      ),
    ),
    
    // Iconos más grandes y claros
    iconTheme: const IconThemeData(
      color: Colors.black,
      size: 28,
    ),
  );
}

/// Tema Ocean - Tonos azules del océano
class OceanTheme {
  static final ThemeData theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0077BE), // Azul océano
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFD0E8F2),
      onPrimaryContainer: Color(0xFF001F2A),

      secondary: Color(0xFF4A90A4), // Azul turquesa
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFD7EEF4),
      onSecondaryContainer: Color(0xFF002733),

      tertiary: Color(0xFF00C9A7), // Verde agua
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFC2F5E9),
      onTertiaryContainer: Color(0xFF003828),

      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),

      background: Color(0xFFF5FAFE),
      onBackground: Color(0xFF1A1C1E),

      surface: Color(0xFFF5FAFE),
      onSurface: Color(0xFF1A1C1E),
      surfaceVariant: Color(0xFFDDE3EA),
      onSurfaceVariant: Color(0xFF41484D),

      outline: Color(0xFF71787E),
      outlineVariant: Color(0xFFC1C7CE),

      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFF2F3133),
      onInverseSurface: Color(0xFFF1F0F4),
      inversePrimary: Color(0xFF90CEF4),
    ),

    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
    ),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Color(0xFF0077BE),
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF00C9A7),
      foregroundColor: Colors.white,
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
      fillColor: const Color(0xFFDDE3EA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0077BE), width: 2),
      ),
    ),
  );
}

/// Tema Forest - Tonos verdes del bosque
class ForestTheme {
  static final ThemeData theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2D6A4F), // Verde bosque
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFD8F3DC),
      onPrimaryContainer: Color(0xFF0A2E1A),

      secondary: Color(0xFF52B788), // Verde claro
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFD8F3DC),
      onSecondaryContainer: Color(0xFF0F3D23),

      tertiary: Color(0xFF95D5B2), // Verde menta
      onTertiary: Color(0xFF1B4332),
      tertiaryContainer: Color(0xFFE8F5E9),
      onTertiaryContainer: Color(0xFF0A2E1A),

      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),

      background: Color(0xFFF8FBF8),
      onBackground: Color(0xFF1A1C1A),

      surface: Color(0xFFF8FBF8),
      onSurface: Color(0xFF1A1C1A),
      surfaceVariant: Color(0xFFDEE5DC),
      onSurfaceVariant: Color(0xFF424940),

      outline: Color(0xFF727970),
      outlineVariant: Color(0xFFC2C9C0),

      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFF2F312E),
      onInverseSurface: Color(0xFFF1F1EC),
      inversePrimary: Color(0xFFB7D1C1),
    ),

    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
    ),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Color(0xFF2D6A4F),
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF52B788),
      foregroundColor: Colors.white,
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
      fillColor: const Color(0xFFDEE5DC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2D6A4F), width: 2),
      ),
    ),
  );
}

/// Tema Sunset - Tonos cálidos de atardecer
class SunsetTheme {
  static final ThemeData theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: const ColorScheme.light(
      primary: Color(0xFFFF6B6B), // Coral
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFFFE5E5),
      onPrimaryContainer: Color(0xFF4A0000),

      secondary: Color(0xFFFFAA5A), // Naranja suave
      onSecondary: Color(0xFF4A2800),
      secondaryContainer: Color(0xFFFFEDD5),
      onSecondaryContainer: Color(0xFF2D1600),

      tertiary: Color(0xFFFFD93D), // Amarillo dorado
      onTertiary: Color(0xFF3D2E00),
      tertiaryContainer: Color(0xFFFFF8E1),
      onTertiaryContainer: Color(0xFF2A1F00),

      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),

      background: Color(0xFFFFFBF5),
      onBackground: Color(0xFF1C1B1A),

      surface: Color(0xFFFFFBF5),
      onSurface: Color(0xFF1C1B1A),
      surfaceVariant: Color(0xFFFAEBDD),
      onSurfaceVariant: Color(0xFF4F4539),

      outline: Color(0xFF807567),
      outlineVariant: Color(0xFFD4C4B5),

      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFF31302F),
      onInverseSurface: Color(0xFFF4F0E9),
      inversePrimary: Color(0xFFFFB4AB),
    ),

    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
    ),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Color(0xFFFF6B6B),
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFFFD93D),
      foregroundColor: Color(0xFF3D2E00),
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
      fillColor: const Color(0xFFFAEBDD),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
      ),
    ),
  );
}

/// Tema Midnight - Azul oscuro profundo
class MidnightTheme {
  static final ThemeData theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF5E9FFF), // Azul brillante
      onPrimary: Color(0xFF003258),
      primaryContainer: Color(0xFF00497D),
      onPrimaryContainer: Color(0xFFD4E3FF),

      secondary: Color(0xFF8B7FFF), // Púrpura suave
      onSecondary: Color(0xFF2E2066),
      secondaryContainer: Color(0xFF45377D),
      onSecondaryContainer: Color(0xFFE5DEFF),

      tertiary: Color(0xFF00D9FF), // Cyan brillante
      onTertiary: Color(0xFF003640),
      tertiaryContainer: Color(0xFF004F5C),
      onTertiaryContainer: Color(0xFFB8EEFF),

      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),

      background: Color(0xFF0A1929), // Azul muy oscuro
      onBackground: Color(0xFFE3E8EF),

      surface: Color(0xFF132F4C), // Azul oscuro
      onSurface: Color(0xFFE3E8EF),
      surfaceVariant: Color(0xFF1E3A52),
      onSurfaceVariant: Color(0xFFC1D0E0),

      outline: Color(0xFF8B9AAA),
      outlineVariant: Color(0xFF3E5060),

      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFFE3E8EF),
      onInverseSurface: Color(0xFF0A1929),
      inversePrimary: Color(0xFF00497D),
    ),

    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF132F4C),
    ),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Color(0xFF0A1929),
      foregroundColor: Color(0xFF5E9FFF),
      titleTextStyle: TextStyle(
        color: Color(0xFF5E9FFF),
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF00D9FF),
      foregroundColor: Color(0xFF003640),
      elevation: 6,
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
      fillColor: const Color(0xFF1E3A52),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF5E9FFF), width: 2),
      ),
    ),
  );
}

/// Tema Monochrome - Escala de grises elegante
class MonochromeTheme {
  static final ThemeData theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2C2C2C), // Gris oscuro
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE0E0E0),
      onPrimaryContainer: Color(0xFF1A1A1A),

      secondary: Color(0xFF5A5A5A), // Gris medio
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFEEEEEE),
      onSecondaryContainer: Color(0xFF2C2C2C),

      tertiary: Color(0xFF757575), // Gris claro
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFF5F5F5),
      onTertiaryContainer: Color(0xFF3C3C3C),

      error: Color(0xFF5A5A5A),
      onError: Colors.white,
      errorContainer: Color(0xFFE0E0E0),
      onErrorContainer: Color(0xFF1A1A1A),

      background: Color(0xFFFAFAFA),
      onBackground: Color(0xFF1A1A1A),

      surface: Color(0xFFFAFAFA),
      onSurface: Color(0xFF1A1A1A),
      surfaceVariant: Color(0xFFEEEEEE),
      onSurfaceVariant: Color(0xFF424242),

      outline: Color(0xFF757575),
      outlineVariant: Color(0xFFC2C2C2),

      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFF313131),
      onInverseSurface: Color(0xFFF5F5F5),
      inversePrimary: Color(0xFFB8B8B8),
    ),

    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
    ),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Color(0xFF2C2C2C),
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF5A5A5A),
      foregroundColor: Colors.white,
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
      fillColor: const Color(0xFFEEEEEE),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2C2C2C), width: 2),
      ),
    ),
  );
}

/// Tema Neon - Colores vibrantes y neón
class NeonTheme {
  static final ThemeData theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFF00FF), // Magenta neón
      onPrimary: Colors.black,
      primaryContainer: Color(0xFF8B008B),
      onPrimaryContainer: Color(0xFFFFD6FF),

      secondary: Color(0xFF00FFFF), // Cyan neón
      onSecondary: Colors.black,
      secondaryContainer: Color(0xFF008B8B),
      onSecondaryContainer: Color(0xFFD6FFFF),

      tertiary: Color(0xFFFFFF00), // Amarillo neón
      onTertiary: Colors.black,
      tertiaryContainer: Color(0xFF8B8B00),
      onTertiaryContainer: Color(0xFFFFFFC0),

      error: Color(0xFFFF0080),
      onError: Colors.black,
      errorContainer: Color(0xFF8B0040),
      onErrorContainer: Color(0xFFFFD6E8),

      background: Color(0xFF0D0D0D), // Negro profundo
      onBackground: Color(0xFFFFFFFF),

      surface: Color(0xFF1A1A1A), // Gris muy oscuro
      onSurface: Color(0xFFFFFFFF),
      surfaceVariant: Color(0xFF2A2A2A),
      onSurfaceVariant: Color(0xFFE0E0E0),

      outline: Color(0xFFFF00FF),
      outlineVariant: Color(0xFF4D004D),

      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFFFFFFFF),
      onInverseSurface: Color(0xFF0D0D0D),
      inversePrimary: Color(0xFF8B008B),
    ),

    cardTheme: CardTheme(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFFF00FF), width: 1),
      ),
      color: const Color(0xFF1A1A1A),
    ),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Color(0xFF0D0D0D),
      foregroundColor: Color(0xFFFF00FF),
      titleTextStyle: TextStyle(
        color: Color(0xFFFF00FF),
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFFFFF00),
      foregroundColor: Colors.black,
      elevation: 8,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF00FF), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF00FF), width: 2),
      ),
    ),
  );
}

/// Tema Colorblind - Diseñado para personas con daltonismo
/// Usa patrones, bordes gruesos y alto contraste además de colores
class ColorblindTheme {
  static final ThemeData theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: const ColorScheme.light(
      // Usamos colores que son distinguibles para la mayoría de tipos de daltonismo
      primary: Color(0xFF0051A5), // Azul oscuro (distinguible)
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFD4E3FF),
      onPrimaryContainer: Color(0xFF001C3A),

      secondary: Color(0xFFFFB000), // Naranja/Amarillo (distinguible del azul)
      onSecondary: Colors.black,
      secondaryContainer: Color(0xFFFFE8C5),
      onSecondaryContainer: Color(0xFF3D2E00),

      tertiary: Color(0xFF6B4C9A), // Púrpura (distinguible)
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFEBDCFF),
      onTertiaryContainer: Color(0xFF23005C),

      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),

      background: Colors.white,
      onBackground: Colors.black,

      surface: Colors.white,
      onSurface: Colors.black,
      surfaceVariant: Color(0xFFE1E2EC),
      onSurfaceVariant: Color(0xFF44474F),

      outline: Colors.black,
      outlineVariant: Color(0xFF74777F),

      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFF2F3033),
      onInverseSurface: Color(0xFFF1F0F4),
      inversePrimary: Color(0xFFA6C8FF),
    ),

    // Tarjetas con bordes gruesos y distintivos
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black, width: 3),
      ),
      color: Colors.white,
    ),

    // AppBar con borde inferior grueso
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Color(0xFF0051A5),
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white, size: 28),
      actionsIconTheme: IconThemeData(color: Colors.white, size: 28),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      shape: Border(bottom: BorderSide(color: Colors.black, width: 3)),
    ),

    // Floating Action Button con borde grueso
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFFFB000),
      foregroundColor: Colors.black,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: Colors.black, width: 3),
      ),
    ),

    // Botones con bordes gruesos
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Color(0xFF0051A5),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    // Input decoration con bordes gruesos
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      floatingLabelStyle: const TextStyle(color: Color(0xFF0051A5), fontWeight: FontWeight.bold),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black, width: 3),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black, width: 3),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF0051A5), width: 4),
      ),
    ),
    
    // Iconos más grandes y claros
    iconTheme: const IconThemeData(
      color: Colors.black,
      size: 28,
    ),
  );
}

/// Enumeración para los modos de tema
enum AppThemeMode {
  bright, // Tema claro y alegre
  chill, // Tema suave y relajante
  dark, // Tema oscuro
  highContrast, // Tema alto contraste
  ocean, // Tema océano
  forest, // Tema bosque
  sunset, // Tema atardecer
  midnight, // Tema medianoche
  monochrome, // Tema monocromático
  neon, // Tema neón
  colorblind, // Tema para daltonismo
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
      case AppThemeMode.highContrast:
        return HighContrastTheme.theme;
      case AppThemeMode.ocean:
        return OceanTheme.theme;
      case AppThemeMode.forest:
        return ForestTheme.theme;
      case AppThemeMode.sunset:
        return SunsetTheme.theme;
      case AppThemeMode.midnight:
        return MidnightTheme.theme;
      case AppThemeMode.monochrome:
        return MonochromeTheme.theme;
      case AppThemeMode.neon:
        return NeonTheme.theme;
      case AppThemeMode.colorblind:
        return ColorblindTheme.theme;
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
      case AppThemeMode.highContrast:
        return 'Alto Contraste';
      case AppThemeMode.ocean:
        return 'Océano';
      case AppThemeMode.forest:
        return 'Bosque';
      case AppThemeMode.sunset:
        return 'Atardecer';
      case AppThemeMode.midnight:
        return 'Medianoche';
      case AppThemeMode.monochrome:
        return 'Monocromo';
      case AppThemeMode.neon:
        return 'Neón';
      case AppThemeMode.colorblind:
        return 'Daltónico';
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
      case AppThemeMode.highContrast:
        return Icons.contrast;
      case AppThemeMode.ocean:
        return Icons.water;
      case AppThemeMode.forest:
        return Icons.park;
      case AppThemeMode.sunset:
        return Icons.wb_twilight;
      case AppThemeMode.midnight:
        return Icons.dark_mode;
      case AppThemeMode.monochrome:
        return Icons.gradient;
      case AppThemeMode.neon:
        return Icons.flash_on;
      case AppThemeMode.colorblind:
        return Icons.accessibility_new;
    }
  }
}
