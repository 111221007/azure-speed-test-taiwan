# Azure Infrastructure Setup for Azure Speed Test Taiwan
# Run this script to create all necessary Azure resources for production deployment

param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName = "azure-speed-test-prod",
    
    [Parameter(Mandatory=$true)]
    [string]$Location = "East Asia",
    
    [Parameter(Mandatory=$true)]
    [string]$AppServicePlanName = "azure-speed-test-plan",
    
    [Parameter(Mandatory=$true)]
    [string]$WebAppName = "azure-speed-test-taiwan",
    
    [Parameter(Mandatory=$true)]
    [string]$StaticWebAppName = "azure-speed-test-ui",
    
    [Parameter(Mandatory=$true)]
    [string]$StorageAccountName = "azurespeedtesttw",
    
    [Parameter(Mandatory=$true)]
    [string]$GitHubRepo = "https://github.com/111221007/azure-speed-test-taiwan"
)

Write-Host "🚀 Setting up Azure infrastructure for Azure Speed Test Taiwan..." -ForegroundColor Green

# Login to Azure (if not already logged in)
Write-Host "📝 Checking Azure authentication..." -ForegroundColor Yellow
$context = Get-AzContext
if (-not $context) {
    Write-Host "Please log in to Azure..." -ForegroundColor Yellow
    Connect-AzAccount
}

# Create Resource Group
Write-Host "📦 Creating resource group: $ResourceGroupName" -ForegroundColor Yellow
$rg = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
if (-not $rg) {
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location
    Write-Host "✅ Resource group created successfully" -ForegroundColor Green
} else {
    Write-Host "ℹ️ Resource group already exists" -ForegroundColor Blue
}

# Create App Service Plan
Write-Host "🔧 Creating App Service Plan: $AppServicePlanName" -ForegroundColor Yellow
$plan = Get-AzAppServicePlan -ResourceGroupName $ResourceGroupName -Name $AppServicePlanName -ErrorAction SilentlyContinue
if (-not $plan) {
    New-AzAppServicePlan -ResourceGroupName $ResourceGroupName -Name $AppServicePlanName -Location $Location -Tier "Basic" -NumberofWorkers 1 -WorkerSize "Small" -Linux
    Write-Host "✅ App Service Plan created successfully" -ForegroundColor Green
} else {
    Write-Host "ℹ️ App Service Plan already exists" -ForegroundColor Blue
}

# Create Web App for Backend API
Write-Host "🌐 Creating Web App: $WebAppName" -ForegroundColor Yellow
$webapp = Get-AzWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName -ErrorAction SilentlyContinue
if (-not $webapp) {
    New-AzWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName -AppServicePlan $AppServicePlanName -RuntimeStack "DOTNETCORE|8.0"
    Write-Host "✅ Web App created successfully" -ForegroundColor Green
} else {
    Write-Host "ℹ️ Web App already exists" -ForegroundColor Blue
}

# Create Storage Account for blob storage tests
Write-Host "💾 Creating Storage Account: $StorageAccountName" -ForegroundColor Yellow
$storage = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -ErrorAction SilentlyContinue
if (-not $storage) {
    New-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -Location $Location -SkuName "Standard_LRS" -Kind "StorageV2"
    Write-Host "✅ Storage Account created successfully" -ForegroundColor Green
} else {
    Write-Host "ℹ️ Storage Account already exists" -ForegroundColor Blue
}

# Configure Web App settings
Write-Host "⚙️ Configuring Web App settings..." -ForegroundColor Yellow
$storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
$storageKey = (Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName)[0].Value
$connectionString = "DefaultEndpointsProtocol=https;AccountName=$StorageAccountName;AccountKey=$storageKey;EndpointSuffix=core.windows.net"

$appSettings = @{
    "ASPNETCORE_ENVIRONMENT" = "Production"
    "AzureStorage__ConnectionString" = $connectionString
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "WEBSITES_PORT" = "8080"
}

Set-AzWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName -AppSettings $appSettings
Write-Host "✅ Web App settings configured" -ForegroundColor Green

# Get publish profile for GitHub Actions
Write-Host "📋 Getting publish profile for GitHub Actions..." -ForegroundColor Yellow
$publishProfile = Get-AzWebAppPublishingProfile -ResourceGroupName $ResourceGroupName -Name $WebAppName -OutputFile null
Write-Host "✅ Publish profile retrieved" -ForegroundColor Green

Write-Host "
🎉 Azure infrastructure setup completed successfully!

📝 Next steps:
1. Add the following secrets to your GitHub repository:
   - AZURE_CREDENTIALS: Service principal credentials (see Azure docs)
   - AZURE_STATIC_WEB_APPS_API_TOKEN: Token for Static Web Apps (if using)

2. Your resources:
   - Resource Group: $ResourceGroupName
   - Web App: https://$WebAppName.azurewebsites.net
   - Storage Account: $StorageAccountName

3. Push your code to GitHub to trigger the deployment pipeline.

🔗 Useful links:
   - Azure Portal: https://portal.azure.com
   - Web App: https://$WebAppName.azurewebsites.net
" -ForegroundColor Green
