# CloudFare Launcher Universal v1.0
# Compatible: Windows 10/11, Admin et User, 32/64-bit

param(
    [string]$InstallDir = "C:\ProgramData\CloudFare",
    [string]$JarName = "App.jar",
    [string[]]$AppArgs = @()
)

$ErrorActionPreference = "Continue"

# ============================================================================
# FONCTIONS
# ============================================================================

function Write-Log {
    param([string]$Message, [string]$Type = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = @{
        "INFO" = "Cyan"
        "OK" = "Green"
        "WARN" = "Yellow"
        "ERROR" = "Red"
    }
    Write-Host "[$timestamp] [$Type] $Message" -F $color[$Type]
}

function Test-AdminPrivileges {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Verify-Java {
    Write-Log "Verification de Java..." "INFO"
    
    $javaExe = "$InstallDir\Java\bin\java.exe"
    
    if (-not (Test-Path $javaExe)) {
        Write-Log "Java.exe non trouve: $javaExe" "ERROR"
        Write-Log "Veuillez d'abord executer Install-Universal.ps1" "ERROR"
        return $false
    }
    
    try {
        $version = & $javaExe -version 2>&1 | Select-Object -First 1
        Write-Log "Java trouve: $version" "OK"
        return $true
    } catch {
        Write-Log "Erreur verification Java" "ERROR"
        return $false
    }
}

function Verify-Jar {
    Write-Log "Verification du JAR..." "INFO"
    
    $jarPath = "$InstallDir\$JarName"
    
    if (-not (Test-Path $jarPath)) {
        Write-Log "JAR non trouve: $jarPath" "ERROR"
        Write-Log "Veuillez d'abord executer Install-Universal.ps1" "ERROR"
        return $false
    }
    
    $size = [math]::Round((Get-Item $jarPath).Length / 1MB, 2)
    Write-Log "JAR trouve: $size MB" "OK"
    return $true
}

function Execute-Application {
    param([string[]]$Args)
    
    Write-Log "Lancement de l'application..." "INFO"
    
    $javaExe = "$InstallDir\Java\bin\java.exe"
    $jarPath = "$InstallDir\$JarName"
    
    try {
        if ($Args.Count -gt 0) {
            & $javaExe -jar $jarPath @Args
        } else {
            & $javaExe -jar $jarPath
        }
        
        Write-Log "Application terminee" "OK"
        return $true
    } catch {
        Write-Log "Erreur execution application" "ERROR"
        return $false
    }
}

function Create-LogFile {
    param([string]$LogDir)
    
    try {
        if (-not (Test-Path $LogDir)) {
            New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
        }
        
        $logFile = "$LogDir\Launch_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
        return $logFile
    } catch {
        return $null
    }
}

# ============================================================================
# EXECUTION PRINCIPALE
# ============================================================================

function Main {
    Write-Host ""
    Write-Host "CloudFare Launcher Universal v1.0" -F Cyan
    Write-Host ""
    
    # Verifications
    if (-not (Verify-Java)) {
        return 1
    }
    
    if (-not (Verify-Jar)) {
        return 1
    }
    
    Write-Host ""
    
    # Creer un fichier log
    $logDir = "$InstallDir\Logs"
    $logFile = Create-LogFile -LogDir $logDir
    
    if ($logFile) {
        Write-Log "Log: $logFile" "INFO"
    }
    
    Write-Host ""
    
    # Executer l'application
    if (Execute-Application -Args $AppArgs) {
        return 0
    } else {
        return 1
    }
}

# Lancer
exit (Main)
