/// Enum representing premium features that can be gated
enum PremiumFeature {
  /// Allow unlimited activities (free users limited to 10)
  unlimitedActivities,
  
  /// Access to all theme options
  allThemes,
  
  /// Cloud backup functionality
  cloudBackup,
  
  /// Advanced statistics and analytics
  advancedStats,
  
  /// Data export functionality (CSV, Excel)
  dataExport,
  
  /// Premium widget options
  premiumWidgets,
  
  /// Remove advertisements
  noAds,
}

/// Extension to get user-friendly names for features
extension PremiumFeatureExtension on PremiumFeature {
  String get displayName {
    switch (this) {
      case PremiumFeature.unlimitedActivities:
        return 'Actividades Ilimitadas';
      case PremiumFeature.allThemes:
        return 'Todos los Temas';
      case PremiumFeature.cloudBackup:
        return 'Backup en la Nube';
      case PremiumFeature.advancedStats:
        return 'Estadísticas Avanzadas';
      case PremiumFeature.dataExport:
        return 'Exportación de Datos';
      case PremiumFeature.premiumWidgets:
        return 'Widgets Premium';
      case PremiumFeature.noAds:
        return 'Sin Anuncios';
    }
  }

  String get description {
    switch (this) {
      case PremiumFeature.unlimitedActivities:
        return 'Crea tantas actividades como necesites';
      case PremiumFeature.allThemes:
        return 'Accede a todos los temas, incluyendo exclusivos premium';
      case PremiumFeature.cloudBackup:
        return 'Sincroniza tus datos en la nube de forma segura';
      case PremiumFeature.advancedStats:
        return 'Gráficas detalladas y análisis de tendencias';
      case PremiumFeature.dataExport:
        return 'Exporta tus datos en CSV o Excel';
      case PremiumFeature.premiumWidgets:
        return 'Widgets exclusivos para tu pantalla de inicio';
      case PremiumFeature.noAds:
        return 'Disfruta de la app sin interrupciones';
    }
  }
}
