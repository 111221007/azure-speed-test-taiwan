# Azure Speed Test - Heroku Production Deployment Script
# This script will deploy the application to Heroku using Docker containers

Write-Host "Starting Heroku production deployment..." -ForegroundColor Green

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

# Set Heroku stack to container
Write-Host "Setting Heroku stack to container..." -ForegroundColor Yellow
heroku stack:set container

# Set environment variables
Write-Host "Setting environment variables..." -ForegroundColor Yellow
heroku config:set ASPNETCORE_ENVIRONMENT=Production
heroku config:set NODE_ENV=production

# Check git status
Write-Host "Checking git status..." -ForegroundColor Yellow
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Host "Uncommitted changes found. Adding all changes..." -ForegroundColor Yellow
    git add .
    git commit -m "Production deployment - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
}

# Push to origin first
Write-Host "Pushing to origin..." -ForegroundColor Yellow
git push origin master

# Deploy to Heroku
Write-Host "Deploying to Heroku..." -ForegroundColor Green
git push heroku master

if ($LASTEXITCODE -eq 0) {
    Write-Host "Deployment successful!" -ForegroundColor Green
    Write-Host "Opening application..." -ForegroundColor Yellow
    heroku open
} else {
    Write-Host "Deployment failed. Check logs with: heroku logs --tail" -ForegroundColor Red
    exit 1
}

Write-Host "Production deployment completed successfully!" -ForegroundColor Green
