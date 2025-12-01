package com.streakify.streakify

// No se puede heredar de StreakifyWidgetProvider porque HomeWidgetProvider es final
// En su lugar, usar StreakifyWidgetProvider directamente en AndroidManifest.xml
class StreakifyMediumWidgetProvider : StreakifyWidgetProvider()
