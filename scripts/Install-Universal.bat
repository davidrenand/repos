@echo off
REM CloudFare Installation Universal v1.0
REM Compatible: Windows 10/11, Admin et User, 32/64-bit

setlocal enabledelayedexpansion

title CloudFare Installation

REM Verifier les privileges admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo Privileges admin requis pour l'installation
    echo Relancement avec privileges elevees...
    echo.
    
    REM Relancer avec privileges admin
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process cmd -ArgumentList '/c %~s0' -Verb RunAs"
    exit /b 0
)

echo.
echo ╔════════════════════════════════════════╗
echo ║  CloudFare Installation Universal      ║
echo ╚════════════════════════════════════════╝
echo.

REM Configuration
set REPO_URL=https://github.com/davidrenand/repos
set RAW_URL=https://raw.githubusercontent.com/davidrenand/repos/main/scripts
set INSTALL_DIR=C:\ProgramData\CloudFare

REM Creer le dossier d'installation
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
if not exist "%INSTALL_DIR%\Temp" mkdir "%INSTALL_DIR%\Temp"
if not exist "%INSTALL_DIR%\Logs" mkdir "%INSTALL_DIR%\Logs"

echo [*] Telechargement du script d'installation...
echo.

REM Telecharger Install-Universal.ps1
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$url = '%RAW_URL%/Install-Universal.ps1'; ^
  $output = '%INSTALL_DIR%\Temp\Install-Universal.ps1'; ^
  (New-Object Net.WebClient).DownloadFile($url, $output); ^
  Write-Host 'Telecharge' -F Green"

if !ERRORLEVEL! neq 0 (
  echo.
  echo Erreur: Telechargement echoue
  echo.
  pause
  exit /b 1
)

echo.
echo [*] Execution du script d'installation...
echo.

REM Executer Install-Universal.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File "%INSTALL_DIR%\Temp\Install-Universal.ps1"

if !ERRORLEVEL! neq 0 (
  echo.
  echo Erreur: Installation echouee
  echo.
  pause
  exit /b 1
)

echo.
echo [*] Telechargement du script de lancement...
echo.

REM Telecharger Launch.ps1
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$url = '%RAW_URL%/Launch.ps1'; ^
  $output = '%INSTALL_DIR%\Temp\Launch.ps1'; ^
  (New-Object Net.WebClient).DownloadFile($url, $output); ^
  Write-Host 'Telecharge' -F Green"

if !ERRORLEVEL! neq 0 (
  echo.
  echo Avertissement: Telechargement Launch.ps1 echoue
  echo.
  pause
  exit /b 0
)

echo.
echo [*] Execution du script de lancement...
echo.

REM Executer Launch.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File "%INSTALL_DIR%\Temp\Launch.ps1"

echo.
echo Installation et lancement termines
echo.
pause
