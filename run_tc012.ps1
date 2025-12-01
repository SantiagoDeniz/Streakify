# Script para TC-ACT-012: Completar actividad día consecutivo
# Inserta datos de prueba y ejecuta la prueba

$adbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$screenshotDir = "C:\Streakify\test_screenshots"
$packageName = "com.streakify.streakify"

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "TC-ACT-012: Dia consecutivo" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Objetivo: Verificar que streak incrementa de 5 a 6" -ForegroundColor Gray
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

Write-Host "[SETUP] Insertando datos de prueba en la base de datos..." -ForegroundColor Yellow
Write-Host ""

# Calcular fecha de ayer
$yesterday = (Get-Date).AddDays(-1).ToString("yyyy-MM-dd")
$activityId = [guid]::NewGuid().ToString()

Write-Host "Datos a insertar:" -ForegroundColor White
Write-Host "  ID: $activityId" -ForegroundColor Gray
Write-Host "  Nombre: TC-012 Meditacion" -ForegroundColor Gray
Write-Host "  Streak: 5" -ForegroundColor Gray
Write-Host "  Last Completed: ${yesterday}T00:00:00.000" -ForegroundColor Gray
Write-Host ""

# Insertar datos directamente en SQLite usando ADB
$insertSQL = @"
INSERT INTO activities (
    id, name, streak, lastCompleted, active, createdAt,
    customIcon, customColor, recurrenceType, dailyGoal, protectorUsed
) VALUES (
    '$activityId',
    'TC-012 Meditacion',
    5,
    '${yesterday}T00:00:00.000',
    1,
    '$(Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fff")',
    'self_improvement',
    '#9C27B0',
    'daily',
    1,
    0
);
"@

Write-Host "[DB] Ejecutando insercion en SQLite..." -ForegroundColor Yellow

# Primero, cerrar la app para liberar la base de datos
& $adbPath shell am force-stop $packageName
Start-Sleep -Seconds 1

# Ejecutar SQL
$dbPath = "/data/data/$packageName/databases/streakify.db"
$sqlResult = & $adbPath shell "run-as $packageName sqlite3 $dbPath `"$insertSQL`""

if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK - Datos insertados" -ForegroundColor Green
} else {
    Write-Host "   ERROR - Fallo la insercion" -ForegroundColor Red
    Write-Host "   Resultado: $sqlResult" -ForegroundColor Gray
}

# Verificar inserción
Write-Host "[DB] Verificando insercion..." -ForegroundColor Yellow
$verifySQL = "SELECT id, name, streak, lastCompleted FROM activities WHERE id='$activityId';"
$verifyResult = & $adbPath shell "run-as $packageName sqlite3 $dbPath `"$verifySQL`""

if ($verifyResult) {
    Write-Host "   OK - Actividad encontrada:" -ForegroundColor Green
    Write-Host "   $verifyResult" -ForegroundColor Gray
} else {
    Write-Host "   ADVERTENCIA - No se pudo verificar" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[APP] Abriendo aplicacion..." -ForegroundColor Yellow
& $adbPath shell monkey -p $packageName -c android.intent.category.LAUNCHER 1 | Out-Null
Start-Sleep -Seconds 4
Write-Host "   OK - Aplicacion abierta" -ForegroundColor Green

Write-Host ""
$file1 = Capture-Screenshot "01_TC-ACT-012_lista_inicial" "Lista con actividad streak=5"

Write-Host ""
Write-Host "[MANUAL] INSTRUCCIONES:" -ForegroundColor Yellow
Write-Host "   1. Busca la actividad 'TC-012 Meditacion'" -ForegroundColor White
Write-Host "   2. Verifica que muestre 'Racha: 5' o similar" -ForegroundColor White
Read-Host "   Presiona ENTER cuando hayas verificado"

Write-Host ""
Write-Host "   3. Presiona sobre la actividad para completarla HOY" -ForegroundColor White
Read-Host "   Presiona ENTER cuando hayas completado"

Write-Host ""
$file2 = Capture-Screenshot "02_TC-ACT-012_completada" "Actividad completada - verificar racha=6"

Write-Host ""
Write-Host "[OK] TC-ACT-012 completado" -ForegroundColor Green
Write-Host ""
Write-Host "VERIFICACION ESPERADA:" -ForegroundColor Cyan
Write-Host "  - Screenshot 1 debe mostrar: Racha = 5" -ForegroundColor White
Write-Host "  - Screenshot 2 debe mostrar: Racha = 6" -ForegroundColor White
Write-Host "  - Mensaje de confirmacion: 'Racha: 6'" -ForegroundColor White
Write-Host ""
Write-Host "Screenshots capturados:" -ForegroundColor Cyan
Write-Host "  - $file1" -ForegroundColor White
Write-Host "  - $file2" -ForegroundColor White
Write-Host ""

Read-Host "Presiona ENTER para finalizar"

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Prueba TC-ACT-012 completada" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Cyan
