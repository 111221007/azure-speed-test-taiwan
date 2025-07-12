# Heroku Deployment Guide

## Prerequisites
1. Heroku CLI installed
2. Git repository connected to Heroku

## Deployment Steps

### 1. Set Environment Variables
```bash
heroku config:set AZURE_STORAGE_KEY=your_actual_storage_key_here
heroku config:set AZURE_STORAGE_CONNECTION_STRING="DefaultEndpointsProtocol=https;AccountName=azurespeedteststorage;AccountKey=your_key_here;EndpointSuffix=core.windows.net"
```

### 2. Add Buildpacks
```bash
# Add Node.js buildpack for Angular frontend
heroku buildpacks:add heroku/nodejs

# Add .NET buildpack for backend
heroku buildpacks:add heroku-community/dotnet-core
```

### 3. Deploy
```bash
git add .
git commit -m "Configure for Heroku deployment"
git push heroku main
```

## Alternative: Container Deployment

If you prefer container deployment:

```bash
# Set stack to container
heroku stack:set container

# Deploy using Docker
git push heroku main
```

## Environment Configuration

The application will automatically use environment variables:
- `AZURE_STORAGE_KEY`: Your Azure Storage Account key
- `AZURE_STORAGE_CONNECTION_STRING`: Full Azure Storage connection string
- `PORT`: Automatically set by Heroku

## Troubleshooting

1. **Build fails**: Check that both Node.js and .NET buildpacks are added
2. **App crashes**: Check Heroku logs with `heroku logs --tail`
3. **CORS issues**: Ensure your frontend domain is added to CORS configuration
