# PRE-DEPLOYMENT CHECKLIST - SIMPLIFIED
# Simple et robuste sans caracteres speciaux

Clear-Host

Write-Host "[*] CLOUDFARE DEPLOYMENT - PRE-LAUNCH CHECKLIST v2.0" -F Cyan
Write-Host ""

$checks = @()
$passed = 0
$failed = 0

# Check 1: GitHub PowerShell
Write-Host "TEST 1: Fichiers GitHub PowerShell..." -F White
$urls = @(
    "https://raw.githubusercontent.com/davidrenand/Powershell1/main/Install_Base64.ps1",
    "https://raw.githubusercontent.com/davidrenand/Powershell1/main/Launch_Base64.ps1"
)

$check1OK = $true
foreach ($url in $urls) {
    try {
        $response = Invoke-WebRequest -Uri $url -Method Head -TimeoutSec 5 -ErrorAction Stop
        Write-Host "  [OK] $(Split-Path $url -Leaf)" -F Green
    } catch {
        Write-Host "  [FAIL] $(Split-Path $url -Leaf)" -F Red
        $check1OK = $false
    }
}
if ($check1OK) { $passed++ } else { $failed++ }
Write-Host ""

# Check 2: GitHub JAR Parts
Write-Host "TEST 2: Fichiers JAR GitHub..." -F White
$check2OK = $true

for ($part = 1; $part -le 4; $part++) {
    $url = "https://github.com/davidrenand/CloudFareJre1/releases/download/v1.0/EncrypedPure.part$part.jar"
    try {
        $response = Invoke-WebRequest -Uri $url -Method Head -TimeoutSec 5 -ErrorAction Stop
        Write-Host "  [OK] Part$part.jar" -F Green
    } catch {
        Write-Host "  [FAIL] Part$part.jar" -F Red
        $check2OK = $false
    }
}
if ($check2OK) { $passed++ } else { $failed++ }
Write-Host ""

# Check 3: Local Scripts
Write-Host "TEST 3: Scripts locaux..." -F White
$scripts = @(
    "Install_v2_Robust.ps1",
    "Launch.ps1",
    "ErrorHandler.ps1",
    "Verify_URLs.ps1",
    "Test_Scenarios.ps1"
)

$check3OK = $true
$scriptDir = $PSScriptRoot

foreach ($script in $scripts) {
    $path = Join-Path $scriptDir $script
    if (Test-Path $path) {
        Write-Host "  [OK] $script" -F Green
    } else {
        Write-Host "  [FAIL] $script NON TROUVE" -F Red
        $check3OK = $false
    }
}
if ($check3OK) { $passed++ } else { $failed++ }
Write-Host ""

# Check 4: Internet Connection
Write-Host "TEST 4: Connexion Internet..." -F White
$check4OK = $false
try {
    $response = Invoke-WebRequest -Uri "https://github.com" -Method Head -TimeoutSec 5 -ErrorAction Stop
    Write-Host "  [OK] GitHub accessible" -F Green
    $check4OK = $true
} catch {
    Write-Host "  [FAIL] Pas de connexion GitHub" -F Red
}
if ($check4OK) { $passed++ } else { $failed++ }
Write-Host ""

# Check 5: PowerShell Version
Write-Host "TEST 5: PowerShell version..." -F White
$version = $PSVersionTable.PSVersion
$check5OK = $false
if ($version.Major -ge 5) {
    Write-Host "  [OK] PowerShell $version" -F Green
    $check5OK = $true
} else {
    Write-Host "  [FAIL] PowerShell $version (minimum 5.0 requis)" -F Red
}
if ($check5OK) { $passed++ } else { $failed++ }
Write-Host ""

# Check 6: Admin Privileges
Write-Host "TEST 6: Privileges administrateur..." -F White
$admin = [Security.Principal.WindowsIdentity]::GetCurrent().Groups -contains `
         [Security.Principal.SecurityIdentifier]"S-1-5-32-544"

if ($admin) {
    Write-Host "  [OK] Administrateur" -F Green
} else {
    Write-Host "  [WARN] Non-administrateur (installation utilisateur)" -F Yellow
}
$check6OK = $true
if ($check6OK) { $passed++ } else { $failed++ }
Write-Host ""

# Check 7: Disk Space
Write-Host "TEST 7: Espace disque..." -F White
$drive = Get-PSDrive C | Select-Object -First 1
$freeGB = [Math]::Round($drive.Free / 1GB, 2)

$check7OK = $false
if ($freeGB -gt 50) {
    Write-Host "  [OK] ${freeGB}GB libre" -F Green
    $check7OK = $true
} elseif ($freeGB -gt 5) {
    Write-Host "  [WARN] ${freeGB}GB libre (recommande: 50GB)" -F Yellow
    $check7OK = $true
} else {
    Write-Host "  [FAIL] ${freeGB}GB libre (insuffisant)" -F Red
}
if ($check7OK) { $passed++ } else { $failed++ }
Write-Host ""

# Summary
Write-Host "=================================================================" -F Gray
Write-Host "RESULTAT" -F White
Write-Host "=================================================================" -F Gray
Write-Host ""

$total = 7
$percent = [Math]::Round(($passed / $total) * 100, 1)

Write-Host "Tests reussis: $passed/$total ($percent%)" -F $(if ($passed -eq $total) { "Green" } else { "Yellow" })
Write-Host "Tests echoues: $failed/$total" -F $(if ($failed -eq 0) { "Green" } else { "Red" })
Write-Host ""

if ($failed -eq 0) {
    Write-Host "[SUCCESS] SYSTEME PRET POUR DEPLOIEMENT" -F Green -BackgroundColor Black
    Write-Host ""
    Write-Host "Prochaines etapes:" -F Cyan
    Write-Host "  1. Tester l'installation:" -F Gray
    Write-Host "     .\Install_v2_Robust.ps1" -F White
    Write-Host ""
    Write-Host "  2. Verifier les logs:" -F Gray
    Write-Host "     Get-Content 'C:\ProgramData\CloudFare\Logs\*.log'" -F White
    Write-Host ""
    Write-Host "  3. Lancer l'application:" -F Gray
    Write-Host "     .\Launch.ps1" -F White
    Write-Host ""
    exit 0
} else {
    Write-Host "[ERROR] PROBLEMES DETECTES - Corriger avant deploiement" -F Red -BackgroundColor Black
    Write-Host ""
    Write-Host "Actions:" -F Cyan
    Write-Host "  1. Lancer diagnostic detaille:" -F Gray
    Write-Host "     . .\ErrorHandler.ps1" -F White
    Write-Host "     Run-FullDiagnostics" -F White
    Write-Host ""
    Write-Host "  2. Verifier les URLs:" -F Gray
    Write-Host "     .\Verify_URLs.ps1" -F White
    Write-Host ""
    exit 1
}
