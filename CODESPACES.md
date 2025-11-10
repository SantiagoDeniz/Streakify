# 🚀 Streakify - Desarrollo en Codespaces

## Comandos útiles en Codespaces:

### 📱 **Compilar para Android:**
```bash
flutter build apk --release
```

### 🌐 **Ejecutar en navegador:**
```bash
flutter run -d web-server --web-port 3000
```

### 🔧 **Verificar configuración:**
```bash
flutter doctor -v
```

### 📦 **Instalar dependencias:**
```bash
flutter pub get
```

### 🎯 **Generar APK de debug:**
```bash
flutter build apk --debug
```

## 📲 **Descargar APK:**
1. Después de compilar, el APK estará en: `build/app/outputs/flutter-apk/`
2. Descarga el archivo desde el explorador de Codespaces
3. Transfiere a tu celular e instala

## ⚡ **Ports que se abren automáticamente:**
- **3000**: Flutter Web Server
- **8080**: Desarrollo general  
- **5000**: Hot reload y debug