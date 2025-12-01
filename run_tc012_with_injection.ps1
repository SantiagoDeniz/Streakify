# Script para ejecutar TC-ACT-012 con inyección de datos
# Completar actividad en día consecutivo (racha 5 -> 6)

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "TC-ACT-012: Día Consecutivo" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$device = "7LXGVSJ7AALZ5DDM"
$package = "com.streakify.streakify"

# Verificar dispositivo
Write-Host "[VERIFICACION] Comprobando dispositivo..." -ForegroundColor Yellow
$deviceCheck = & $adb devices | Select-String $device
if (-not $deviceCheck) {
    Write-Host "   ERROR - Dispositivo no encontrado" -ForegroundColor Red
    exit 1
}
Write-Host "   OK - Dispositivo encontrado" -ForegroundColor Green

# Activar modo testing TC-ACT-012
Write-Host ""
Write-Host "[INYECCION] Activando modo test TC-ACT-012..." -ForegroundColor Yellow

# Crear archivo XML de SharedPreferences con el flag
$prefsXml = @"
<?xml version='1.0' encoding='utf-8' standalone='yes' ?>
<map>
    <boolean name="inject_tc012" value="true" />
</map>
"@

# Guardar temporalmente
$prefsXml | Out-File -FilePath "temp_prefs.xml" -Encoding UTF8

# Detener la app si está corriendo
& $adb -s $device shell am force-stop $package 2>$null

# Usar adb para escribir el archivo de preferencias
# Nota: Esto requiere que la app exista primero
Write-Host "   Configurando flag de inyeccion..." -ForegroundColor DarkGray

# Método alternativo: Usar am broadcast para activar
# Por ahora, el flag se activará en el código cuando detecte el nombre especial

Remove-Item "temp_prefs.xml" -ErrorAction SilentlyContinue

Write-Host "   OK - Modo test configurado (se inyectara al iniciar app)" -ForegroundColor Green

# Compilar APK debug
Write-Host ""
Write-Host "[COMPILACION] Compilando APK debug..." -ForegroundColor Yellow
Write-Host "   Esto tomara varios minutos..." -ForegroundColor DarkGray

$buildOutput = flutter build apk --debug --no-tree-shake-icons 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "   ERROR - Fallo la compilacion" -ForegroundColor Red
    Write-Host $buildOutput
    exit 1
}
Write-Host "   OK - Compilacion exitosa" -ForegroundColor Green

# Instalar APK
Write-Host ""
Write-Host "[INSTALACION] Instalando APK..." -ForegroundColor Yellow
$installOutput = & $adb -s $device install -r "build\app\outputs\flutter-apk\app-debug.apk" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "   ERROR - Fallo la instalacion" -ForegroundColor Red
    Write-Host $installOutput
    exit 1
}
Write-Host "   OK - APK instalado" -ForegroundColor Green

# Limpiar logcat
Write-Host ""
Write-Host "[DEBUG] Limpiando logcat..." -ForegroundColor Yellow
& $adb -s $device logcat -c
Write-Host "   OK - Logcat limpio" -ForegroundColor Green

# Iniciar captura de logs en background
Write-Host ""
Write-Host "[DEBUG] Iniciando captura de logs..." -ForegroundColor Yellow
$logFile = "test_screenshots\tc012_injection_logcat.txt"
$logJob = Start-Job -ScriptBlock {
    param($adb, $device, $logFile)
    & $adb -s $device logcat > $logFile
} -ArgumentList $adb, $device, $logFile
Write-Host "   OK - Capturando logs en: $logFile" -ForegroundColor Green

# Dar tiempo para que el job inicie
Start-Sleep -Seconds 1

# Abrir aplicación
Write-Host ""
Write-Host "[APP] Abriendo aplicacion..." -ForegroundColor Yellow
& $adb -s $device shell am start -n "$package/.MainActivity" | Out-Null
Start-Sleep -Seconds 8
Write-Host "   OK - Aplicacion abierta con datos inyectados" -ForegroundColor Green

# Screenshot inicial
Write-Host ""
Write-Host "[CAPTURA] Screenshot inicial..." -ForegroundColor Yellow
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
& $adb -s $device shell screencap -p /sdcard/screenshot.png
& $adb -s $device pull /sdcard/screenshot.png "test_screenshots\01_TC-ACT-012_injection_${timestamp}.png" | Out-Null
& $adb -s $device shell rm /sdcard/screenshot.png
Write-Host "   OK - Guardado: 01_TC-ACT-012_injection_${timestamp}.png" -ForegroundColor Green

# Instrucciones manuales
Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "ESTADO ACTUAL (INYECTADO)" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "La actividad 'Test Ejercicio' debería tener:" -ForegroundColor White
Write-Host "  - Racha actual: 5" -ForegroundColor Yellow
Write-Host "  - Ultima completacion: AYER" -ForegroundColor Yellow
Write-Host "  - Historial: 5 dias consecutivos" -ForegroundColor Yellow
Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "INSTRUCCIONES TC-ACT-012" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Verifica en el dispositivo que 'Test Ejercicio' muestra racha = 5" -ForegroundColor White
Write-Host "2. Presiona el boton de completar (checkmark) de 'Test Ejercicio'" -ForegroundColor White
Write-Host "3. Observa que sucede con la racha" -ForegroundColor White
Write-Host ""

Read-Host "Presiona ENTER despues de completar la actividad"

# Screenshot después de completar
Write-Host ""
Write-Host "[CAPTURA] Screenshot despues de completar..." -ForegroundColor Yellow
& $adb -s $device shell screencap -p /sdcard/screenshot.png
& $adb -s $device pull /sdcard/screenshot.png "test_screenshots\02_TC-ACT-012_injection_despues_${timestamp}.png" | Out-Null
& $adb -s $device shell rm /sdcard/screenshot.png
Write-Host "   OK - Guardado: 02_TC-ACT-012_injection_despues_${timestamp}.png" -ForegroundColor Green

# Verificar resultado
Write-Host ""
Write-Host "Cual es la racha ACTUAL de 'Test Ejercicio'?" -ForegroundColor Yellow
$result = Read-Host "Ingresa el numero"

# Detener captura de logs
Write-Host ""
Write-Host "[DEBUG] Deteniendo captura de logs..." -ForegroundColor Yellow
Stop-Job -Job $logJob
Remove-Job -Job $logJob
Write-Host "   OK - Logs guardados" -ForegroundColor Green

# Analizar resultado
Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "RESULTADO TC-ACT-012" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

if ($result -eq "6") {
    Write-Host "[EXITO] Racha incremento correctamente: 5 -> 6" -ForegroundColor Green
    Write-Host ""
    Write-Host "RESULTADO ESPERADO:" -ForegroundColor White
    Write-Host "  Al completar en dia consecutivo, la racha incrementa" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "[FALLO] Racha incorrecta: Se esperaba 6, se obtuvo $result" -ForegroundColor Red
    Write-Host ""
    Write-Host "PROBLEMA DETECTADO:" -ForegroundColor White
    Write-Host "  La racha no incremento correctamente en dia consecutivo" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "Screenshots capturados:" -ForegroundColor White
Write-Host "  1. 01_TC-ACT-012_injection_${timestamp}.png (Estado inicial)" -ForegroundColor Gray
Write-Host "  2. 02_TC-ACT-012_injection_despues_${timestamp}.png (Despues de completar)" -ForegroundColor Gray
Write-Host ""
Write-Host "Logs guardados en:" -ForegroundColor White
Write-Host "  $logFile" -ForegroundColor Gray
Write-Host ""

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "TEST COMPLETADO" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

Read-Host "Presiona ENTER para finalizar"
