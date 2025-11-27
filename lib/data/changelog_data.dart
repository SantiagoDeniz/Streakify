import '../models/changelog_entry.dart';

/// Changelog data for version history
final List<ChangelogEntry> changelogData = [
  ChangelogEntry(
    version: '1.0.0',
    date: DateTime(2024, 11, 27),
    features: [
      'Lanzamiento inicial de Streakify',
      'Sistema de rachas para seguimiento de hábitos',
      'Widgets para pantalla de inicio',
      'Estadísticas y gráficas detalladas',
      'Sistema de logros y gamificación',
      'Notificaciones inteligentes',
      'Múltiples temas visuales',
      'Backup y exportación de datos',
    ],
    improvements: [
      'Interfaz optimizada para tablets',
      'Soporte completo de accesibilidad',
      'Rendimiento mejorado con lazy loading',
    ],
    bugFixes: [],
  ),
  
  ChangelogEntry(
    version: '0.9.0',
    date: DateTime(2024, 11, 20),
    features: [
      'Sistema de monetización con modelo freemium',
      'Suscripción Premium con características exclusivas',
      'Sistema de donaciones',
      'Centro de ayuda integrado',
      'Tutorial interactivo para nuevos usuarios',
    ],
    improvements: [
      'Mejoras en el sistema de notificaciones',
      'Optimización de la base de datos',
      'Interfaz de usuario refinada',
    ],
    bugFixes: [
      'Corregido problema con rachas en cambio de zona horaria',
      'Solucionado crash al exportar datos grandes',
      'Arreglado error en widget de calendario',
    ],
  ),
  
  ChangelogEntry(
    version: '0.8.0',
    date: DateTime(2024, 11, 10),
    features: [
      'Tema daltónico para mejor accesibilidad',
      'Modo de alto contraste',
      'Soporte para lectores de pantalla',
      'Navegación por teclado en tablet/desktop',
    ],
    improvements: [
      'Tamaños de toque aumentados para mejor usabilidad',
      'Reducción de movimiento respetando preferencias del sistema',
      'Mejoras en la configuración de accesibilidad',
    ],
    bugFixes: [
      'Corregidos problemas de contraste en tema oscuro',
      'Solucionados errores de semantics en algunos widgets',
    ],
  ),
  
  ChangelogEntry(
    version: '0.7.0',
    date: DateTime(2024, 11, 1),
    features: [
      'Características sociales: compartir logros',
      'Grupos de accountability',
      'Tabla de líderes',
      'Sistema de buddies',
    ],
    improvements: [
      'Mejoras en el sistema de notificaciones',
      'Optimización del rendimiento general',
    ],
    bugFixes: [
      'Corregido error al compartir en redes sociales',
      'Solucionado problema de sincronización',
    ],
  ),
];

/// Get latest changelog entry
ChangelogEntry? getLatestChangelog() {
  if (changelogData.isEmpty) return null;
  return changelogData.first;
}

/// Get changelog for specific version
ChangelogEntry? getChangelogForVersion(String version) {
  try {
    return changelogData.firstWhere((entry) => entry.version == version);
  } catch (e) {
    return null;
  }
}
