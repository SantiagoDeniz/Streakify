# TC-ACT-012: Completar actividad dia consecutivo (MODO DEBUG)
# Este script ejecuta el test en modo debug para obtener mas informacion de errores

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "TC-ACT-012: Test en modo DEBUG" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$packageName = "com.streakify.streakify"
$screenshotDir = "C:\Streakify\test_screenshots"

# Verificar dispositivo
Write-Host "[VERIFICACION] Comprobando dispositivo..." -ForegroundColor Yellow
$device = & $adb devices | Select-String -Pattern "device$" | Select-Object -First 1
if (-not $device) {
    Write-Host "[ERROR] No hay dispositivo conectado" -ForegroundColor Red
    exit 1
}
Write-Host "   OK - Dispositivo encontrado" -ForegroundColor Green
Write-Host ""

# Limpiar logcat
Write-Host "[DEBUG] Limpiando logcat..." -ForegroundColor Yellow
& $adb logcat -c
Write-Host "   OK - Logcat limpio" -ForegroundColor Green
Write-Host ""

# Compilar en modo debug
Write-Host "[COMPILACION] Compilando APK en modo DEBUG..." -ForegroundColor Yellow
Write-Host "   Esto tomara varios minutos..." -ForegroundColor Gray
$compileOutput = flutter build apk --debug --no-tree-shake-icons 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Fallo la compilacion" -ForegroundColor Red
    Write-Host $compileOutput -ForegroundColor Red
    exit 1
}
Write-Host "   OK - Compilacion exitosa" -ForegroundColor Green
Write-Host ""

# Instalar APK debug
Write-Host "[INSTALACION] Instalando APK debug en dispositivo..." -ForegroundColor Yellow
$apkPath = "build\app\outputs\flutter-apk\app-debug.apk"
if (-not (Test-Path $apkPath)) {
    Write-Host "[ERROR] No se encontro el APK: $apkPath" -ForegroundColor Red
    exit 1
}

& $adb install -r $apkPath 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Fallo la instalacion" -ForegroundColor Red
    exit 1
}
Write-Host "   OK - APK instalado" -ForegroundColor Green
Write-Host ""

# Iniciar logcat en segundo plano
Write-Host "[DEBUG] Iniciando captura de logs..." -ForegroundColor Yellow
$logFile = Join-Path $screenshotDir "tc012_debug_logcat.txt"
$logcatJob = Start-Job -ScriptBlock {
    param($adbPath, $logFile)
    & $adbPath logcat -v time > $logFile
} -ArgumentList $adb, $logFile
Write-Host "   OK - Capturando logs en: $logFile" -ForegroundColor Green
Write-Host ""

# Abrir app
Write-Host "[APP] Abriendo aplicacion..." -ForegroundColor Yellow
& $adb shell am start -n "$packageName/.MainActivity" 2>&1 | Out-Null
Start-Sleep -Seconds 3
Write-Host "   OK - Aplicacion abierta" -ForegroundColor Green
Write-Host ""

# Captura inicial
Write-Host "[CAPTURA] Screenshot inicial..." -ForegroundColor Yellow
& $adb shell screencap -p /sdcard/screenshot_temp.png 2>&1 | Out-Null
& $adb pull /sdcard/screenshot_temp.png "$screenshotDir\01_TC-ACT-012_debug_inicial.png" 2>&1 | Out-Null
Write-Host "   OK - Guardado: 01_TC-ACT-012_debug_inicial.png" -ForegroundColor Green
Write-Host ""

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "INSTRUCCIONES MANUALES" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. En el dispositivo, localiza la actividad 'Test Ejercicio'" -ForegroundColor White
Write-Host "2. Observa que ya esta completada (racha = 1)" -ForegroundColor White
Write-Host "3. Presiona SUAVEMENTE sobre la actividad" -ForegroundColor White
Write-Host "4. Observa que sucede:" -ForegroundColor White
Write-Host "   - Se abre una pantalla de detalles?" -ForegroundColor Gray
Write-Host "   - Aparece pantalla gris?" -ForegroundColor Gray
Write-Host "   - Muestra algun mensaje?" -ForegroundColor Gray
Write-Host ""

$response = Read-Host "Presiona ENTER despues de tocar la actividad"
Write-Host ""

# Captura despues del tap
Write-Host "[CAPTURA] Screenshot despues del tap..." -ForegroundColor Yellow
Start-Sleep -Milliseconds 500
& $adb shell screencap -p /sdcard/screenshot_temp.png 2>&1 | Out-Null
& $adb pull /sdcard/screenshot_temp.png "$screenshotDir\02_TC-ACT-012_debug_despues_tap.png" 2>&1 | Out-Null
Write-Host "   OK - Guardado: 02_TC-ACT-012_debug_despues_tap.png" -ForegroundColor Green
Write-Host ""

Write-Host "Describe lo que ves en pantalla:" -ForegroundColor Yellow
Write-Host "A - Pantalla de detalles de la actividad (normal)" -ForegroundColor White
Write-Host "B - Pantalla gris/vacia" -ForegroundColor White
Write-Host "C - Mensaje 'Ya completaste esta actividad'" -ForegroundColor White
Write-Host "D - Otro comportamiento" -ForegroundColor White
Write-Host ""
$resultado = Read-Host "Ingresa A, B, C o D"
Write-Host ""

