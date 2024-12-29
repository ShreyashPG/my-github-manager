const { exec } = require('child_process');
const path = require('path');

// Define the function to run the package
function runMyGithubManager() {
    return new Promise((resolve, reject) => {
        // Path to the script
        const scriptPath = path.resolve(__dirname, 'node_modules/my-github-manager/my-github-manager.sh');

        // Execute the script
        exec(`bash ${scriptPath}`, (error, stdout, stderr) => {
            if (error) {
                reject(`Error executing the script: ${error.message}`);
                return;
            }
            if (stderr) {
                reject(`stderr: ${stderr}`);
                return;
            }
            resolve(stdout);
        });
    });
}

// Export the function
module.exports = runMyGithubManager;
