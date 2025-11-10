#!/bin/bash

# Script de configuración post-creación para Codespaces
echo "🚀 Configurando entorno Flutter..."

# Verificar Flutter
flutter doctor -v

# Instalar dependencias
echo "📦 Instalando dependencias..."
flutter pub get

# Configurar Android SDK si está disponible
if [ -n "$ANDROID_SDK_ROOT" ]; then
    echo "🤖 Configurando Android SDK..."
    flutter config --android-sdk $ANDROID_SDK_ROOT
fi

# Habilitar desarrollo web
flutter config --enable-web

# Mostrar información del proyecto
echo "✅ Configuración completada!"
echo "📱 Para compilar APK: flutter build apk"
echo "🌐 Para ejecutar en web: flutter run -d web-server"
echo "🔧 Para ver dispositivos: flutter devices"