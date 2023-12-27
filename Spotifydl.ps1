param (
    [string]$arg
)

# If no argument is passed, use the default value from the config.json file
if ($null -eq $arg -or $arg -eq "") {
    # Read the config.json file and convert it to a PowerShell object
    $config = Get-Content -Path "./config.json" | ConvertFrom-Json

    # Get the defaultPlaylist value
    $defaultPlaylist = $config.defaultPlaylist

    # If the defaultPlaylist value is not null or empty, use it as the default value
    if (![string]::IsNullOrEmpty($defaultPlaylist)) {
        $arg = $defaultPlaylist
    }
    else {
        $arg = "https://open.spotify.com/album/4ma7FIZ99q6QIOXTMMnk58?si=Ad8c4-uuRsqQIMUjmx_5gA"
    }
}

# Get the path to the desktop
$desktopPath = [Environment]::GetFolderPath("Desktop")

# Define the output folder path
$outputFolderPath = Join-Path -Path $desktopPath -ChildPath "output"

# Check if the output folder exists
if (Test-Path -Path $outputFolderPath) {
    # Clear the output folder
    Remove-Item -Path "$outputFolderPath\*" -Recurse -Force
}
else {
    # Create the output folder
    New-Item -Path $outputFolderPath -ItemType Directory | Out-Null
}

# Check if ffmpeg is installed and in the system's PATH
try {
    $ffmpeg = Get-Command ffmpeg -ErrorAction Stop
}
catch {
    Write-Host "ffmpeg is not installed or not in the system's PATH. Trying to install it using winget..."

    # Check if winget is installed
    try {
        $winget = Get-Command winget -ErrorAction Stop
    }
    catch {
        Write-Host "winget is not installed. Please install winget and then run this script again."
        exit 1
    }

    # Install ffmpeg using winget
    & $winget install ffmpeg
}

# Check if Node.js is installed and in the system's PATH
try {
    $node = Get-Command node -ErrorAction Stop
}
catch {
    Write-Host "Node.js is not installed or not in the system's PATH. Trying to install it using winget..."

    # Check if winget is installed
    try {
        $winget = Get-Command winget -ErrorAction Stop
    }
    catch {
        Write-Host "winget is not installed. Please install winget and then run this script again."
        exit 1
    }

    # Install Node.js using winget
    & $winget install nodejs
}

# Check if spotify-dl is installed
try {
    $spotifydl = Get-Command spotifydl -ErrorAction Stop
}
catch {
    Write-Host "spotify-dl is not installed. Trying to install it using npm..."

    # Install spotify-dl using npm
    & $node/npm install -g spotify-dl
}

# Execute the spotifydl command
& $spotifydl --l --o $outputFolderPath $arg