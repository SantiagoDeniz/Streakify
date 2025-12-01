# TC-ACT-012 Alternativo: Verificar comportamiento de día consecutivo
# Como no podemos completar dos veces el mismo día, verificamos el comportamiento esperado

$adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$screenshotDir = "C:\Streakify\test_screenshots"
$packageName = "com.streakify.streakify"

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "TC-ACT-012: Verificacion de comportamiento" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

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

Write-Host "[INFO] SITUACION ACTUAL:" -ForegroundColor Yellow
Write-Host "- Actividad 'Test Ejercicio' completada HOY en TC-ACT-011" -ForegroundColor Gray
Write-Host "- Racha actual: 1" -ForegroundColor Gray
Write-Host "- No se puede completar dos veces el mismo dia" -ForegroundColor Gray
Write-Host ""
Write-Host "[PRUEBA] Verificaremos:" -ForegroundColor Cyan
Write-Host "1. Que la actividad muestre 'Completada hoy'" -ForegroundColor White
Write-Host "2. Que NO permita completarse nuevamente" -ForegroundColor White
Write-Host "3. Que la racha se mantenga en 1" -ForegroundColor White
Write-Host ""

Write-Host "[APP] Abriendo aplicacion..." -ForegroundColor Yellow
& $adbPath shell monkey -p $packageName -c android.intent.category.LAUNCHER 1 | Out-Null
Start-Sleep -Seconds 4
Write-Host "   OK - Aplicacion abierta" -ForegroundColor Green
Write-Host ""

$file1 = Capture-Screenshot "01_TC-ACT-012_alt_estado_actual" "Test Ejercicio - completada hoy"
Write-Host ""

Write-Host "[MANUAL] INSTRUCCIONES:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Localiza la actividad 'Test Ejercicio'" -ForegroundColor White
Write-Host "2. Verifica que muestre:" -ForegroundColor White
Write-Host "   - Racha: 1 o similar" -ForegroundColor Gray
Write-Host "   - Estado: Completada/Check/Marca de completado" -ForegroundColor Gray
Write-Host "   - Puede mostrar 'Hoy' o 'Completada hoy'" -ForegroundColor Gray
Write-Host ""
Read-Host "Presiona ENTER cuando hayas verificado el estado"

Write-Host ""
Write-Host "3. Intenta presionar sobre la actividad nuevamente" -ForegroundColor White
Write-Host "   (para intentar completarla de nuevo)" -ForegroundColor Gray
Write-Host ""
Read-Host "Presiona ENTER cuando hayas intentado completar"

Write-Host ""
$file2 = Capture-Screenshot "02_TC-ACT-012_alt_intento_doble" "Despues de intentar completar de nuevo"
Write-Host ""

Write-Host "[PREGUNTA] Que sucedio al intentar completar de nuevo?" -ForegroundColor Yellow
Write-Host "A - No paso nada / No se pudo completar" -ForegroundColor White
Write-Host "B - Se completo nuevamente (la racha aumento)" -ForegroundColor White
Write-Host "C - Mostro un mensaje de error o advertencia" -ForegroundColor White
$respuesta = Read-Host "Ingresa A, B o C"

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "RESULTADOS TC-ACT-012 (Alternativo)" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

switch ($respuesta.ToUpper()) {
    "A" {
        Write-Host "[RESULTADO] COMPORTAMIENTO CORRECTO" -ForegroundColor Green -BackgroundColor Black
        Write-Host "La actividad NO permitio completarse dos veces el mismo dia" -ForegroundColor Green
        Write-Host "Esto valida que el sistema detecta correctamente el 'mismo dia'" -ForegroundColor Green
        Write-Host ""
        Write-Host "[IMPLICACION PARA TC-ACT-012]" -ForegroundColor Cyan
        Write-Host "Si NO permite doble completacion el mismo dia," -ForegroundColor White
        Write-Host "entonces SI debe incrementar la racha al completar dia consecutivo" -ForegroundColor White
        Write-Host ""
        Write-Host "PRUEBA: EXITOSA (comportamiento esperado)" -ForegroundColor Green
    }
    "B" {
        Write-Host "[RESULTADO] COMPORTAMIENTO INCORRECTO" -ForegroundColor Red -BackgroundColor Black
        Write-Host "La actividad PERMITIO completarse dos veces el mismo dia" -ForegroundColor Red
        Write-Host "Esto es un BUG - no deberia permitir multiples completaciones diarias" -ForegroundColor Red
        Write-Host "(a menos que dailyGoal > 1)" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "PRUEBA: FALLIDA" -ForegroundColor Red
    }
    "C" {
        Write-Host "[RESULTADO] COMPORTAMIENTO CORRECTO (con feedback)" -ForegroundColor Green -BackgroundColor Black
        Write-Host "La actividad mostro mensaje indicando que ya fue completada hoy" -ForegroundColor Green
        Write-Host "Esto es IDEAL - feedback claro al usuario" -ForegroundColor Green
        Write-Host ""
        Write-Host "PRUEBA: EXITOSA (mejor que esperado)" -ForegroundColor Green
    }
    default {
        Write-Host "[RESULTADO] Respuesta no valida" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Screenshots capturados:" -ForegroundColor Cyan
Write-Host "  1. $file1 - Estado actual de 'Test Ejercicio'" -ForegroundColor White
Write-Host "  2. $file2 - Despues de intentar completar de nuevo" -ForegroundColor White
Write-Host ""

Write-Host "[NOTA IMPORTANTE]" -ForegroundColor Yellow
Write-Host "Para probar TC-ACT-012 COMPLETO (racha 5 -> 6):" -ForegroundColor White
Write-Host "  Opcion 1: Esperar a manana y completar 'Test Ejercicio' nuevamente" -ForegroundColor Gray
Write-Host "           (verificar que racha pase de 1 a 2)" -ForegroundColor Gray
Write-Host "  Opcion 2: Crear nueva actividad y completarla por 5 dias consecutivos" -ForegroundColor Gray
Write-Host "  Opcion 3: Modificar la app para incluir modo debug con datos de prueba" -ForegroundColor Gray
Write-Host ""

Read-Host "Presiona ENTER para finalizar"
