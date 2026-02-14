# 1. Configurar codificacion para evitar simbolos raros
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 2. Definir nombre de archivo
$fechaHora = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$usuarioActual = $env:USERNAME
$nombreArchivo = "$($usuarioActual)_$($fechaHora).txt"
$rutaSalida = Join-Path -Path $PSScriptRoot -ChildPath $nombreArchivo

# Funcion para escribir encabezados sin acentos en el codigo para evitar conflictos
function Escribir-Encabezado($titulo) {
    $linea = "=" * 40
    Add-Content -Path $rutaSalida -Value "`n$linea`n $titulo `n$linea" -Encoding UTF8
}

Write-Host "Iniciando reporte... Por favor espere." -ForegroundColor Cyan

# --- EJECUCION DE TAREAS ---

Escribir-Encabezado "1. INFORMACION DEL SISTEMA"
Get-ComputerInfo | Out-String | Add-Content -Path $rutaSalida -Encoding UTF8

Escribir-Encabezado "2. CONFIGURACION IP"
ipconfig /all | Add-Content -Path $rutaSalida -Encoding UTF8

Escribir-Encabezado "3. USUARIOS Y GRUPOS LOCALES"
Get-LocalUser | Select-Object Name, Enabled | Out-String | Add-Content -Path $rutaSalida -Encoding UTF8
Get-LocalGroup | Select-Object Name | Out-String | Add-Content -Path $rutaSalida -Encoding UTF8

Escribir-Encabezado "4. USUARIOS ACTIVOS"
quser | Add-Content -Path $rutaSalida -Encoding UTF8

Escribir-Encabezado "5. PROCESOS EN EJECUCION"
Get-Process | Select-Object Id, ProcessName, CPU | Sort-Object CPU -Descending | Select-Object -First 30 | Out-String | Add-Content -Path $rutaSalida -Encoding UTF8

Escribir-Encabezado "6. LISTADO DE ARCHIVOS EN CARPETAS PERSONALES"
# Metodo infalible: Usar la variable de entorno HOME
$carpetas = @("Desktop", "Documents", "Pictures", "Downloads")

foreach ($c in $carpetas) {
    $rutaReal = Join-Path -Path $HOME -ChildPath $c
    Add-Content -Path $rutaSalida -Value "--- CARPETA: $c ---" -Encoding UTF8
    if (Test-Path $rutaReal) {
        Get-ChildItem -Path $rutaReal | Select-Object Name, LastWriteTime | Out-String | Add-Content -Path $rutaSalida -Encoding UTF8
    } else {
        Add-Content -Path $rutaSalida -Value "No se encontro la ruta: $rutaReal" -Encoding UTF8
    }
}

Write-Host "PROCESO FINALIZADO CON EXITO" -ForegroundColor Green
