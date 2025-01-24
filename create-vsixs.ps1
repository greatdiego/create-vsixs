param (
    [string]$ExtensionPath,
    [switch]$Debug
)

# Check if the provided path exists
if (-Not (Test-Path $ExtensionPath)) {
    Write-Host "The specified path does not exist: $ExtensionPath" -ForegroundColor Red
    exit 1
}

# Get the absolute path of the execution directory
$ExecutionPath = (Get-Location).Path

if ($Debug) {
    Write-Host "Debug: Execution path is $ExecutionPath" -ForegroundColor Yellow
}

# Iterate over each directory in the provided path
Get-ChildItem -Path $ExtensionPath -Directory | ForEach-Object {
    $Dir = $_
    $DirName = $Dir.Name

    if ($Debug) {
        Write-Host "Debug: Processing directory $DirName" -ForegroundColor Yellow
    }

    # Define paths for the temporary "extensions" directory and the ZIP/VSIX file
    $TempPath = Join-Path $ExecutionPath "extensions"
    $NestedExtensionPath = Join-Path $TempPath "extension"
    $ZipFilePath = Join-Path $ExecutionPath "$DirName.zip"
    $VsixFilePath = Join-Path $ExecutionPath "$DirName.vsix"

    if ($Debug) {
        Write-Host "Debug: Temporary path is $TempPath" -ForegroundColor Yellow
        Write-Host "Debug: Nested extension path is $NestedExtensionPath" -ForegroundColor Yellow
        Write-Host "Debug: ZIP file path is $ZipFilePath" -ForegroundColor Yellow
        Write-Host "Debug: VSIX file path is $VsixFilePath" -ForegroundColor Yellow
    }

    # Create the temporary "extensions/extension" directory
    if (-Not (Test-Path $NestedExtensionPath)) {
        New-Item -ItemType Directory -Path $NestedExtensionPath -Force | Out-Null
        if ($Debug) {
            Write-Host "Debug: Created nested directory $NestedExtensionPath" -ForegroundColor Yellow
        }
    }

    # Copy the contents of the directory to the temporary "extensions/extension" folder
    Copy-Item -Path "$($Dir.FullName)\*" -Destination $NestedExtensionPath -Recurse
    if ($Debug) {
        Write-Host "Debug: Copied contents of $($Dir.FullName) to $NestedExtensionPath" -ForegroundColor Yellow
    }

    # Compress the "extensions" folder into a ZIP file
    Compress-Archive -Path "$TempPath\*" -DestinationPath $ZipFilePath -Force
    if ($Debug) {
        Write-Host "Debug: Compressed $TempPath into $ZipFilePath" -ForegroundColor Yellow
    }

    # Remove the existing VSIX file if it exists
    if (Test-Path $VsixFilePath) {
        Remove-Item -Path $VsixFilePath -Force
        if ($Debug) {
            Write-Host "Debug: Removed existing VSIX file $VsixFilePath" -ForegroundColor Yellow
        }
    }

    # Rename the ZIP file to VSIX
    Rename-Item -Path $ZipFilePath -NewName "$DirName.vsix" -Force
    if ($Debug) {
        Write-Host "Debug: Renamed $ZipFilePath to $VsixFilePath" -ForegroundColor Yellow
    }

    # Remove the temporary "extensions" directory
    Remove-Item -Path $TempPath -Recurse -Force
    if ($Debug) {
        Write-Host "Debug: Removed temporary directory $TempPath" -ForegroundColor Yellow
    }

    Write-Host "Created VSIX file: $VsixFilePath" -ForegroundColor Green
}

Write-Host "All VSIX files have been created." -ForegroundColor Cyan
