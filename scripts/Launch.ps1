# CloudFare Launch v2.0
$InstallDir = "C:\ProgramData\CloudFare"

$java = "$InstallDir\Java\bin\java.exe"
$jar = "$InstallDir\App.jar"

Write-Host ""
Write-Host "CLOUDFARE v2.0 LAUNCHER" -F Cyan
Write-Host ""

if (-not (Test-Path $java)) {
    Write-Host "ERROR: Java not found" -F Red
    exit 1
}

if (-not (Test-Path $jar)) {
    Write-Host "ERROR: App.jar not found" -F Red
    exit 1
}

Write-Host "Java: $java" -F Green
Write-Host "JAR: $jar" -F Green
Write-Host ""

Write-Host "Launching application..." -F Yellow
Write-Host ""

& $java -jar $jar

Write-Host ""
Write-Host "Application closed" -F Green
