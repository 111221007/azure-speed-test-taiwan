# Azure Speed Test - Production Deployment Script
# This script deploys the application to Azure and GitHub

param(
    [Parameter(Mandatory=$false)]
    [string]$GitHubRepo = "git@github.com:111221007/azure-speed-test-taiwan.git",
    
    [Parameter(Mandatory=$false)]
    [switch]$SetupInfrastructure,
    
    [Parameter(Mandatory=$false)]
    [switch]$DeployOnly
)

Write-Host "Azure Speed Test - Production Deployment" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

# Check if Git is initialized
if (-not (Test-Path ".git")) {
    Write-Host "Initializing Git repository..." -ForegroundColor Yellow
    git init
    Write-Host "Git repository initialized" -ForegroundColor Green
}

# Add remote origin if not exists
$remotes = git remote
if ($remotes -notcontains "origin") {
    Write-Host "Adding GitHub remote..." -ForegroundColor Yellow
    git remote add origin $GitHubRepo
    Write-Host "GitHub remote added: $GitHubRepo" -ForegroundColor Green
} else {
    Write-Host "GitHub remote already exists" -ForegroundColor Blue
}

# Set up Azure infrastructure if requested
if ($SetupInfrastructure) {
    Write-Host "Setting up Azure infrastructure..." -ForegroundColor Yellow
    & ".\scripts\Setup-AzureInfrastructure.ps1" -ResourceGroupName "azure-speed-test-prod" -Location "East Asia" -WebAppName "azure-speed-test-taiwan" -StorageAccountName "azurespeedtesttw"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Infrastructure setup failed!" -ForegroundColor Red
        exit 1
    }
}

if (-not $DeployOnly) {
    # Build and test locally first
    Write-Host "Building frontend..." -ForegroundColor Yellow
    Push-Location ui
    try {
        npm install
        if ($LASTEXITCODE -ne 0) { throw "npm install failed" }
        
        npm run build
        if ($LASTEXITCODE -ne 0) { throw "npm build failed" }
        
        Write-Host "Frontend build successful" -ForegroundColor Green
    } catch {
        Write-Host "Frontend build failed: $_" -ForegroundColor Red
        Pop-Location
        exit 1
    }
    Pop-Location

    # Build backend
    Write-Host "Building backend..." -ForegroundColor Yellow
    Push-Location api/AzureSpeed
    try {
        dotnet restore
        if ($LASTEXITCODE -ne 0) { throw "dotnet restore failed" }
        
        dotnet build --configuration Release
        if ($LASTEXITCODE -ne 0) { throw "dotnet build failed" }
        
        Write-Host "Backend build successful" -ForegroundColor Green
    } catch {
        Write-Host "Backend build failed: $_" -ForegroundColor Red
        Pop-Location
        exit 1
    }
    Pop-Location
}

# Commit and push to GitHub
Write-Host "Deploying to GitHub..." -ForegroundColor Yellow
git add .
git status

$commitMessage = "Deploy Azure Speed Test - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
git commit -m $commitMessage

# Push to GitHub
$currentBranch = git branch --show-current
if ([string]::IsNullOrEmpty($currentBranch)) {
    $currentBranch = "main"
    git checkout -b main
}

Write-Host "Pushing to GitHub ($currentBranch branch)..." -ForegroundColor Yellow
git push -u origin $currentBranch

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Deployment initiated successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Status:" -ForegroundColor Green
    Write-Host "- Code pushed to GitHub" -ForegroundColor Green
    Write-Host "- CI/CD pipeline triggered" -ForegroundColor Green
    Write-Host ""
    Write-Host "Links:" -ForegroundColor Green
    Write-Host "- GitHub Repository: https://github.com/111221007/azure-speed-test-taiwan" -ForegroundColor Green
    Write-Host "- GitHub Actions: https://github.com/111221007/azure-speed-test-taiwan/actions" -ForegroundColor Green
    Write-Host "- Azure Portal: https://portal.azure.com" -ForegroundColor Green
    Write-Host "- Production URL: https://azure-speed-test-taiwan.azurewebsites.net" -ForegroundColor Green
    Write-Host ""
    Write-Host "The deployment pipeline will:" -ForegroundColor Yellow
    Write-Host "1. Build the Angular frontend" -ForegroundColor Yellow
    Write-Host "2. Build the .NET backend" -ForegroundColor Yellow
    Write-Host "3. Run tests" -ForegroundColor Yellow
    Write-Host "4. Deploy to Azure Web App" -ForegroundColor Yellow
    Write-Host "5. Configure production settings" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Monitor the deployment progress in GitHub Actions." -ForegroundColor Yellow
} else {
    Write-Host "Git push failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Go to GitHub repository settings" -ForegroundColor Cyan
Write-Host "2. Add these secrets for automated deployment:" -ForegroundColor Cyan
Write-Host "   - AZURE_CREDENTIALS (Azure service principal)" -ForegroundColor Cyan
Write-Host "   - AZURE_STATIC_WEB_APPS_API_TOKEN (if using Static Web Apps)" -ForegroundColor Cyan
Write-Host "3. Monitor the deployment in GitHub Actions" -ForegroundColor Cyan
Write-Host "4. Test the application once deployed" -ForegroundColor Cyan
Write-Host ""
Write-Host "Your Azure Speed Test is now ready for production!" -ForegroundColor Green
