# Azure Speed Test - Production Deployment

This document describes the production-ready setup for deploying the Azure Speed Test application to Heroku.

## Architecture

- **Frontend**: Angular 18 with Server-Side Rendering (SSR)
- **Backend**: ASP.NET Core 8.0 Web API
- **Deployment**: Docker containers on Heroku
- **Database**: File-based configuration (JSON)

## Prerequisites

1. **Heroku CLI**: [Download and install](https://devcenter.heroku.com/articles/heroku-cli)
2. **Git**: Version control
3. **Docker**: For local testing (optional)

## Quick Deployment

### 1. Login to Heroku
```bash
heroku login
```

### 2. Create or Connect to Heroku App
```bash
# Create new app
heroku create your-app-name

# Or connect to existing app
heroku git:remote -a your-existing-app-name
```

### 3. Deploy Using PowerShell Script
```powershell
.\Deploy-Heroku.ps1
```

### 4. Manual Deployment (Alternative)
```bash
# Set stack to container
heroku stack:set container

# Set environment variables
heroku config:set ASPNETCORE_ENVIRONMENT=Production
heroku config:set NODE_ENV=production

# Deploy
git push heroku master

# Open application
heroku open
```

## Configuration

### Environment Variables

Set these in Heroku dashboard or CLI:

```bash
# Core configuration
heroku config:set ASPNETCORE_ENVIRONMENT=Production
heroku config:set NODE_ENV=production

# Azure Storage (optional)
heroku config:set AZURE_STORAGE_CONNECTION_STRING="your-connection-string"
heroku config:set AZURE_STORAGE_KEY="your-storage-key"

# Application Insights (optional)
heroku config:set APPLICATION_INSIGHTS_CONNECTION_STRING="your-ai-connection-string"
```

### File Structure

```
├── api/AzureSpeed/          # .NET Core Backend
│   ├── Program.cs           # Main application entry point
│   ├── appsettings.Production.json  # Production configuration
│   └── ...
├── ui/                      # Angular Frontend
│   ├── src/
│   ├── package.json
│   └── ...
├── Dockerfile              # Multi-stage build configuration
├── heroku.yml              # Heroku container configuration
├── Deploy-Heroku.ps1       # Deployment script
└── README.md               # This file
```

## Production Features

### ✅ Optimized Build Process
- Multi-stage Docker builds for minimal image size
- Angular production build with tree-shaking and minification
- .NET release build with optimizations
- Static file compression and caching

### ✅ Security & Performance
- HTTPS redirects (handled by Heroku)
- CORS configuration for multiple domains
- Security headers (HSTS)
- Health check endpoint (`/health`)

### ✅ Monitoring & Logging
- Application Insights integration
- Structured logging with different levels
- Health monitoring endpoint
- Error tracking and diagnostics

### ✅ Scalability
- Stateless application design
- Environment-specific configurations
- Resource-efficient Docker containers
- Horizontal scaling ready

## Monitoring

### Health Check
- **Endpoint**: `https://your-app.herokuapp.com/health`
- **Response**: `OK` (HTTP 200)

### Logs
```bash
# View recent logs
heroku logs --tail

# View specific number of lines
heroku logs -n 500

# Filter by source
heroku logs --source app
```

### Application Metrics
```bash
# Check dyno status
heroku ps

# Check configuration
heroku config

# Check app info
heroku apps:info
```

## Scaling

### Horizontal Scaling
```bash
# Scale up
heroku ps:scale web=2

# Scale down
heroku ps:scale web=1
```

### Vertical Scaling
```bash
# Upgrade to standard dynos
heroku ps:resize web=standard-1x

# Upgrade to performance dynos
heroku ps:resize web=performance-m
```

## Troubleshooting

### Common Issues

1. **Build Failures**
   - Check logs: `heroku logs --tail`
   - Verify Docker build locally: `docker build -t test .`

2. **Application Not Starting**
   - Check port binding in Program.cs
   - Verify environment variables: `heroku config`

3. **Static Files Not Loading**
   - Check wwwroot folder in Docker image
   - Verify static file middleware in Program.cs

4. **API Endpoints Not Working**
   - Check CORS configuration
   - Verify API routing in controllers

### Debug Commands

```bash
# Access bash in running container
heroku run bash

# Check file system
heroku run ls -la

# Check environment variables
heroku run env

# Restart application
heroku restart
```

## Performance Optimization

### Caching Strategy
- Static files cached for 1 year
- API responses cached appropriately
- Browser caching headers configured

### Build Optimization
- Multi-stage builds reduce image size
- Only production dependencies in final image
- Optimized Angular builds with dead code elimination

### Runtime Optimization
- Efficient .NET Core runtime
- Minimal Docker base images
- Resource-efficient Alpine Linux for Node.js build

## Security Considerations

### HTTPS
- Automatic HTTPS redirect
- HSTS headers for security
- SSL certificates managed by Heroku

### Environment Variables
- Sensitive data stored in environment variables
- No secrets in source code
- Production-specific configuration

### CORS Configuration
- Restricted origins for production
- Proper headers configuration
- API endpoint protection

## Maintenance

### Regular Updates
- Keep dependencies updated
- Monitor security advisories
- Update Docker base images

### Backup Strategy
- Source code in Git repository
- Environment variables documented
- Configuration files versioned

### Monitoring
- Set up alerts for application errors
- Monitor application performance
- Track usage metrics

## Support

### Resources
- [Heroku Documentation](https://devcenter.heroku.com/)
- [ASP.NET Core Documentation](https://docs.microsoft.com/aspnet/core)
- [Angular Documentation](https://angular.io/docs)

### Getting Help
- Check application logs first
- Review Heroku status page
- Consult framework documentation
- Contact support if needed

---

**Last Updated**: July 2025  
**Version**: 1.0.0  
**Environment**: Production
