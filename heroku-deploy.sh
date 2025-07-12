#!/bin/bash

# Heroku deployment script
echo "Starting Heroku deployment..."

# Set environment variables
export ASPNETCORE_ENVIRONMENT=Production
export NODE_ENV=production

# Clean previous builds (if any)
rm -rf ui/dist
rm -rf api/AzureSpeed/out

# Build the application
node build.js

if [ $? -eq 0 ]; then
    echo "Build completed successfully!"
else
    echo "Build failed!"
    exit 1
fi

echo "Deployment preparation complete!"
