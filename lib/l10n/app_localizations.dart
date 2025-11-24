/// Simple localization helper for Streakify
/// Supports Spanish (es) and English (en)
class AppLocalizations {
  final String localeCode;

  AppLocalizations(this.localeCode);

  static AppLocalizations of(String locale) {
    return AppLocalizations(locale);
  }

  // Common
  String get appName => 'Streakify';
  String get cancel => localeCode == 'es' ? 'Cancelar' : 'Cancel';
  String get save => localeCode == 'es' ? 'Guardar' : 'Save';
  String get delete => localeCode == 'es' ? 'Eliminar' : 'Delete';
  String get edit => localeCode == 'es' ? 'Editar' : 'Edit';
  String get apply => localeCode == 'es' ? 'Aplicar' : 'Apply';
  String get close => localeCode == 'es' ? 'Cerrar' : 'Close';
  String get create => localeCode == 'es' ? 'Crear' : 'Create';
  String get export => localeCode == 'es' ? 'Exportar' : 'Export';
  String get import => localeCode == 'es' ? 'Importar' : 'Import';
  
  // Personalization
  String get personalization => localeCode == 'es' ? 'Personalización' : 'Personalization';
  String get language => localeCode == 'es' ? 'Idioma' : 'Language';
  String get spanish => localeCode == 'es' ? 'Español' : 'Spanish';
  String get english => localeCode == 'es' ? 'Inglés' : 'English';
  String get font => localeCode == 'es' ? 'Fuente' : 'Font';
  String get textSize => localeCode == 'es' ? 'Tamaño de texto' : 'Text size';
  String get density => localeCode == 'es' ? 'Densidad' : 'Density';
  String get dateFormat => localeCode == 'es' ? 'Formato de fecha' : 'Date format';
  String get dayStartHour => localeCode == 'es' ? 'Hora de inicio del día' : 'Day start hour';
  
  // Themes
  String get themes => localeCode == 'es' ? 'Temas' : 'Themes';
  String get selectTheme => localeCode == 'es' ? 'Seleccionar tema' : 'Select theme';
  String get customThemes => localeCode == 'es' ? 'Temas personalizados' : 'Custom themes';
  String get createCustomTheme => localeCode == 'es' ? 'Crear tema personalizado' : 'Create custom theme';
  String get autoTheme => localeCode == 'es' ? 'Tema automático' : 'Auto theme';
  String get autoThemeDesc => localeCode == 'es' 
      ? 'Cambiar tema según la hora del día' 
      : 'Change theme based on time of day';
  String get lightTheme => localeCode == 'es' ? 'Tema claro' : 'Light theme';
  String get darkTheme => localeCode == 'es' ? 'Tema oscuro' : 'Dark theme';
  String get themeGallery => localeCode == 'es' ? 'Galería de temas' : 'Theme gallery';
  
  // Settings
  String get settings => localeCode == 'es' ? 'Configuración' : 'Settings';
  String get appearance => localeCode == 'es' ? 'Apariencia' : 'Appearance';
  String get advanced => localeCode == 'es' ? 'Avanzado' : 'Advanced';
  
  // Messages
  String get themeApplied => localeCode == 'es' ? 'Tema aplicado' : 'Theme applied';
  String get settingsSaved => localeCode == 'es' ? 'Configuración guardada' : 'Settings saved';
  String get themeCreated => localeCode == 'es' ? 'Tema creado' : 'Theme created';
  String get themeDeleted => localeCode == 'es' ? 'Tema eliminado' : 'Theme deleted';
  
  // Theme creator
  String get themeName => localeCode == 'es' ? 'Nombre del tema' : 'Theme name';
  String get themeDescription => localeCode == 'es' ? 'Descripción' : 'Description';
  String get darkMode => localeCode == 'es' ? 'Modo oscuro' : 'Dark mode';
  String get primaryColor => localeCode == 'es' ? 'Color primario' : 'Primary color';
  String get secondaryColor => localeCode == 'es' ? 'Color secundario' : 'Secondary color';
  String get tertiaryColor => localeCode == 'es' ? 'Color terciario' : 'Tertiary color';
  String get backgroundColor => localeCode == 'es' ? 'Color de fondo' : 'Background color';
  String get preview => localeCode == 'es' ? 'Vista previa' : 'Preview';
}
