# Create Offline Installable VSIXs from VSCode

Microsoft has removed the download link from plugins within the VSCode marketplace.

This powershell script will package installed VSCode plugins for offline installation.

1. Run this script.

```
powershell -executionpolicy bypass create-vsixs.ps1 ~/.vscode/extensions
```

2. Install the VSIXs to your offline installation of VSCode.