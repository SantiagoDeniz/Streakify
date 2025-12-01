# Script para ejecutar casos de prueba criticos en dispositivo Android
# con captura de screenshots

$adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$screenshotDir = "C:\Streakify\test_screenshots"
$packageName = "com.streakify.streakify"

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "CASOS DE PRUEBA CRITICOS" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Funcion para capturar screenshot
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
    
    # Capturar en dispositivo y transferir
    & $adbPath shell screencap $remotePath | Out-Null
    & $adbPath pull $remotePath $localPath | Out-Null
    & $adbPath shell rm $remotePath | Out-Null
    
    Write-Host "   OK - Guardado: $filename" -ForegroundColor Green
    Start-Sleep -Milliseconds 500
}

# Funcion para limpiar la base de datos
function Clear-Database {
    Write-Host "[LIMPIEZA] Limpiando base de datos..." -ForegroundColor Yellow
    & $adbPath shell "am force-stop $packageName"
    Start-Sleep -Seconds 1
    & $adbPath shell "pm clear $packageName"
    Start-Sleep -Seconds 2
    Write-Host "   OK - Base de datos limpiada" -ForegroundColor Green
}

# Funcion para abrir la app
function Open-App {
    Write-Host "[APP] Abriendo aplicacion..." -ForegroundColor Yellow
    & $adbPath shell monkey -p $packageName -c android.intent.category.LAUNCHER 1 | Out-Null
    Start-Sleep -Seconds 4
    Write-Host "   OK - Aplicacion abierta" -ForegroundColor Green
}

# INICIO DE PRUEBAS
Write-Host "Dispositivo conectado: " -NoNewline
$device = & $adbPath devices | Select-String "device$"
Write-Host "$device" -ForegroundColor Green
Write-Host ""

# Estado inicial
Write-Host "[INICIAL] Capturando estado inicial..." -ForegroundColor Cyan
Open-App
Capture-Screenshot "00_estado_inicial" "Estado inicial de la app"
Write-Host ""

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "TC-ACT-011: Primera completacion" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Objetivo: Verificar que streak=1 en primera completacion" -ForegroundColor Gray
Write-Host ""

# Limpiar y reiniciar
Clear-Database
Open-App
Start-Sleep -Seconds 3

Capture-Screenshot "01_TC-ACT-011_inicio" "Pantalla inicial vacia"

Write-Host "[MANUAL] INSTRUCCIONES:" -ForegroundColor Yellow
Write-Host "   1. Presiona el boton '+' para crear una actividad" -ForegroundColor White
Read-Host "   Presiona ENTER cuando hayas presionado '+'"

Capture-Screenshot "02_TC-ACT-011_formulario" "Formulario de nueva actividad"

Write-Host "   2. Ingresa 'Test Ejercicio' como nombre" -ForegroundColor White
Write-Host "   3. Selecciona un icono y color" -ForegroundColor White
Write-Host "   4. Presiona 'Guardar'" -ForegroundColor White
Read-Host "   Presiona ENTER cuando hayas guardado"

Start-Sleep -Seconds 1
Capture-Screenshot "03_TC-ACT-011_actividad_creada" "Actividad creada en lista"

Write-Host "   5. Presiona sobre la actividad para completarla" -ForegroundColor White
Read-Host "   Presiona ENTER cuando hayas marcado como completada"

Start-Sleep -Seconds 1
Capture-Screenshot "04_TC-ACT-011_completada" "Actividad completada - verificar racha=1"

Write-Host ""
Write-Host "[OK] TC-ACT-011 completado" -ForegroundColor Green
Write-Host "   Verificar en screenshot: streak debe ser 1" -ForegroundColor Gray
Write-Host ""
Read-Host "Presiona ENTER para continuar con siguiente prueba"

# TC-ACT-012
Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "TC-ACT-012: Dia consecutivo" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Objetivo: Verificar que streak incrementa de 5 a 6" -ForegroundColor Gray
Write-Host ""

Write-Host "[AVISO] Esta prueba requiere manipular la base de datos" -ForegroundColor Yellow
Write-Host "   Necesitamos una actividad con streak=5 completada ayer" -ForegroundColor Gray
Write-Host ""
Write-Host "   Opciones:" -ForegroundColor White
Write-Host "   A - Usar flutter para insertar datos de prueba" -ForegroundColor White
Write-Host "   B - Saltar esta prueba por ahora" -ForegroundColor White
$option = Read-Host "   Selecciona opcion (A/B)"

if ($option -eq "A") {
    Write-Host "   Ejecutando insercion de datos de prueba..." -ForegroundColor Yellow
    # Aqui se ejecutaria un script de dart para insertar datos
    Write-Host "   (Requiere implementacion adicional)" -ForegroundColor Gray
} else {
    Write-Host "   [SKIP] Prueba saltada" -ForegroundColor Gray
}

Write-Host ""
Read-Host "Presiona ENTER para continuar"

# TC-ACT-013
Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "TC-ACT-013: Saltar un dia" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Objetivo: Verificar que streak se reinicia a 1" -ForegroundColor Gray
Write-Host ""

Write-Host "[AVISO] Similar a TC-ACT-012, requiere datos de prueba" -ForegroundColor Yellow
Write-Host "   Necesitamos una actividad completada hace 2 dias" -ForegroundColor Gray
Write-Host "   [SKIP] Prueba saltada" -ForegroundColor Gray

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "RESUMEN DE PRUEBAS" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "[OK] TC-ACT-011: Completado (revisar screenshots)" -ForegroundColor Green
Write-Host "[SKIP] TC-ACT-012: Saltado (requiere datos de prueba)" -ForegroundColor Yellow
Write-Host "[SKIP] TC-ACT-013: Saltado (requiere datos de prueba)" -ForegroundColor Yellow
Write-Host ""
Write-Host "Screenshots guardados en: $screenshotDir" -ForegroundColor Cyan
Write-Host ""

# Listar screenshots capturados
Write-Host "Screenshots capturados:" -ForegroundColor Cyan
Get-ChildItem $screenshotDir -Filter "*.png" | ForEach-Object {
    Write-Host "   - $($_.Name)" -ForegroundColor White
}

Write-Host ""
Write-Host "Pruebas completadas!" -ForegroundColor Green
