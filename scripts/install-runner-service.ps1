# GitHub Actions Self-Hosted Runner Service Installation Script
# This script installs the GitHub Actions runner as a Windows service

param(
    [Parameter(Mandatory=$true)]
    [string]$RepoOwner,
    
    [Parameter(Mandatory=$true)]
    [string]$RepoName,
    
    [Parameter(Mandatory=$false)]
    [string]$RunnerName = "windows-runner-$(Get-Random -Maximum 9999)",
    
    [Parameter(Mandatory=$false)]
    [string]$RunnerPath = "C:\Users\Wipro\actions-runner"
)

# Error handling
$ErrorActionPreference = "Stop"

# Colors for output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Write-Info { Write-ColorOutput "[INFO] $args" -Color Cyan }
function Write-Success { Write-ColorOutput "[SUCCESS] $args" -Color Green }
function Write-Warning { Write-ColorOutput "[WARNING] $args" -Color Yellow }
function Write-Error { Write-ColorOutput "[ERROR] $args" -Color Red }

# Check if running as Administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Download and configure runner
function Install-Runner {
    Write-Info "Installing GitHub Actions self-hosted runner..."
    
    # Create runner directory
    if (Test-Path $RunnerPath) {
        Write-Warning "Runner directory already exists. Removing existing installation..."
        Remove-Item -Path $RunnerPath -Recurse -Force
    }
    
    New-Item -Path $RunnerPath -ItemType Directory -Force | Out-Null
    Set-Location $RunnerPath
    
    # Download latest runner
    Write-Info "Downloading latest runner package..."
    $latestRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/actions/runner/releases/latest"
    $downloadUrl = $latestRelease.assets | Where-Object { $_.name -match "actions-runner-win-x64-.*\.zip$" } | Select-Object -ExpandProperty browser_download_url
    
    if (-not $downloadUrl) {
        throw "Could not find runner download URL"
    }
    
    $outputPath = Join-Path $RunnerPath "actions-runner-win-x64.zip"
    Invoke-WebRequest -Uri $downloadUrl -OutFile $outputPath
    
    # Extract runner
    Write-Info "Extracting runner package..."
    Expand-Archive -Path $outputPath -DestinationPath $RunnerPath -Force
    
    # Configure runner
    Write-Info "Configuring runner..."
    $tokenUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/actions/runners/registration-token"
    $tokenResponse = Invoke-RestMethod -Uri $tokenUrl -Method POST -Headers @{
        "Authorization" = "token $env:GITHUB_TOKEN"
        "Accept" = "application/vnd.github.v3+json"
    }
    
    $token = $tokenResponse.token
    
    # Run configuration
    $configArgs = @(
        "./config.cmd"
        "--unattended"
        "--url", "https://github.com/$RepoOwner/$RepoName"
        "--token", $token
        "--name", $RunnerName
        "--runnergroup", "default"
        "--labels", "windows,self-hosted"
        "--work", "_work"
    )
    
    & $configArgs[0] $configArgs[1..($configArgs.Length-1)]
    
    if ($LASTEXITCODE -ne 0) {
        throw "Runner configuration failed"
    }
    
    Write-Success "Runner configured successfully"
}

# Install as Windows service
function Install-RunnerService {
    Write-Info "Installing runner as Windows service..."
    
    # Install service
    $installArgs = @(
        "./svc.cmd"
        "install"
    )
    
    & $installArgs[0] $installArgs[1]
    
    if ($LASTEXITCODE -ne 0) {
        throw "Service installation failed"
    }
    
    # Start service
    Write-Info "Starting runner service..."
    Start-Service -Name "actions.runner.$RepoOwner.$RepoName.$RunnerName"
    
    # Set service to automatic start
    Set-Service -Name "actions.runner.$RepoOwner.$RepoName.$RunnerName" -StartupType Automatic
    
    Write-Success "Runner service installed and started"
}

