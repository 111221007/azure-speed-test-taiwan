#!/bin/bash

echo "Starting Heroku build process..."

# Navigate to UI directory and build Angular app
echo "Building Angular frontend..."
cd ui

# Install dependencies
npm install

# Build the Angular app
./node_modules/.bin/ng build --configuration production

echo "Angular build completed successfully!"

# Copy built files to a location where .NET can serve them
echo "Copying built files..."
cd ..

echo "Build process completed!"