# Detener captura de logs
Write-Host "[DEBUG] Deteniendo captura de logs..." -ForegroundColor Yellow
Stop-Job -Job $logcatJob
Receive-Job -Job $logcatJob | Out-Null
Remove-Job -Job $logcatJob
Write-Host "   OK - Logs guardados" -ForegroundColor Green
Write-Host ""

# Extraer logs relevantes
Write-Host "[DEBUG] Extrayendo logs de Flutter/Streakify..." -ForegroundColor Yellow
$flutterLogs = Get-Content $logFile | Select-String -Pattern "flutter|streakify|ActivityFocusScreen|Navigator" -Context 2 | Select-Object -Last 100
$flutterLogFile = Join-Path $screenshotDir "tc012_debug_flutter_logs.txt"
$flutterLogs | Out-File -FilePath $flutterLogFile -Encoding UTF8
Write-Host "   OK - Logs Flutter: $flutterLogFile" -ForegroundColor Green
Write-Host ""

# Analizar resultado
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "RESULTADOS TC-ACT-012 (DEBUG)" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

switch ($resultado.ToUpper()) {
    "A" {
        Write-Host "[RESULTADO] Pantalla de detalles mostrada correctamente" -ForegroundColor Green
        Write-Host ""
        Write-Host "ANALISIS:" -ForegroundColor Yellow
        Write-Host "- La navegacion funciona correctamente" -ForegroundColor White
        Write-Host "- No se reproduce el problema de pantalla gris" -ForegroundColor White
        Write-Host "- El problema original puede haber sido resuelto" -ForegroundColor White
    }
    "B" {
        Write-Host "[RESULTADO] PROBLEMA: Pantalla gris detectada" -ForegroundColor Red
        Write-Host ""
        Write-Host "ANALISIS:" -ForegroundColor Yellow
        Write-Host "- El problema persiste en modo debug" -ForegroundColor White
        Write-Host "- Revisar logs de Flutter para identificar error" -ForegroundColor White
        Write-Host "- Verificar archivo: $flutterLogFile" -ForegroundColor Gray
        Write-Host ""
        Write-Host "SIGUIENTE PASO:" -ForegroundColor Cyan
        Write-Host "Buscar errores en los logs con:" -ForegroundColor White
        Write-Host "Get-Content '$flutterLogFile' | Select-String -Pattern 'error|exception|null' -CaseSensitive:`$false" -ForegroundColor Gray
    }
    "C" {
        Write-Host "[RESULTADO] Mensaje de validacion mostrado" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "ANALISIS:" -ForegroundColor Yellow
        Write-Host "- La app detecto que la actividad ya esta completada" -ForegroundColor White
        Write-Host "- Esto es correcto, previene completar dos veces" -ForegroundColor White
        Write-Host "- No hay problema de pantalla gris" -ForegroundColor White
    }
    "D" {
        Write-Host "[RESULTADO] Comportamiento inesperado" -ForegroundColor Magenta
        Write-Host ""
        Write-Host "Por favor describe que observaste:" -ForegroundColor Yellow
        $descripcion = Read-Host
        Write-Host ""
        Write-Host "DESCRIPCION REGISTRADA:" -ForegroundColor White
        Write-Host $descripcion -ForegroundColor Gray
    }
    default {
        Write-Host "[RESULTADO] Respuesta no valida" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Screenshots capturados:" -ForegroundColor Cyan
Write-Host "  1. 01_TC-ACT-012_debug_inicial.png" -ForegroundColor White
Write-Host "  2. 02_TC-ACT-012_debug_despues_tap.png" -ForegroundColor White
Write-Host ""
Write-Host "Logs de debug:" -ForegroundColor Cyan
Write-Host "  - Completo: $logFile" -ForegroundColor White
Write-Host "  - Flutter:  $flutterLogFile" -ForegroundColor White
Write-Host ""

Write-Host "[NOTA] Modo DEBUG activado:" -ForegroundColor Yellow
Write-Host "  - Mayor informacion en logs" -ForegroundColor Gray
Write-Host "  - Mejor tracking de errores" -ForegroundColor Gray
Write-Host "  - Hot reload disponible si necesitas cambios" -ForegroundColor Gray
Write-Host ""

$continuar = Read-Host "Deseas intentar reproducir el problema nuevamente? (S/N)"
if ($continuar -eq "S" -or $continuar -eq "s") {
    Write-Host ""
    Write-Host "[INFO] Manten la app abierta y vuelve a presionar sobre 'Test Ejercicio'" -ForegroundColor Cyan
    Read-Host "Presiona ENTER despues de intentarlo"
    
    Write-Host "[CAPTURA] Screenshot adicional..." -ForegroundColor Yellow
    & $adb shell screencap -p /sdcard/screenshot_temp.png 2>&1 | Out-Null
    & $adb pull /sdcard/screenshot_temp.png "$screenshotDir\03_TC-ACT-012_debug_segundo_intento.png" 2>&1 | Out-Null
    Write-Host "   OK - Guardado: 03_TC-ACT-012_debug_segundo_intento.png" -ForegroundColor Green
}

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "TEST COMPLETADO" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

Read-Host "Presiona ENTER para finalizar"
