# Azure Speed Test - Heroku Deployment Guide

This guide explains how to deploy the Azure Speed Test application to Heroku.

## Prerequisites

1. Heroku CLI installed
2. Git repository
3. Node.js and npm
4. .NET 8.0 SDK

## Deployment Steps

### 1. Install Heroku CLI
```bash
# Download and install from https://devcenter.heroku.com/articles/heroku-cli
```

### 2. Login to Heroku
```bash
heroku login
```

### 3. Create a Heroku App
```bash
heroku create azure-speed-test-taiwan
```

### 4. Set Environment Variables
```bash
# Set production environment
heroku config:set ASPNETCORE_ENVIRONMENT=Production
heroku config:set NODE_ENV=production

# Set Azure Storage credentials (if needed)
heroku config:set AZURE_STORAGE_CONNECTION_STRING="your-connection-string"
heroku config:set AZURE_STORAGE_KEY="your-storage-key"
```

### 5. Configure Build Stack
```bash
# Use container stack for Docker deployment
heroku stack:set container

# Or use buildpacks
heroku buildpacks:add heroku/nodejs
heroku buildpacks:add heroku/dotnet
```

### 6. Deploy to Heroku
```bash
# Push to Heroku
git push heroku master

# Or push from a different branch
git push heroku your-branch:master
```

### 7. Scale the Application
```bash
heroku ps:scale web=1
```

### 8. Open the Application
```bash
heroku open
```

## Configuration Files

### package.json
- Contains Node.js dependencies and build scripts
- `heroku-postbuild` script runs after npm install

### heroku.yml
- Defines the Docker build and run configuration
- Uses the Dockerfile for building the application

### Procfile
- Defines how to run the application
- Points to the compiled .NET application

### Dockerfile
- Multi-stage build for both Angular and .NET
- Uses nginx to serve static files
- Runs both frontend and backend

## Build Process

1. **Frontend Build**: Angular application is built using `ng build --configuration production`
2. **Backend Build**: .NET application is compiled using `dotnet publish -c Release`
3. **Docker Build**: Both applications are combined in a Docker container

## Environment Variables

- `PORT`: Automatically set by Heroku
- `ASPNETCORE_ENVIRONMENT`: Set to "Production"
- `NODE_ENV`: Set to "production"
- `AZURE_STORAGE_CONNECTION_STRING`: Azure Storage connection string
- `AZURE_STORAGE_KEY`: Azure Storage account key

## Monitoring

- View logs: `heroku logs --tail`
- Check dyno status: `heroku ps`
- Monitor metrics: `heroku addons:create heroku-postgresql:hobby-dev`

## Troubleshooting

1. **Build Failures**: Check logs with `heroku logs --tail`
2. **Port Issues**: Ensure application listens on `process.env.PORT`
3. **Static Files**: Verify Angular build outputs are properly served

## Custom Domains

```bash
# Add custom domain
heroku domains:add your-domain.com

# Configure DNS
# Add CNAME record pointing to your-app.herokuapp.com
```

## SSL Certificate

```bash
# Enable automatic SSL
heroku certs:auto:enable
```

## Database (if needed)

```bash
# Add PostgreSQL
heroku addons:create heroku-postgresql:hobby-dev

# Get connection string
heroku config:get DATABASE_URL
```

## Scaling

```bash
# Scale dynos
heroku ps:scale web=2

# Upgrade dyno type
heroku ps:resize web=standard-1x
```

## Production Checklist

- [ ] Environment variables set
- [ ] SSL certificate configured
- [ ] Custom domain configured (if applicable)
- [ ] Monitoring enabled
- [ ] Database configured (if needed)
- [ ] Backup strategy in place
- [ ] Error tracking enabled
- [ ] Performance monitoring enabled

## Support

For issues with deployment, check:
1. Heroku logs: `heroku logs --tail`
2. Build logs: `heroku builds`
3. Application health: `heroku ps`
4. Configuration: `heroku config`

1. **Build fails**: Check that both Node.js and .NET buildpacks are added
2. **App crashes**: Check Heroku logs with `heroku logs --tail`
3. **CORS issues**: Ensure your frontend domain is added to CORS configuration
