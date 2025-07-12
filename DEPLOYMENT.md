# Azure Speed Test - Deployment Guide

## Environment Variables

The following environment variables need to be set in your deployment environment:

### Azure Storage Configuration
- `AZURE_STORAGE_KEY`: Your Azure Storage Account Access Key
- `AZURE_STORAGE_CONNECTION_STRING`: Full connection string for Azure Storage

### Example Values (replace with your actual values):
```
AZURE_STORAGE_KEY=your_actual_storage_key_here
AZURE_STORAGE_CONNECTION_STRING=DefaultEndpointsProtocol=https;AccountName=azurespeedteststorage;AccountKey=YOUR_KEY_HERE;EndpointSuffix=core.windows.net
```

## GitHub Actions Secrets

Add the following secrets to your GitHub repository:

1. `AZURE_STORAGE_KEY`
2. `AZURE_STORAGE_CONNECTION_STRING`
3. `AZURE_WEBAPP_PUBLISH_PROFILE` (if using Web App deployment)

## Local Development

For local development, create a `settings.json` file in `api/AzureSpeed/Data/` with your actual credentials:

```json
{
    "accounts": [
        {
            "key": "YOUR_ACTUAL_STORAGE_KEY",
            "name": "azurespeedteststorage",
            "locationId": "japanwest"
        }
    ]
}
```

**Note**: The `settings.json` file is excluded from version control for security reasons.

## Deployment Process

1. Set environment variables in your deployment platform
2. The application will automatically replace placeholders in configuration files
3. Deploy using the provided GitHub Actions workflow or Docker container
