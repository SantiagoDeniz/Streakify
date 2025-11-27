# Guía de Configuración de Firebase para Streakify

## Descripción General
Esta guía explica cómo configurar Firebase para Streakify y habilitar Crashlytics, Analytics y Remote Config (Feature Flags).

## Requisitos Previos
- Una cuenta de Google
- Acceso a la [Consola de Firebase](https://console.firebase.google.com/)

## Paso 1: Crear un Proyecto de Firebase

1. Ve a la [Consola de Firebase](https://console.firebase.google.com/)
2. Haz clic en "Agregar proyecto"
3. Ingresa el nombre del proyecto: `Streakify` (o el nombre que prefieras)
4. Habilita Google Analytics (recomendado)
5. Elige o crea una cuenta de Google Analytics
6. Haz clic en "Crear proyecto"

## Paso 2: Agregar la App de Android

1. En tu proyecto de Firebase, haz clic en el ícono de Android
2. Ingresa el nombre del paquete: `com.example.streakify` (o tu nombre de paquete real desde `android/app/build.gradle`)
3. Ingresa el apodo de la app: `Streakify Android`
4. Descarga el archivo `google-services.json`
5. Coloca el archivo en el directorio `android/app/`

### Actualizar la Configuración de Android

Agrega a `android/build.gradle`:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

Agrega a `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-analytics'
    implementation 'com.google.firebase:firebase-crashlytics'
}
```

## Paso 3: Agregar la App de iOS (Opcional)

1. En tu proyecto de Firebase, haz clic en el ícono de iOS
2. Ingresa el bundle ID desde `ios/Runner.xcodeproj`
3. Descarga el archivo `GoogleService-Info.plist`
4. Agrega el archivo a `ios/Runner/` en Xcode

## Paso 4: Habilitar los Servicios de Firebase

### Crashlytics
1. En la Consola de Firebase, ve a Crashlytics
2. Haz clic en "Habilitar Crashlytics"
3. Sigue el asistente de configuración

### Analytics
1. En la Consola de Firebase, ve a Analytics
2. Analytics debería estar habilitado por defecto
3. Verifica que los eventos se estén rastreando

### Remote Config
1. En la Consola de Firebase, ve a Remote Config
2. Haz clic en "Crear configuración"
3. Agrega los siguientes parámetros:

| Clave del Parámetro | Valor por Defecto | Descripción |
|---------------------|-------------------|-------------|
| `enable_new_statistics_ui` | `false` | Activar nueva UI de estadísticas |
| `enable_social_features` | `false` | Activar funciones sociales |
| `enable_advanced_gamification` | `true` | Activar gamificación avanzada |
| `enable_experimental_themes` | `false` | Activar temas experimentales |
| `enable_team_streaks` | `false` | Activar rachas de equipo |
| `enable_pomodoro_mode` | `false` | Activar modo Pomodoro |

4. Haz clic en "Publicar cambios"

## Paso 5: Probar la Integración de Firebase

### Ejecutar la app con Firebase
```bash
flutter run
```

### Verificar Crashlytics
Provocar un crash de prueba:
```dart
FirebaseCrashlytics.instance.crash();
```

Revisa el dashboard de Crashlytics en la Consola de Firebase después de unos minutos.

### Verificar Analytics
Los eventos deberían aparecer en el dashboard de Analytics de la Consola de Firebase dentro de 24 horas.

### Verificar Remote Config
Revisa los logs para ver si los feature flags se están obteniendo:
```
Logger.info('Feature flags fetched and activated');
```

## Solución de Problemas

### Falla la Compilación de Android
- Asegúrate de que `google-services.json` esté en `android/app/`
- Verifica que el nombre del paquete coincida en Firebase y `build.gradle`
- Ejecuta `flutter clean` y recompila

### Falla la Compilación de iOS
- Asegúrate de que `GoogleService-Info.plist` esté agregado al proyecto de Xcode
- Verifica que el bundle ID coincida en Firebase y Xcode
- Ejecuta `pod install` en el directorio `ios/`

### Firebase No Se Inicializa
- Verifica la conexión a internet
- Verifica que `google-services.json` / `GoogleService-Info.plist` sean válidos
- Revisa los logs para errores de inicialización

## Opcional: Configurar Secretos de GitHub

Para CI/CD, agrega la configuración de Firebase como secretos de GitHub:

1. Ve a la configuración de tu repositorio de GitHub
2. Navega a Secrets and variables → Actions
3. Agrega los siguientes secretos:
   - `FIREBASE_ANDROID_CONFIG`: Contenido de `google-services.json`
   - `FIREBASE_IOS_CONFIG`: Contenido de `GoogleService-Info.plist`

## Recursos

- [Documentación de Firebase](https://firebase.google.com/docs?hl=es)
- [Documentación de FlutterFire](https://firebase.flutter.dev/)
- [Configuración de Crashlytics](https://firebase.google.com/docs/crashlytics/get-started?platform=flutter&hl=es)
- [Configuración de Analytics](https://firebase.google.com/docs/analytics/get-started?platform=flutter&hl=es)
- [Configuración de Remote Config](https://firebase.google.com/docs/remote-config/get-started?platform=flutter&hl=es)
