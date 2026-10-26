# NeNe Poker installer for PowerShell (Windows): installs nene-poker inside WSL and adds a `nene-poker` command for PowerShell and cmd.
#
#   irm https://raw.githubusercontent.com/hideyukiMORI/nene-poker/main/install.ps1 | iex
#
# nene-poker is a Linux program, so it lives in WSL. This script runs install.sh inside your WSL distribution (which verifies the
# download against SHA256SUMS and installs ~/.local/bin/nene-poker there), then writes %LOCALAPPDATA%\nene-poker\bin\nene-poker.cmd,
# which starts it through wsl.exe, and adds that folder to your user PATH.
#
# Options (environment variables): NENE_POKER_DISTRO picks a WSL distribution (default: your default one),
# NENE_POKER_VERSION picks a release (default: the latest).
# To uninstall: delete %LOCALAPPDATA%\nene-poker, remove it from your user PATH, and run: wsl rm ~/.local/bin/nene-poker
#
# Kept to ASCII on purpose: Windows PowerShell 5.1 reads scripts without a BOM in the local code page.

function Install-NeNePoker {
    $ErrorActionPreference = 'Stop'
    $repo = 'https://raw.githubusercontent.com/hideyukiMORI/nene-poker/main'

    # Under `irm | iex`, `exit` would close the window; every failure returns from this function instead.
    if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
        Write-Host 'nene-poker install: WSL is not installed. Run "wsl --install", restart, and run this again.' -ForegroundColor Red
        return
    }
    $distroArgs = @()
    $distroOption = ''
    if ($env:NENE_POKER_DISTRO) {
        $distroArgs = @('-d', $env:NENE_POKER_DISTRO)
        $distroOption = " -d $env:NENE_POKER_DISTRO"
    }
    # wsl.exe -l prints UTF-16; strip the NUL bytes before looking at it
    $distros = @((& wsl.exe -l -q) -replace "`0", '' | Where-Object { $_.Trim() })
    if ($distros.Count -eq 0) {
        Write-Host 'nene-poker install: no WSL distribution yet. Run "wsl --install -d Ubuntu", then run this again.' -ForegroundColor Red
        return
    }

    $version = ''
    if ($env:NENE_POKER_VERSION) {
        $version = "NENE_POKER_VERSION=$env:NENE_POKER_VERSION "
    }
    & wsl.exe @distroArgs -e sh -c "curl -fsSL $repo/install.sh | ${version}bash"
    if ($LASTEXITCODE -ne 0) {
        Write-Host 'nene-poker install: the installer inside WSL failed (see above). Nothing was added on the Windows side.' -ForegroundColor Red
        return
    }

    $bin = Join-Path $env:LOCALAPPDATA 'nene-poker\bin'
    New-Item -ItemType Directory -Force -Path $bin | Out-Null
    $launcher = Join-Path $bin 'nene-poker.cmd'
    # --cd ~ starts in the WSL home, so the path needs no shell to expand it
    Set-Content -Path $launcher -Encoding ASCII -Value @(
        '@echo off',
        "wsl.exe$distroOption --cd ~ -e .local/bin/nene-poker %*"
    )

    # NENE_POKER_PATH_SCOPE exists only so the installer can be tested without touching the user PATH ('Process').
    $scope = 'User'
    if ($env:NENE_POKER_PATH_SCOPE) {
        $scope = $env:NENE_POKER_PATH_SCOPE
    }
    $path = [Environment]::GetEnvironmentVariable('Path', $scope)
    if ($null -eq $path) {
        $path = ''
    }
    if (-not (($path -split ';') -contains $bin)) {
        [Environment]::SetEnvironmentVariable('Path', (($path.TrimEnd(';') + ';' + $bin).TrimStart(';')), $scope)
        Write-Host "nene-poker install: added $bin to your $scope PATH"
    }
    if (-not (($env:Path -split ';') -contains $bin)) {
        $env:Path = $env:Path.TrimEnd(';') + ';' + $bin
    }

    Write-Host "nene-poker install: installed $launcher"
    Write-Host 'nene-poker install: run nene-poker here or in a new window (q quits, t changes the theme).'
}

Install-NeNePoker
