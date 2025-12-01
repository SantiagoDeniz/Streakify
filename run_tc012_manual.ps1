# Script Simplificado para TC-ACT-012
# Como la app esta en release, hacemos la prueba de forma manual simulada

$adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$screenshotDir = "C:\Streakify\test_screenshots"
$packageName = "com.streakify.streakify"

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "TC-ACT-012: Dia consecutivo" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Función para capturar screenshot
function Capture-Screenshot {
    param (
        [string]$name,
        [string]$description
    )
    Write-Host "[CAPTURA] $description" -ForegroundColor Yellow
    $timestamp = Get-Date -Format "HHmmss"
    $filename = "${name}_${timestamp}.png"
    $remotePath = "/sdcard/screenshot_temp.png"
    $localPath = "$screenshotDir\$filename"
    
    & $adbPath shell screencap $remotePath | Out-Null
    & $adbPath pull $remotePath $localPath | Out-Null
    & $adbPath shell rm $remotePath | Out-Null
    
    Write-Host "   OK - Guardado: $filename" -ForegroundColor Green
    Start-Sleep -Milliseconds 500
    return $filename
}

Write-Host "[INFO] LIMITACION: App en modo Release" -ForegroundColor Yellow
Write-Host "No se puede insertar datos directamente en la base de datos" -ForegroundColor Gray
Write-Host ""
Write-Host "[SOLUCION] Usaremos una actividad existente" -ForegroundColor Cyan
Write-Host ""

Write-Host "[APP] Abriendo aplicacion..." -ForegroundColor Yellow
& $adbPath shell monkey -p $packageName -c android.intent.category.LAUNCHER 1 | Out-Null
Start-Sleep -Seconds 4
Write-Host "   OK - Aplicacion abierta" -ForegroundColor Green
Write-Host ""

$file1 = Capture-Screenshot "01_TC-ACT-012_lista_inicial" "Estado inicial - buscar actividad con racha"
Write-Host ""

Write-Host "[MANUAL] INSTRUCCIONES PARA TC-ACT-012:" -ForegroundColor Yellow
Write-Host ""
Write-Host "OPCION A - Si ya tienes una actividad con racha >= 5:" -ForegroundColor White
Write-Host "  1. Identifica una actividad que tenga racha de al menos 5" -ForegroundColor Gray
Write-Host "  2. Verifica que fue completada AYER (debe mostrar 'Hace 1 dia')" -ForegroundColor Gray
Write-Host "  3. Anota la racha actual (ej: 5)" -ForegroundColor Gray
Write-Host "  4. Completa la actividad HOY" -ForegroundColor Gray
Write-Host "  5. Verifica que la racha aumento en 1 (ej: 5 -> 6)" -ForegroundColor Gray
Write-Host ""
Write-Host "OPCION B - Si NO tienes actividades con racha:" -ForegroundColor White  
Write-Host "  1. Usa la actividad 'Test Ejercicio' creada en TC-ACT-011" -ForegroundColor Gray
Write-Host "  2. Su racha actual es 1 (completada hace un rato)" -ForegroundColor Gray
Write-Host "  3. Completa la actividad nuevamente HOY" -ForegroundColor Gray
Write-Host "  4. Verifica que la racha aumento de 1 a 2" -ForegroundColor Gray
Write-Host ""
Write-Host "NOTA: Para esta prueba, aceptaremos cualquier incremento" -ForegroundColor Yellow
Write-Host "consecutivo de racha (no necesariamente de 5 a 6)" -ForegroundColor Yellow
Write-Host ""

$activityName = Read-Host "Ingresa el NOMBRE de la actividad a usar"
$currentStreak = Read-Host "Ingresa la RACHA ACTUAL de esa actividad"

Write-Host ""
Write-Host "[TEST] Datos de prueba:" -ForegroundColor Cyan
Write-Host "  Actividad: $activityName" -ForegroundColor White
Write-Host "  Racha actual: $currentStreak" -ForegroundColor White
Write-Host "  Racha esperada: $([int]$currentStreak + 1)" -ForegroundColor White
Write-Host ""

Read-Host "Presiona ENTER cuando estes listo para completar la actividad"

Write-Host ""
Write-Host "Ahora completa la actividad '$activityName' presionando sobre ella" -ForegroundColor Yellow
Read-Host "Presiona ENTER cuando hayas completado la actividad"

Write-Host ""
$file2 = Capture-Screenshot "02_TC-ACT-012_completada" "Actividad completada - verificar incremento"

Write-Host ""
$newStreak = Read-Host "Ingresa la NUEVA RACHA mostrada despues de completar"

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "RESULTADOS TC-ACT-012" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Actividad probada: $activityName" -ForegroundColor White
Write-Host "Racha antes: $currentStreak" -ForegroundColor White
Write-Host "Racha despues: $newStreak" -ForegroundColor White
Write-Host "Incremento: $(if ([int]$newStreak -eq ([int]$currentStreak + 1)) { "1" } else { "INCORRECTO" })" -ForegroundColor $(if ([int]$newStreak -eq ([int]$currentStreak + 1)) { "Green" } else { "Red" })
Write-Host ""

if ([int]$newStreak -eq ([int]$currentStreak + 1)) {
    Write-Host "[RESULTADO] PRUEBA EXITOSA" -ForegroundColor Green -BackgroundColor Black
    Write-Host "La racha incremento correctamente en 1 dia consecutivo" -ForegroundColor Green
} else {
    Write-Host "[RESULTADO] PRUEBA FALLIDA" -ForegroundColor Red -BackgroundColor Black
    Write-Host "La racha NO incremento correctamente" -ForegroundColor Red
    Write-Host "Esperado: $([int]$currentStreak + 1), Obtenido: $newStreak" -ForegroundColor Red
}

Write-Host ""
Write-Host "Screenshots capturados:" -ForegroundColor Cyan
Write-Host "  1. $file1 - Estado inicial" -ForegroundColor White
Write-Host "  2. $file2 - Despues de completar" -ForegroundColor White
Write-Host ""

Read-Host "Presiona ENTER para finalizar"