# Configure firewall
function Set-FirewallRules {
    Write-Info "Configuring firewall rules..."
    
    try {
        # Allow runner outbound connections
        New-NetFirewallRule -DisplayName "GitHub Actions Runner" -Direction Outbound -Program "$RunnerPath\bin\Runner.Listener.exe" -Action Allow -ErrorAction SilentlyContinue
        Write-Success "Firewall rules configured"
    }
    catch {
        Write-Warning "Could not configure firewall rules: $($_.Exception.Message)"
    }
}

# Create runner management scripts
function New-RunnerScripts {
    Write-Info "Creating runner management scripts..."
    
    # Start script
    $startScript = @"
@echo off
echo Starting GitHub Actions Runner service...
net start "actions.runner.$RepoOwner.$RepoName.$RunnerName"
echo Runner service started.
pause
"@
    
    # Stop script
    $stopScript = @"
@echo off
echo Stopping GitHub Actions Runner service...
net stop "actions.runner.$RepoOwner.$RepoName.$RunnerName"
echo Runner service stopped.
pause
"@
    
    # Status script
    $statusScript = @"
@echo off
echo GitHub Actions Runner Service Status:
sc query "actions.runner.$RepoOwner.$RepoName.$RunnerName"
pause
"@
    
    # Uninstall script
    $uninstallScript = @"
@echo off
echo Uninstalling GitHub Actions Runner service...
cd /d "$RunnerPath"
call svc.cmd stop
call svc.cmd uninstall
echo Runner service uninstalled.
pause
"@
    
    # Save scripts
    $startScript | Out-File -FilePath "$RunnerPath\start-runner.bat" -Encoding ASCII
    $stopScript | Out-File -FilePath "$RunnerPath\stop-runner.bat" -Encoding ASCII
    $statusScript | Out-File -FilePath "$RunnerPath\status-runner.bat" -Encoding ASCII
    $uninstallScript | Out-File -FilePath "$RunnerPath\uninstall-runner.bat" -Encoding ASCII
    
    Write-Success "Runner management scripts created"
}

# Verify installation
function Test-RunnerInstallation {
    Write-Info "Verifying runner installation..."
    
    # Check service status
    $serviceName = "actions.runner.$RepoOwner.$RepoName.$RunnerName"
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    
    if ($service) {
        Write-Success "Runner service is installed"
        Write-Info "Service Name: $serviceName"
        Write-Info "Service Status: $($service.Status)"
        Write-Info "Startup Type: $($service.StartType)"
    } else {
        throw "Runner service not found"
    }
    
    # Check runner directory
    if (Test-Path "$RunnerPath\run.cmd") {
        Write-Success "Runner files are present"
    } else {
        throw "Runner files not found"
    }
}

# Main execution
try {
    Write-Info "Starting GitHub Actions runner service installation..."
    
    # Check administrator privileges
    if (-not (Test-Administrator)) {
        Write-Error "This script must be run as Administrator"
        exit 1
    }
    
    # Check for GitHub token
    if (-not $env:GITHUB_TOKEN) {
        Write-Error "GITHUB_TOKEN environment variable is required"
        Write-Info "Set it with: `$env:GITHUB_TOKEN = 'your_github_token'"
        exit 1
    }
    
    # Install runner
    Install-Runner
    
    # Install service
    Install-RunnerService
    
    # Configure firewall
    Set-FirewallRules
    
    # Create management scripts
    New-RunnerScripts
    
    # Verify installation
    Test-RunnerInstallation
    
    Write-Success "GitHub Actions runner service installation completed!"
    Write-Info "Runner Name: $RunnerName"
    Write-Info "Runner Path: $RunnerPath"
    Write-Info "Service Name: actions.runner.$RepoOwner.$RepoName.$RunnerName"
    Write-Info ""
    Write-Info "Management scripts created:"
    Write-Info "  Start: $RunnerPath\start-runner.bat"
    Write-Info "  Stop: $RunnerPath\stop-runner.bat"
    Write-Info "  Status: $RunnerPath\status-runner.bat"
    Write-Info "  Uninstall: $RunnerPath\uninstall-runner.bat"
    Write-Info ""
    Write-Info "You can now use this runner in your GitHub Actions workflows with:"
    Write-Info "  runs-on: [self-hosted, windows]"
    
}
catch {
    Write-Error "Installation failed: $($_.Exception.Message)"
    exit 1
}
