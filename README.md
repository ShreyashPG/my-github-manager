
# My GitHub Manager - Script Runner

This project allows you to execute the `my-github-manager` package script in your project by importing and using a reusable function.

## Setup Instructions

### 1. Import and Use the Function
In your main file (e.g., `index.js`), add the following code:

```javascript
const runMyGithubManager = require('my-github-manager/runMyGithubManager');

// Call the function
runMyGithubManager()
    .then((output) => {
        console.log(`Script executed successfully: ${output}`);
    })
    .catch((error) => {
        console.error(`Script execution failed: ${error}`);
    });
```

## Prerequisites
- Ensure you have installed the `my-github-manager` package in your project:
  ```bash
  npm install my-github-manager
  ```
- Make sure `bash` is available on your system. For Windows, you can use:
  - [WSL (Windows Subsystem for Linux)](https://learn.microsoft.com/en-us/windows/wsl/install) or
  - [Git Bash](https://git-scm.com/).

## Additional Notes
- The function is designed to be reusable and handles errors gracefully using Promises.
- The script's path is dynamically resolved using `path.resolve` for cross-platform compatibility.
