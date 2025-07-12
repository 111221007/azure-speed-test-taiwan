#!/usr/bin/env node

const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');

console.log('Starting build process...');

// Ensure we're in the correct directory
const rootDir = process.cwd();
console.log('Root directory:', rootDir);

// Change to UI directory
const uiDir = path.join(rootDir, 'ui');
console.log('UI directory:', uiDir);

if (!fs.existsSync(uiDir)) {
    console.error('UI directory not found:', uiDir);
    process.exit(1);
}

process.chdir(uiDir);

console.log('Installing UI dependencies...');
exec('npm install', { maxBuffer: 1024 * 1024 * 10 }, (error, stdout, stderr) => {
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
        
        console.log('Build output:', stdout);
        console.log('Angular build completed successfully!');
        
        // Change back to root directory
        process.chdir(rootDir);
        console.log('Build process completed successfully!');
        process.exit(0);
    });
});
