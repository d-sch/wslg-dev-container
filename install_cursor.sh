#!/bin/bash

echo "Fetching the latest Cursor download URL..."
# Use curl to get the JSON response and jq to extract the downloadUrl field
CURSOR_URL=$(curl -s "https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=latest" | sed -n 's/.*"downloadUrl":"\([^"]*\)".*/\1/p')

# Extract the version from the URL until first - using sed
# Example CURSOR_URL=https://anysphere-binaries.s3.us-east-1.amazonaws.com/production/client/linux/x64/appimage/Cursor-0.46.11-ae378be9dc2f5f1a6a1a220c6e25f9f03c8d4e19.deb.glibc2.25-x86_64.AppImage
# Example CURSOR_VERSION=Cursor-0.46.11
CURSOR_VERSION=$(echo $CURSOR_URL | sed -n 's/.*\/\([^\/]*\.[0-9]*\.[0-9]*\).*/\1/p')

if [ -z "$CURSOR_URL" ] || [ "$CURSOR_URL" == "null" ]; then
  echo "Error: Failed to get download URL."
  exit 1
fi

echo "Download URL: $CURSOR_URL"
echo "Download Version: $CURSOR_VERSION"

# function to download $CURSOR_VERSION
function download_cursor {
    echo "Downloading Cursor"
    curl -L "$CURSOR_URL" -o "$CURSOR_VERSION"
}

# Check if directory ide/ exists
if [ ! -d "ide" ]; then
    mkdir ide
else 
    #ask user if they want to delete the existing ide/ directory
    read -p "ide/ directory already exists. Do you want to delete it? (y/n) [y]" delete_ide
    delete_ide=${delete_ide:-y}
    if [ $delete_ide == "y" ]; then
        rm -rf ide/*
    else
        echo "Installation cancelled by user."
        exit 1
    fi
fi

# Check if idea.tar.gz exists and if so, delete it
if [ -f "$CURSOR_VERSION" ]; then
    # ask user if they want to delete the existing idea tar.gz file
    read -p "$CURSOR_VERSION download already exists. Do you want to delete it? (y/n) [default n] " delete_cursor
    delete_cursor=${delete_cursor:-n}
    if [ $delete_cursor == "y" ]; then
        rm $CURSOR_VERSION
        # download the latest version 
        download_cursor
    else
        # re-use the existing file
        echo "Re-using existing $CURSOR_VERSION"
    fi
else
    # download the latest version
    download_cursor   
fi

cp $CURSOR_VERSION ide/cursor
chmod +x ide/cursor
(cd ide && ./cursor --appimage-extract && rm cursor && mv squashfs-root/* . && rm -r squashfs-root)

# Check if docker-compose.yml exists and if so, delete it
if [ -f "docker-compose.override.yml" ]; then
    rm docker-compose.override.yml
fi

cp docker-compose.cursor.override.yml docker-compose.override.yml

# Check if file start.sh exists and if so, delete it
if [ -f "start.sh" ]; then
    rm start.sh
fi

./build.sh

# cp start_cursor.sh start.sh