# VERIFICATEUR D'URLs - CloudFare Installation System
# Test toutes les URLs et génère rapport

param(
    [string]$ReportFile = "$PSScriptRoot\URL_Verification_Report.txt"
)

$ErrorActionPreference = "SilentlyContinue"
$ProgressPreference = "SilentlyContinue"

# URLs à vérifier
$UrlsToCheck = @(
    @{
        Type = "PowerShell Scripts (GitHub)"
        Urls = @(
            "https://raw.githubusercontent.com/davidrenand/Powershell1/main/Install_Base64.ps1",
            "https://raw.githubusercontent.com/davidrenand/Powershell1/main/Launch_Base64.ps1",
            "https://api.github.com/repos/davidrenand/Powershell1/contents/",
            "https://github.com/davidrenand/Powershell1"
        )
    },
    @{
        Type = "JAR Parts (GitHub Raw)"
        Urls = @(
            "https://raw.githubusercontent.com/davidrenand/repos/main/EncrypedPure.part1.jar",
            "https://raw.githubusercontent.com/davidrenand/repos/main/EncrypedPure.part2.jar",
            "https://raw.githubusercontent.com/davidrenand/repos/main/EncrypedPure.part3.jar",
            "https://raw.githubusercontent.com/davidrenand/repos/main/EncrypedPure.part4.jar",
            "https://api.github.com/repos/davidrenand/CloudFareJre1/contents"
        )
    },
    @{
        Type = "Java Downloads"
        Urls = @(
            "https://github.com/graalvm/graalvm-ce-builds/releases/download/jdk-21.0.1/graalvm-community-jdk-21.0.1_windows-x64_bin.zip",
            "https://download.oracle.com/java/21/latest/jdk-21_windows-x64_bin.zip",
            "https://api.github.com/repos/graalvm/graalvm-ce-builds/releases"
        )
    },
    @{
        Type = "GitHub Status"
        Urls = @(
            "https://github.com",
            "https://api.github.com",
            "https://raw.githubusercontent.com"
        )
    }
)

function Test-UrlAccess {
    param(
        [string]$Url,
        [int]$TimeoutSeconds = 10
    )
    
    $startTime = Get-Date
    $statusCode = 0
    $responseTime = 0
    $accessible = $false
    $errorMsg = ""
    
    try {
        $response = Invoke-WebRequest -Uri $Url `
                                     -Method Head `
                                     -TimeoutSec $TimeoutSeconds `
                                     -ErrorAction Stop `
                                     -WarningAction SilentlyContinue
        
        $statusCode = $response.StatusCode
        $accessible = ($statusCode -ge 200 -and $statusCode -lt 400)
        
    } catch [System.Net.WebException] {
        $errorMsg = $_.Exception.Message
        try {
            $statusCode = [int]$_.Exception.Response.StatusCode
        } catch { }
        
    } catch [System.TimeoutException] {
        $errorMsg = "TIMEOUT - URL ne répond pas dans $TimeoutSeconds secondes"
        $statusCode = 0
        
    } catch {
        $errorMsg = $_.Exception.Message
    }
    
    $responseTime = [Math]::Round(((Get-Date) - $startTime).TotalMilliseconds, 0)
    
    return @{
        Url = $Url
        Accessible = $accessible
        StatusCode = $statusCode
        ResponseTime = $responseTime
        Error = $errorMsg
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
}

function Generate-Report {
    param([array]$Results)
    
    $report = @()
    $report += "╔══════════════════════════════════════════════════════════════╗"
    $report += "║   CLOUDFARE INSTALLATION - URL VERIFICATION REPORT          ║"
    $report += "╚══════════════════════════════════════════════════════════════╝"
    $report += ""
    $report += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    $report += "Computer: $env:COMPUTERNAME"
    $report += "User: $env:USERNAME"
    $report += ""
    
    $totalTests = 0
    $passedTests = 0
    
    foreach ($category in $Results) {
        $report += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        $report += "CATEGORY: $($category.Type)"
        $report += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        foreach ($result in $category.Results) {
            $totalTests++
            $status = if ($result.Accessible) { "✅ OK" } else { "❌ FAILED" }
            if ($result.Accessible) { $passedTests++ }
            
            $report += ""
            $report += "$status | $($result.Url)"
            
            if ($result.StatusCode -gt 0) {
                $report += "     Status Code: $($result.StatusCode)"
            }
            
            if ($result.ResponseTime -gt 0) {
                $report += "     Response Time: $($result.ResponseTime)ms"
            }
            
            if ($result.Error) {
                $report += "     Error: $($result.Error)"
            }
        }
        
        $report += ""
    }
    
    $report += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    $report += "SUMMARY"
    $report += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    $report += "Total Tests: $totalTests"
    $report += "Passed: $passedTests"
    $report += "Failed: $($totalTests - $passedTests)"
    $report += "Success Rate: $([Math]::Round(($passedTests/$totalTests)*100, 1))%"
    $report += ""
    
    if ($passedTests -eq $totalTests) {
        $report += "✅ TOUS LES TESTS RÉUSSIS - SYSTÈME PRÊT POUR DÉPLOIEMENT"
    } elseif ($passedTests -ge $totalTests * 0.8) {
        $report += "⚠️ PLUPART DES TESTS RÉUSSIS - VÉRIFIER LES ERREURS"
    } else {
        $report += "❌ NOMBREUSES DÉFAILLANCES - VÉRIFIER LA CONFIGURATION"
    }
    
    $report += ""
    
    return $report -join "`n"
}

# Exécution
Write-Host "🔍 Vérification des URLs..." -F Cyan

$allResults = @()
$totalUrls = 0

foreach ($category in $UrlsToCheck) {
    Write-Host "`n📋 $($category.Type)..." -F Yellow
    
    $categoryResults = @()
    
    foreach ($url in $category.Urls) {
        $totalUrls++
        Write-Host "   Testing: $url" -F Gray -NoNewline
        
        $result = Test-UrlAccess -Url $url
        $categoryResults += $result
        
        if ($result.Accessible) {
            Write-Host " ✅" -F Green
        } else {
            Write-Host " ❌ (Status: $($result.StatusCode))" -F Red
        }
    }
    
    $allResults += @{
        Type = $category.Type
        Results = $categoryResults
    }
}

# Générer rapport
$report = Generate-Report -Results $allResults

# Afficher rapport
Clear-Host
Write-Host $report -F White
$report | Out-File -FilePath $ReportFile -Encoding UTF8 -Force

Write-Host ""
Write-Host "📄 Rapport sauvegardé: $ReportFile" -F Green
Write-Host ""

# Copier dans clipboard aussi
$report | Set-Clipboard

pause
