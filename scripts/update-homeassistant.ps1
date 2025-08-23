# Home Assistant Version Update Script (PowerShell)
# Usage: .\scripts\update-homeassistant.ps1 [-Force] [-DryRun]

param(
    [switch]$Force,
    [switch]$DryRun,
    [switch]$Help
)

# Colors for output
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Reset = "`e[0m"

function Write-Status($Message) {
    Write-Host "${Blue}[INFO]${Reset} $Message"
}

function Write-Success($Message) {
    Write-Host "${Green}[SUCCESS]${Reset} $Message"
}

function Write-Warning($Message) {
    Write-Host "${Yellow}[WARNING]${Reset} $Message"
}

function Write-Error($Message) {
    Write-Host "${Red}[ERROR]${Reset} $Message"
}

if ($Help) {
    Write-Host "Usage: .\scripts\update-homeassistant.ps1 [-Force] [-DryRun]"
    Write-Host "  -Force    Force update even if version is the same"
    Write-Host "  -DryRun   Show what would be done without making changes"
    exit 0
}

# Check if required files exist
$DockerfilePath = "Dockerfile"
$ReadmePath = "README.md"

if (-not (Test-Path $DockerfilePath)) {
    Write-Error "Dockerfile not found in current directory"
    exit 1
}

Write-Status "🔍 Checking Home Assistant versions..."

# Get current version from Dockerfile
$DockerfileContent = Get-Content $DockerfilePath -Raw
if ($DockerfileContent -match 'FROM homeassistant/home-assistant:([^\s]+)') {
    $CurrentVersion = $Matches[1]
} else {
    Write-Error "Could not extract current version from Dockerfile"
    exit 1
}
Write-Status "Current version: $CurrentVersion"

# Get latest version from Docker Hub
Write-Status "Fetching latest version from Docker Hub..."
try {
    $Response = Invoke-RestMethod -Uri "https://registry.hub.docker.com/v2/repositories/homeassistant/home-assistant/tags?page_size=100&ordering=-last_updated"
    $LatestVersion = $Response.results | 
        Where-Object { $_.name -match '^[0-9]{4}\.[0-9]+\.[0-9]+$' } | 
        Sort-Object { [version]$_.name } | 
        Select-Object -Last 1 | 
        Select-Object -ExpandProperty name
} catch {
    Write-Error "Could not fetch latest version from Docker Hub: $($_.Exception.Message)"
    Write-Host "This could be due to:"
    Write-Host "  - Docker Hub API is down or rate limiting"
    Write-Host "  - Network connectivity issues"
    Write-Host "  - Changes in Docker Hub API response format"
    exit 1
}

if (-not $LatestVersion -or $LatestVersion -eq "null" -or [string]::IsNullOrWhiteSpace($LatestVersion)) {
    Write-Error "Failed to determine latest Home Assistant version"
    Write-Host "Possible causes:"
    Write-Host "  - No valid semantic version tags found in Docker Hub response"
    Write-Host "  - API response format changed"
    Write-Host "  - Network or API issues"
    exit 1
}

# Additional validation for version format
if ($LatestVersion -notmatch '^[0-9]{4}\.[0-9]+\.[0-9]+$') {
    Write-Error "Invalid version format detected: '$LatestVersion'"
    Write-Host "Expected format: YYYY.MM.DD (e.g., 2025.4.1)"
    exit 1
}
Write-Status "Latest version: $LatestVersion"

# Compare versions
if ($CurrentVersion -eq $LatestVersion -and -not $Force) {
    Write-Success "✅ Already up to date! Current version $CurrentVersion is the latest."
    exit 0
}

if ($CurrentVersion -ne $LatestVersion) {
    Write-Status "🔄 Update available: $CurrentVersion -> $LatestVersion"
} elseif ($Force) {
    Write-Warning "🔄 Force update requested for version $LatestVersion"
}

if ($DryRun) {
    Write-Warning "🧪 DRY RUN MODE - No changes will be made"
    Write-Host "Would update:"
    Write-Host "  - Dockerfile: homeassistant/home-assistant:$CurrentVersion -> homeassistant/home-assistant:$LatestVersion"
    if (Test-Path $ReadmePath) {
        Write-Host "  - README badges with new version"
    }
    exit 0
}

# Create backup
$BackupDir = "backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
Copy-Item $DockerfilePath -Destination $BackupDir
if (Test-Path $ReadmePath) {
    Copy-Item $ReadmePath -Destination $BackupDir
}
Write-Status "📦 Backup created in $BackupDir\"

# Update Dockerfile
Write-Status "🛠️ Updating Dockerfile..."
$UpdatedContent = $DockerfileContent -replace "FROM homeassistant/home-assistant:$CurrentVersion", "FROM homeassistant/home-assistant:$LatestVersion"
Set-Content -Path $DockerfilePath -Value $UpdatedContent

# Verify the change
$VerifyContent = Get-Content $DockerfilePath -Raw
if ($VerifyContent -match "FROM homeassistant/home-assistant:$LatestVersion") {
    Write-Success "✅ Dockerfile updated successfully"
} else {
    Write-Error "❌ Failed to update Dockerfile"
    exit 1
}

# Update README if it exists
if (Test-Path $ReadmePath) {
    Write-Status "📝 Updating README badges..."
    $ReadmeContent = Get-Content $ReadmePath -Raw
    $UpdatedReadme = $ReadmeContent -replace "Home%20Assistant-[0-9]{4}\.[0-9]+\.[0-9]+-blue", "Home%20Assistant-$LatestVersion-blue"
    Set-Content -Path $ReadmePath -Value $UpdatedReadme
    Write-Success "✅ README updated successfully"
}

# Test build (optional)
if (Get-Command docker -ErrorAction SilentlyContinue) {
    Write-Status "🧪 Testing Docker build..."
    try {
        docker build --no-cache -t "test-homeassistant:$LatestVersion" . 2>$null | Out-Null
        Write-Success "✅ Docker build test passed"
        docker rmi "test-homeassistant:$LatestVersion" 2>$null | Out-Null
    } catch {
        Write-Warning "⚠️ Docker build test failed - please review the changes manually"
    }
} else {
    Write-Warning "⚠️ Docker not found - skipping build test"
}

# Show summary
Write-Host ""
Write-Success "🎉 Update completed successfully!"
Write-Host ""
Write-Host "Summary of changes:"
Write-Host "  📄 Dockerfile: homeassistant/home-assistant:$CurrentVersion -> homeassistant/home-assistant:$LatestVersion"
if (Test-Path $ReadmePath) {
    Write-Host "  📖 README: Updated version badges"
}
Write-Host "  📦 Backup: Created in $BackupDir\"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Review the changes: git diff"
Write-Host "  2. Test the build: docker build -t test ."
Write-Host "  3. Commit the changes: git add -A; git commit -m `"Update Home Assistant to $LatestVersion`""
Write-Host "  4. Push to repository: git push"
Write-Host ""