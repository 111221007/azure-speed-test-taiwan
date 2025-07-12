# Azure Speed Test - Heroku Deployment Script
# This script will prepare and deploy the application to Heroku

Write-Host "Starting Heroku deployment preparation..." -ForegroundColor Green

# Check if git is available
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git is not installed or not in PATH. Please install Git first." -ForegroundColor Red
    exit 1
}

# Check if heroku CLI is available
if (-not (Get-Command heroku -ErrorAction SilentlyContinue)) {
    Write-Host "Heroku CLI is not installed. Please install it first." -ForegroundColor Red
    Write-Host "Download from: https://devcenter.heroku.com/articles/heroku-cli" -ForegroundColor Yellow
    exit 1
}

# Check if we're in the correct directory
if (-not (Test-Path "package.json")) {
    Write-Host "package.json not found. Please run this script from the project root directory." -ForegroundColor Red
    exit 1
}

# Build the application
Write-Host "Building the application..." -ForegroundColor Yellow
node build.js

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed. Please check the errors above." -ForegroundColor Red
    exit 1
}

# Check git status
Write-Host "Checking git status..." -ForegroundColor Yellow
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Host "Uncommitted changes found. Adding all changes..." -ForegroundColor Yellow
    git add .
    git commit -m "Prepare for Heroku deployment - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
}

# Check if heroku remote exists
$herokuRemote = git remote -v | Select-String "heroku"
if (-not $herokuRemote) {
    Write-Host "Heroku remote not found. Please create a Heroku app first:" -ForegroundColor Red
    Write-Host "  heroku create your-app-name" -ForegroundColor Yellow
    Write-Host "  or" -ForegroundColor Yellow
    Write-Host "  heroku git:remote -a your-existing-app-name" -ForegroundColor Yellow
    exit 1
}

# Set required environment variables
Write-Host "Setting environment variables..." -ForegroundColor Yellow
heroku config:set ASPNETCORE_ENVIRONMENT=Production
heroku config:set NODE_ENV=production

# Set stack to container for Docker deployment
Write-Host "Setting stack to container..." -ForegroundColor Yellow
heroku stack:set container

# Deploy to Heroku
Write-Host "Deploying to Heroku..." -ForegroundColor Green
git push heroku master

if ($LASTEXITCODE -eq 0) {
    Write-Host "Deployment successful!" -ForegroundColor Green
    Write-Host "Opening application..." -ForegroundColor Yellow
    heroku open
} else {
    Write-Host "Deployment failed. Check logs with: heroku logs --tail" -ForegroundColor Red
}

Write-Host "Deployment script completed." -ForegroundColor Green
