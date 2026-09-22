Write-Host "Hack Club Regis Application Installer version 1.0.3" -ForegroundColor Green
Write-Host "This will install apps like VS Code, GitHub, Anaconda, Node.js, and Hackatime on your PC."
Write-Host "The installation will begin in 10 seconds. Press Ctrl + C NOW to abort."
Start-Sleep -Seconds 10
Write-Host "Starting installation now..." -ForegroundColor Green
function Test-CommandExists {
    param (
        [string]$Command
    )

    return $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}
function Install-WingetPackage {
    param (
        [Parameter(Mandatory)]
        [string]$PackageId
    )

    Write-Host "Checking $PackageId..." -ForegroundColor Cyan

    $Installed = winget list --id $PackageId -e `
        --accept-source-agreements 2>$null

    if ($LASTEXITCODE -eq 0 -and $Installed -match $PackageId) {
        Write-Host "$PackageId is already installed. Skipping." -ForegroundColor Yellow
        return $true
    }

    Write-Host "Installing $PackageId..." -ForegroundColor Cyan

    winget install --id $PackageId -e `
        --silent `
        --accept-package-agreements `
        --accept-source-agreements `
        --disable-interactivity

    $ExitCode = $LASTEXITCODE

    if ($ExitCode -eq 0) {
        Write-Host "$PackageId installed successfully." -ForegroundColor Green
        return $true
    }

    Write-Host "$PackageId installation failed (exit code: $ExitCode)." -ForegroundColor Red
    return $false
}
# VS Code

Write-Host "Checking for VS Code installation..."
Install-WingetPackage "Microsoft.VisualStudioCode"

$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "User")

$TimeoutSeconds = 60
$ElapsedSeconds = 0

while (-not ((Test-CommandExists -Command code)-or (Test-CommandExists -Command code-insiders))) {
    if ($ElapsedSeconds -ge $TimeoutSeconds) {
        Write-Host "Timed out waiting for VS Code to finish starting up." -ForegroundColor Red
        exit 1
    }

    Start-Sleep -Seconds 1
    $ElapsedSeconds++
}

Write-Host "Installing VS Code extensions..."
if (Test-CommandExists -Command "code"){
$InstalledExtensions = @(
    code --list-extensions
)

$Extensions = @(
    "ms-python.python"
    "ms-python.vscode-pylance"
    "GitHub.copilot"
    "GitHub.copilot-chat"
    "GitHub.vscode-pull-request-github"
    "ms-vscode.live-server"
    "ms-python.debugpy"
    "ms-python.vscode-python-envs"
    "ms-vscode.remote-server"
    "ms-vscode-remote.remote-ssh-edit"
    "ms-vscode-remote.remote-ssh"
    "ms-vscode.remote-explorer"
    "WakaTime.vscode-wakatime"
)

foreach ($Extension in $Extensions) {

    if ($InstalledExtensions -contains $Extension) {
        Write-Host "$Extension is already installed. Skipping." `
            -ForegroundColor DarkGray

        continue
    }

    Write-Host "Installing extension: $Extension..."

    code --install-extension $Extension

    if ($LASTEXITCODE -eq 0) {
        Write-Host "$Extension installed successfully." `
            -ForegroundColor Green
    } else {
        Write-Host "Failed to install $Extension." `
            -ForegroundColor Red
    }
}

