# GESTIONNAIRE D'ERREURS GLOBAL
# Détecte et gère tous les types de rejet/erreur
# À sourcer dans tous les scripts PowerShell

# ============================================================================
# CONFIGURATION GLOBALE D'ERREURS
# ============================================================================

$global:ErrorTypes = @{
    "ADMIN_REQUIRED" = @{
        Code = 1001
        Message = "Privilèges administrateur requis"
        Solution = "Exécuter 'Exécuter en tant qu'administrateur'"
        Severity = "CRITICAL"
    }
    "JAVA_REQUIRED" = @{
        Code = 1002
        Message = "Java 21 introuvable"
        Solution = "Télécharger Java 21 JDK depuis java.com"
        Severity = "CRITICAL"
    }
    "DISK_SPACE" = @{
        Code = 1003
        Message = "Espace disque insuffisant (besoin 50GB)"
        Solution = "Libérer de l'espace disque ou installer sur autre partition"
        Severity = "CRITICAL"
    }
    "NETWORK_TIMEOUT" = @{
        Code = 1004
        Message = "Connexion réseau timeout"
        Solution = "Vérifier la connexion Internet, réessayer dans quelques minutes"
        Severity = "ERROR"
    }
    "FILE_ACCESS_DENIED" = @{
        Code = 1005
        Message = "Accès fichier refusé"
        Solution = "Fermer les programmes utilisant les fichiers, réessayer"
        Severity = "ERROR"
    }
    "ANTIVIRUS_BLOCKING" = @{
        Code = 1006
        Message = "Antivirus détecté du trafic suspect"
        Solution = "Ajouter CloudFare en exception dans l'antivirus"
        Severity = "ERROR"
    }
    "FIREWALL_BLOCKING" = @{
        Code = 1007
        Message = "Firewall bloque la connexion"
        Solution = "Autoriser PowerShell dans les règles firewall"
        Severity = "ERROR"
    }
    "CORRUPTED_FILE" = @{
        Code = 1008
        Message = "Fichier corrompu"
        Solution = "Relancer l'installation pour retélécharger"
        Severity = "ERROR"
    }
    "REGISTRY_ACCESS" = @{
        Code = 1009
        Message = "Impossible accéder aux clés registre"
        Solution = "Vérifier les permissions du registre"
        Severity = "WARNING"
    }
    "EXECUTION_POLICY" = @{
        Code = 1010
        Message = "Execution Policy PowerShell trop restrictif"
        Solution = "Exécuter avec -ExecutionPolicy Bypass"
        Severity = "WARNING"
    }
    "URL_NOT_FOUND" = @{
        Code = 1011
        Message = "URL indisponible"
        Solution = "Vérifier la connexion, réessayer ou contacter support"
        Severity = "ERROR"
    }
    "PORT_BLOCKED" = @{
        Code = 1012
        Message = "Port réseau bloqué (443/80)"
        Solution = "Vérifier firewall/proxy réseau, contacter IT"
        Severity = "ERROR"
    }
    "PROXY_AUTH_FAILED" = @{
        Code = 1013
        Message = "Authentification proxy échouée"
        Solution = "Configurer identifiants proxy Windows"
        Severity = "ERROR"
    }
    "PERMISSION_DENIED" = @{
        Code = 1014
        Message = "Permission refusée"
        Solution = "Contacter administrateur système"
        Severity = "CRITICAL"
    }
}

# ============================================================================
# FONCTIONS DE GESTION D'ERREURS
# ============================================================================

function Get-ErrorInfo {
    param(
        [string]$ErrorCode,
        [string]$ErrorMessage = ""
    )
    
    if ($global:ErrorTypes.ContainsKey($ErrorCode)) {
        $err = $global:ErrorTypes[$ErrorCode]
        return @{
            Code = $err.Code
            Message = $err.Message
            Solution = $err.Solution
            Severity = $err.Severity
            UserMessage = $ErrorMessage
        }
    }
    
    return @{
        Code = 9999
        Message = "Erreur inconnue"
        Solution = "Contacter support technique"
        Severity = "CRITICAL"
        UserMessage = $ErrorMessage
    }
}

function Show-ErrorDialog {
    param(
        [string]$ErrorCode,
        [string]$ErrorMessage = ""
    )
    
    $errorInfo = Get-ErrorInfo -ErrorCode $ErrorCode -ErrorMessage $ErrorMessage
    $severity = $errorInfo.Severity
    
    # Déterminer couleur et icône
    $colors = @{
        "CRITICAL" = @{ Fg = "Red"; Bg = "Black"; Icon = "❌" }
        "ERROR" = @{ Fg = "Red"; Bg = "Black"; Icon = "⚠️" }
        "WARNING" = @{ Fg = "Yellow"; Bg = "Black"; Icon = "⚡" }
        "INFO" = @{ Fg = "Cyan"; Bg = "Black"; Icon = "ℹ️" }
    }
    
    $color = $colors[$severity]
    
    # Afficher dialogue
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -F $color.Fg
    Write-Host "║                     ERREUR - $severity" -F $color.Fg
    Write-Host "╠════════════════════════════════════════════════════════════╣" -F $color.Fg
    Write-Host "║ Code: $($errorInfo.Code)" -F $color.Fg
    Write-Host "║ Message: $($errorInfo.Message)" -F $color.Fg
    
    if ($errorInfo.UserMessage) {
        Write-Host "║ Détail: $($errorInfo.UserMessage)" -F $color.Fg
    }
    
    Write-Host "╠════════════════════════════════════════════════════════════╣" -F $color.Fg
    Write-Host "║ SOLUTION:" -F $color.Fg
    Write-Host "║ $($errorInfo.Solution)" -F $color.Fg
    Write-Host "╚════════════════════════════════════════════════════════════╝" -F $color.Fg
    Write-Host ""
    
    return $errorInfo
}

