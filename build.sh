#!/bin/bash

echo "Building Azure Speed Test for Heroku..."

# Build Angular frontend
echo "Building Angular frontend..."
cd ui
npm install
npm run build:prod
cd ..

# Build .NET backend
echo "Building .NET backend..."
cd api/AzureSpeed
dotnet restore
dotnet publish -c Release -o out
cd ../..

echo "Build completed successfully!"