Write-Host "Extension setup complete!" -ForegroundColor Green
} else {
    $InstalledExtensions = @(
    code-insiders --list-extensions
)

$Extensions = @(
    "ms-python.python"
    "ms-python.vscode-pylance"
    "GitHub.copilot-chat"
    "GitHub.vscode-pull-request-github"
    "ms-vscode.live-server"
    "ms-python.debugpy"
    "ms-python.vscode-python-envs"
    "ms-vscode.remote-server"
    "ms-vscode-remote.remote-ssh-edit"
    "ms-vscode-remote.remote-ssh"
    "ms-vscode.remote-explorer"
    "WakaTime.vscode-wakatime"
)

foreach ($Extension in $Extensions) {

    if ($InstalledExtensions -contains $Extension) {
        Write-Host "$Extension is already installed. Skipping." `
            -ForegroundColor DarkGray

        continue
    }

    Write-Host "Installing extension: $Extension..."

    code-insiders --install-extension $Extension

    if ($LASTEXITCODE -eq 0) {
        Write-Host "$Extension installed successfully." `
            -ForegroundColor Green
    } else {
        Write-Host "Failed to install $Extension." `
            -ForegroundColor Red
    }
}

Write-Host "Extension setup complete!" -ForegroundColor Green
}
# Git

Install-WingetPackage "Git.Git"

# GitHub CLI
Install-WingetPackage "GitHub.cli"
# Reload the machine and user PATH variables
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "User")

gh auth status 2>$null

if ($LASTEXITCODE -ne 0) {
    Write-Host "You are not signed in to GitHub. Follow the steps to sign in." -ForegroundColor Yellow
    gh auth login --hostname github.com --git-protocol https --web
}
else {
    Write-Host "GitHub authentication detected." -ForegroundColor Green
}

git clone "https://github.com/Hack-Club-Regis/HOOT-Web-Frontend.git" "$HOME\HOOT\HOOT-Web-Frontend"
git clone "https://github.com/Hack-Club-Regis/HOOT-AI-Backend.git" "$HOME\HOOT\HOOT-AI-Backend"

# GitHub Desktop
Install-WingetPackage "GitHub.GitHubDesktop"

# Anaconda
Install-WingetPackage "Anaconda.Anaconda3"

$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "User")

while (-not ((Test-CommandExists -Command conda))) {
    if ($ElapsedSeconds -ge $TimeoutSeconds) {
        Write-Host "Timed out waiting for conda to finish starting up." -ForegroundColor Red
        exit 1
    }

    Start-Sleep -Seconds 1
    $ElapsedSeconds++
}
    
conda create -n HOOT python=3.14 -y
conda activate HOOT
$PythonPackages = @(
    "numpy"
)

foreach ($PythonPackage in $PythonPackages) {

    Write-Host "Installing Python package: $PythonPackage..."

    python -m pip install $PythonPackage

    if ($LASTEXITCODE -eq 0) {
        Write-Host "$PythonPackage installed successfully." `
            -ForegroundColor Green
    } else {
        Write-Host "Failed to install $PythonPackage." `
            -ForegroundColor Red
    }
}

# Node.js
Install-WingetPackage "OpenJS.NodeJS.LTS"
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "User")

$Path = "$HOME\HOOT\HOOT-Web-Frontend"

$TimeoutSeconds = 60
$ElapsedSeconds = 0

while (-not (Test-Path $Path)) {
    if ($ElapsedSeconds -ge $TimeoutSeconds) {
        Write-Host "Timed out waiting for Git to finish cloning." -ForegroundColor Red
        exit 1
    }

    Start-Sleep -Seconds 1
    $ElapsedSeconds++
}
Set-Location $HOME\HOOT\HOOT-Web-Frontend
npm ci


# Hackatime

Write-Host "Checking for Hackatime installation..."
if (Test-Path (Join-Path $HOME .wakatime)) {
    Write-Host "Hackatime is already installed."
} else {
    Write-Host "Hackatime not found." -ForegroundColor Red
    Write-Host "Hackatime is Hack Club's time tracking tool. You'll need this for YSWS. Sign in in your browser, then paste the command it gives you below."
    Start-Sleep -Seconds 10
    Start-Process "https://hackatime.hackclub.com/setup?step=terminal-command"

    $HackatimeCommand = Read-Host "Paste the command here"

    Invoke-Expression $HackatimeCommand
}

Write-Host "Installation complete!" -ForegroundColor Green
Write-Host "                                                                                                
                                                                                                
                                                                                                
                                                                                                
                                 %%%%%%%%%%%%%%#                                                
                               %@%%%%%%%%%%%%%%%%%%%%                                    +%%%   
@@@                            @@%%%%.-%%%%%%%%%%%%%%%%%%%                           #%%%%@%    
.-@@@@                        %@%%%%...%%*..%%%#:%%%%%%%%%%%%%%%               +#%%%%%%%%@%     
....:%@@@                    %@%%%%%.......*%%:...%%%-.-%%%%%%%%%%%@%%%%%%%%%%%%%%#++%%%%@%%%%%%
........=@@@@               %@%%%%%...#=...%%-.%-:%#..%+%#.%%%%%%%%%%%%%%%%%%%%-%--%.%%%%%%%%%% 
............+@%@@@@         @@%%%%%-+%%%..%%.....*%..%%%%-.%*.%%%%%-.+%=+%%%.%%.=%.=%.%%%%@%%   
.................-#@@%%@@  @@%%%%%%%%%%%+%%%.%%..%%.=%%%%....%%%%%::%%%=.%%%--%-.%--#+%%%%#     
.................*@-....#@%@%%%%%%%%%%%%%%%%%%%%%%%..=%%..#..%%%%%.=%%%%.%%%%-=.*%%%%%%#        
................@*.......=@@          %%%%%%%%%%%%%%%%%%-%%=.#%%%%+.+#%%...-#%%%%%%%%+          
...............%*.......=#%%@                %%%%%%%%%%%%%%%%%%%%%%#+*%%%%%%%%%%%%+             
..............=%......@%:...@@                     @%%%%%%%%%%%%%%%%%%%%%%%%%%+                 
..............@.........@@..@@                             +@@@@%%%%%%%%*++                     
.............+*......:=#*@@@@                                                                   
.............@......@*+...@@                                                                    
.............@.......=@@..@@                                                                    
............=#......=@%@@@@                                                                     
............=*....:@*-...@                                                                      
@@=..........@.....:@@#..@                                                                      
  @@@%%=.....*%...=@@@@#@@                                                                      
       @@@@@%%@@%@@                                                                             
                                                                                                
                                                                                                
                                                                                                
                                                                                                
"
