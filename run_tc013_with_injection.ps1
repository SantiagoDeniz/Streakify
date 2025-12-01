# Script para ejecutar TC-ACT-013 con inyección de datos
# Completar después de saltar un día (racha debe reiniciarse a 1)

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "TC-ACT-013: Saltar un Día" -ForegroundColor Cyan
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
$logFile = "test_screenshots\tc013_injection_logcat.txt"
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
Write-Host "   OK - Aplicacion abierta" -ForegroundColor Green

# Screenshot inicial
Write-Host ""
Write-Host "[CAPTURA] Screenshot inicial..." -ForegroundColor Yellow
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
& $adb -s $device shell screencap -p /sdcard/screenshot.png
& $adb -s $device pull /sdcard/screenshot.png "test_screenshots\01_TC-ACT-013_injection_${timestamp}.png" | Out-Null
& $adb -s $device shell rm /sdcard/screenshot.png
Write-Host "   OK - Guardado: 01_TC-ACT-013_injection_${timestamp}.png" -ForegroundColor Green

# Instrucciones manuales
Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "ESTADO ACTUAL (INYECTADO)" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "La actividad 'Test Salto' debería tener:" -ForegroundColor White
Write-Host "  - Racha actual: 3" -ForegroundColor Yellow
Write-Host "  - Ultima completacion: HACE 2 DIAS" -ForegroundColor Yellow
Write-Host "  - Dias sin completar: 1 (ayer)" -ForegroundColor Yellow
Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "INSTRUCCIONES TC-ACT-013" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Busca la actividad 'Test Salto' en el dispositivo" -ForegroundColor White
Write-Host "2. Verifica que muestra racha = 3 (o puede estar ya reseteada)" -ForegroundColor White
Write-Host "3. Presiona el boton de completar (checkmark)" -ForegroundColor White
Write-Host "4. Observa el valor de la racha despues de completar" -ForegroundColor White
Write-Host ""

Read-Host "Presiona ENTER despues de completar la actividad"

# Screenshot después de completar
Write-Host ""
Write-Host "[CAPTURA] Screenshot despues de completar..." -ForegroundColor Yellow
& $adb -s $device shell screencap -p /sdcard/screenshot.png
& $adb -s $device pull /sdcard/screenshot.png "test_screenshots\02_TC-ACT-013_injection_despues_${timestamp}.png" | Out-Null
& $adb -s $device shell rm /sdcard/screenshot.png
Write-Host "   OK - Guardado: 02_TC-ACT-013_injection_despues_${timestamp}.png" -ForegroundColor Green

# Verificar resultado
Write-Host ""
Write-Host "Cual es la racha ACTUAL de 'Test Salto'?" -ForegroundColor Yellow
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
Write-Host "RESULTADO TC-ACT-013" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

if ($result -eq "1") {
    Write-Host "[EXITO] Racha se reinicio correctamente a 1" -ForegroundColor Green
    Write-Host ""
    Write-Host "RESULTADO ESPERADO:" -ForegroundColor White
    Write-Host "  Al saltar un dia (no completar ayer), la racha se reinicia" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "[FALLO] Racha incorrecta: Se esperaba 1, se obtuvo $result" -ForegroundColor Red
    Write-Host ""
    Write-Host "PROBLEMA DETECTADO:" -ForegroundColor White
    Write-Host "  La racha no se reinicio correctamente al saltar un dia" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "Screenshots capturados:" -ForegroundColor White
Write-Host "  1. 01_TC-ACT-013_injection_${timestamp}.png (Estado inicial)" -ForegroundColor Gray
Write-Host "  2. 02_TC-ACT-013_injection_despues_${timestamp}.png (Despues de completar)" -ForegroundColor Gray
Write-Host ""
Write-Host "Logs guardados en:" -ForegroundColor White
Write-Host "  $logFile" -ForegroundColor Gray
Write-Host ""

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "TEST COMPLETADO" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

Read-Host "Presiona ENTER para finalizar"