function Test-AdminPrivileges {
    $admin = [Security.Principal.WindowsIdentity]::GetCurrent().Groups -contains `
             [Security.Principal.SecurityIdentifier]"S-1-5-32-544"
    
    if (-not $admin) {
        Show-ErrorDialog -ErrorCode "ADMIN_REQUIRED"
        return $false
    }
    
    return $true
}

function Test-DiskSpace {
    param([string]$Path = "C:\", [int]$RequiredGB = 50)
    
    try {
        $drive = Get-PSDrive (Split-Path -Qualifier $Path) | Select-Object -First 1
        $freeGB = [math]::Round($drive.Free / 1GB, 2)
        
        if ($freeGB -lt $RequiredGB) {
            Show-ErrorDialog -ErrorCode "DISK_SPACE" -ErrorMessage "Libre: ${freeGB}GB, requis: ${RequiredGB}GB"
            return $false
        }
        
        return $true
    } catch {
        Show-ErrorDialog -ErrorCode "DISK_SPACE" -ErrorMessage $_.Exception.Message
        return $false
    }
}

function Test-NetConnection {
    param([string]$TestUrl = "https://github.com")
    
    try {
        $response = Invoke-WebRequest -Uri $TestUrl -Method Head -TimeoutSec 5 -ErrorAction Stop
        return $true
    } catch [System.Net.WebException] {
        $webEx = $_.Exception
        
        # Analyser type d'erreur réseau
        if ($webEx.Message -like "*timeout*") {
            Show-ErrorDialog -ErrorCode "NETWORK_TIMEOUT" -ErrorMessage $webEx.Message
        } elseif ($webEx.Message -like "*404*") {
            Show-ErrorDialog -ErrorCode "URL_NOT_FOUND"
        } elseif ($webEx.Message -like "*Connection refused*") {
            Show-ErrorDialog -ErrorCode "PORT_BLOCKED"
        } else {
            Show-ErrorDialog -ErrorCode "NETWORK_TIMEOUT" -ErrorMessage $webEx.Message
        }
        
        return $false
    } catch [System.TimeoutException] {
        Show-ErrorDialog -ErrorCode "NETWORK_TIMEOUT"
        return $false
    } catch {
        Show-ErrorDialog -ErrorCode "NETWORK_TIMEOUT" -ErrorMessage $_.Exception.Message
        return $false
    }
}

function Test-FileAccess {
    param([string]$FilePath)
    
    try {
        # Test lecture
        $null = Get-Content $FilePath -ErrorAction Stop
        return $true
    } catch {
        if ($_.Exception.Message -like "*denied*") {
            Show-ErrorDialog -ErrorCode "FILE_ACCESS_DENIED" -ErrorMessage "Fichier: $FilePath"
        } else {
            Show-ErrorDialog -ErrorCode "FILE_ACCESS_DENIED" -ErrorMessage $_.Exception.Message
        }
        return $false
    }
}

function Test-AntivirusInterference {
    # Vérifier processus antivirus connus
    $knownAV = @(
        "MsMpEng",          # Windows Defender
        "avast",            # Avast
        "avgui",            # AVG
        "ccSvcHst",         # Norton
        "ISAFE",            # F-Secure
        "McShield"          # McAfee
    )
    
    $runningAV = Get-Process | Where-Object { $_.Name -in $knownAV }
    
    if ($runningAV) {
        Show-ErrorDialog -ErrorCode "ANTIVIRUS_BLOCKING" -ErrorMessage "Processus: $($runningAV.Name -join ', ')"
        return $true
    }
    
    return $false
}

function Test-FirewallBlocking {
    # Vérifier services firewall actifs
    try {
        $firewall = Get-Service -Name mpssvc -ErrorAction SilentlyContinue
        
        if ($firewall.Status -eq "Running") {
            # Test de base de connectivité
            $tcpClient = New-Object System.Net.Sockets.TcpClient
            $result = $tcpClient.BeginConnect("github.com", 443, $null, $null)
            $connected = $result.AsyncWaitHandle.WaitOne(3000, $false)
            
            if (-not $connected) {
                Show-ErrorDialog -ErrorCode "FIREWALL_BLOCKING"
                return $true
            }
        }
    } catch {
        Write-Verbose "Firewall check error: $_"
    }
    
    return $false
}

function Test-ExecutionPolicy {
    $policy = Get-ExecutionPolicy
    
    if ($policy -eq "Restricted") {
        Show-ErrorDialog -ErrorCode "EXECUTION_POLICY"
        return $false
    }
    
    return $true
}

function Test-ProxyAuth {
    try {
        $proxy = [System.Net.ServicePointManager]::DefaultProxy
        
        if ($proxy -and $proxy.Address) {
            # Essayer accès sans auth
            $wc = New-Object System.Net.WebClient
            $response = $wc.DownloadString("https://github.com")
            return $true
        }
    } catch {
        if ($_.Exception.Message -like "*401*" -or $_.Exception.Message -like "*407*") {
            Show-ErrorDialog -ErrorCode "PROXY_AUTH_FAILED"
            return $false
        }
    }
    
    return $true
}

function Verify-FileIntegrity {
    param(
        [string]$FilePath,
        [string]$ExpectedHash,
        [ValidateSet("SHA256", "SHA1", "MD5")]
        [string]$Algorithm = "SHA256"
    )
    
    try {
        $hash = Get-FileHash -Path $FilePath -Algorithm $Algorithm -ErrorAction Stop
        
        if ($hash.Hash -ne $ExpectedHash) {
            Show-ErrorDialog -ErrorCode "CORRUPTED_FILE" -ErrorMessage "Hash mismatch: $($hash.Hash)"
            return $false
        }
        
        return $true
    } catch {
        Show-ErrorDialog -ErrorCode "CORRUPTED_FILE" -ErrorMessage $_.Exception.Message
        return $false
    }
}

function Run-FullDiagnostics {
    Write-Host "🔍 Diagnostic complet du système..." -F Cyan
    Write-Host ""
    
    $results = @()
    
    # 1. Admin
    Write-Host "Vérification privilèges admin..." -NoNewline
    $adminOk = Test-AdminPrivileges
    Write-Host (" " + $(if ($adminOk) { "✓" } else { "✗" })) -F $(if ($adminOk) { "Green" } else { "Red" })
    $results += @{ Name = "Admin"; Status = $adminOk }
    
    # 2. Espace disque
    Write-Host "Vérification espace disque..." -NoNewline
    $diskOk = Test-DiskSpace
    Write-Host (" " + $(if ($diskOk) { "✓" } else { "✗" })) -F $(if ($diskOk) { "Green" } else { "Red" })
    $results += @{ Name = "Disk"; Status = $diskOk }
    
    # 3. Réseau
    Write-Host "Vérification connexion réseau..." -NoNewline
    $netOk = Test-NetConnection
    Write-Host (" " + $(if ($netOk) { "✓" } else { "✗" })) -F $(if ($netOk) { "Green" } else { "Red" })
    $results += @{ Name = "Network"; Status = $netOk }
    
    # 4. Antivirus
    Write-Host "Vérification interférence antivirus..." -NoNewline
    $avBlocking = Test-AntivirusInterference
    Write-Host (" " + $(if (-not $avBlocking) { "✓" } else { "✗" })) -F $(if (-not $avBlocking) { "Green" } else { "Red" })
    $results += @{ Name = "AV"; Status = -not $avBlocking }
    
    # 5. Firewall
    Write-Host "Vérification firewall..." -NoNewline
    $fwBlocking = Test-FirewallBlocking
    Write-Host (" " + $(if (-not $fwBlocking) { "✓" } else { "✗" })) -F $(if (-not $fwBlocking) { "Green" } else { "Red" })
    $results += @{ Name = "Firewall"; Status = -not $fwBlocking }
    
    # 6. Execution Policy
    Write-Host "Vérification Execution Policy..." -NoNewline
    $execPolicyOk = Test-ExecutionPolicy
    Write-Host (" " + $(if ($execPolicyOk) { "✓" } else { "✗" })) -F $(if ($execPolicyOk) { "Green" } else { "Red" })
    $results += @{ Name = "ExecutionPolicy"; Status = $execPolicyOk }
    
    # 7. Proxy
    Write-Host "Vérification authentification proxy..." -NoNewline
    $proxyOk = Test-ProxyAuth
    Write-Host (" " + $(if ($proxyOk) { "✓" } else { "✗" })) -F $(if ($proxyOk) { "Green" } else { "Red" })
    $results += @{ Name = "Proxy"; Status = $proxyOk }
    
    Write-Host ""
    
    # Résumé
    $passed = ($results | Where-Object { $_.Status }).Count
    $total = $results.Count
    
    Write-Host "Résumé: $passed/$total tests réussis" -F $(if ($passed -eq $total) { "Green" } else { "Yellow" })
    
    return $results
}

# Export des fonctions
Export-ModuleMember -Function @(
    'Get-ErrorInfo',
    'Show-ErrorDialog',
    'Test-AdminPrivileges',
    'Test-DiskSpace',
    'Test-NetConnection',
    'Test-FileAccess',
    'Test-AntivirusInterference',
    'Test-FirewallBlocking',
    'Test-ExecutionPolicy',
    'Test-ProxyAuth',
    'Verify-FileIntegrity',
    'Run-FullDiagnostics'
) -ErrorAction SilentlyContinue
