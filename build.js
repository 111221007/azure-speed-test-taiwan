#!/usr/bin/env node

const { exec } = require('child_process');
const path = require('path');

console.log('Starting build process...');

// Change to UI directory
process.chdir('ui');

console.log('Installing UI dependencies...');
exec('npm install', (error, stdout, stderr) => {
    if (error) {
        console.error('Error installing UI dependencies:', error);
        process.exit(1);
    }
    
    console.log('UI dependencies installed successfully');
    console.log('Building Angular application...');
    
    // Build Angular app using npx
    exec('npx ng build --configuration production', (error, stdout, stderr) => {
        if (error) {
            console.error('Error building Angular app:', error);
            console.error('stderr:', stderr);
            process.exit(1);
        }
        
        console.log('Build output:', stdout);
        console.log('Angular build completed successfully!');
        process.exit(0);
    });
});
