package com.streakify.streakify

class StreakifySmallWidgetProvider : StreakifyWidgetProvider() {
    // Hereda la lógica de onUpdate, pero al estar registrado con 
    // home_widget_small_provider.xml, tendrá el tamaño inicial correcto.
    // La lógica dinámica en la clase padre se encargará de mantener el layout correcto
    // si el usuario lo redimensiona, o podemos sobrescribir para forzar.
}
