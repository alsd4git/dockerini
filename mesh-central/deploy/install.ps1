# Auto-elevate

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {

    $command = "irm https://meshc.<redatto>/install.ps1 | iex"

    Start-Process powershell `
        -Verb RunAs `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"$command`""

    exit
}

# MeshCentral Agent Deploy Script
# Run as Administrator

$AgentUrl = "https://meshc.alsd.duckdns.org/meshagents?id=4&meshid=Wi8IOSTD6f`$sgLrOD2kCYVCn`$YUhmCEplNaNILrOIGGXyVcQ8bsDlRumLDS04F9R&installflags=2"

$ServiceName = "meshnetworkservice"
$InstallPath = "C:\Program Files\Mesh Network Service"
$TempDir = Join-Path $env:TEMP "mesh-agent-install"
$AgentFile = Join-Path $TempDir "meshnetworkservice.exe"

Write-Host "Preparing temp folder..."
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

Write-Host "Downloading MeshCentral agent..."
Invoke-WebRequest -Uri $AgentUrl -OutFile $AgentFile -UseBasicParsing

if (!(Test-Path $AgentFile)) {
    throw "Agent download failed."
}

Write-Host "Installing agent..."
$InstallArgs = "-fullinstall --installPath=`"$InstallPath`""

$Process = Start-Process `
    -FilePath $AgentFile `
    -ArgumentList $InstallArgs `
    -Wait `
    -PassThru `
    -WindowStyle Hidden

if ($Process.ExitCode -ne 0) {
    throw "Agent installer exited with code $($Process.ExitCode)."
}

Start-Sleep -Seconds 3

Write-Host "Configuring service recovery..."
sc.exe failure $ServiceName reset= 86400 actions= restart/30000/restart/30000/restart/30000 | Out-Null

Write-Host "Starting service if needed..."
$Service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue

if ($null -eq $Service) {
    throw "Service '$ServiceName' not found after installation."
}

if ($Service.Status -ne "Running") {
    Start-Service -Name $ServiceName
}

Write-Host "Cleaning up installer..."
Remove-Item $AgentFile -Force -ErrorAction SilentlyContinue
Remove-Item $TempDir -Force -Recurse -ErrorAction SilentlyContinue

Write-Host "Done. Service status:"
Get-Service -Name $ServiceName
