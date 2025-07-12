#!/usr/bin/env node

const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');

console.log('Starting build process...');

// Ensure we're in the correct directory
const rootDir = process.cwd();
console.log('Root directory:', rootDir);

// Step 1: Build Angular frontend
const uiDir = path.join(rootDir, 'ui');
console.log('UI directory:', uiDir);

if (!fs.existsSync(uiDir)) {
    console.error('UI directory not found:', uiDir);
    process.exit(1);
}

process.chdir(uiDir);

console.log('Installing UI dependencies...');
exec('npm ci --omit=dev', { maxBuffer: 1024 * 1024 * 10 }, (error, stdout, stderr) => {
    if (error) {
        console.error('Error installing UI dependencies:', error);
        console.error('stderr:', stderr);
        process.exit(1);
    }
    
    console.log('UI dependencies installed successfully');
    console.log('Building Angular application...');
    
    // Build Angular app using npx
    exec('npx ng build --configuration production', { maxBuffer: 1024 * 1024 * 10 }, (error, stdout, stderr) => {
        if (error) {
            console.error('Error building Angular app:', error);
            console.error('stderr:', stderr);
            process.exit(1);
        }
        
        console.log('Angular build completed successfully!');
        
        // Step 2: Build .NET backend
        console.log('Building .NET backend...');
        
        // Change to API directory
        const apiDir = path.join(rootDir, 'api', 'AzureSpeed');
        console.log('API directory:', apiDir);
        
        if (!fs.existsSync(apiDir)) {
            console.error('API directory not found:', apiDir);
            process.exit(1);
        }
        
        process.chdir(apiDir);
        
        // Build and publish .NET app
        exec('dotnet publish -c Release -o out', { maxBuffer: 1024 * 1024 * 10 }, (error, stdout, stderr) => {
            if (error) {
                console.error('Error building .NET app:', error);
                console.error('stderr:', stderr);
                process.exit(1);
            }
            
            console.log('Build output:', stdout);
            console.log('.NET build completed successfully!');
            
            // Change back to root directory
            process.chdir(rootDir);
            console.log('Complete build process finished successfully!');
            process.exit(0);
        });
    });
});
