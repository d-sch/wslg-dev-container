#!/bin/bash


echo "Fetching the latest Cursor download URL..."
# Use curl to get the JSON response and jq to extract the downloadUrl field
CODE_URL=$(curl -I 'https://code.visualstudio.com/sha/download?build=stable&os=linux-x64' -o /dev/null -sw %header{location})

# Extract the version from the URL until first - using sed
# Example CURSOR_URL=location
# https://vscode.download.prss.microsoft.com/dbazure/download/stable/bf9252a2fb45be6893dd8870c0bf37e2e1766d61/code-stable-x64-1764110803.tar.gz
# Example CURSOR_VERSION=Cursor-0.46.11
CODE_VERSION=$(echo $CODE_URL | sed -n 's/.*\/\([^\/]*\-[0-9]*\.*\)/\1/p')

if [ -z "$CODE_URL" ] || [ "$CODE_URL" == "null" ]; then
  echo "Error: Failed to get download URL."
  exit 1
fi

echo "Download URL: $CODE_URL"
echo "Download Version: $CODE_VERSION"

# function to download $code_version
function download_code {
    echo "Downloading Visual Studio Code"
    curl -L "$CODE_URL" -o "$CODE_VERSION"
}

# Check if directory ide/ exists
ide_directory="ide/code/"

# Check that ide is not root directory and relative to current directory and inside ide directory and ends with slash
if [ "$ide_directory" == "/" ] || [[ "$ide_directory" != ide/* ]] || [[ "$ide_directory" != */ ]]; then
    echo "Error: ide_directory must be a relative path and not root directory and must end with a slash"
    exit 1
fi


if [ -d "$ide_directory" ]; then 
    #ask user if they want to delete the existing ide/ directory
    read -p "$ide_directory directory already exists. Do you want to delete it? (y/n) [y]" delete_ide
    delete_ide=${delete_ide:-y}
    if [ $delete_ide == "y" ]; then
        rm -rf -- "$ide_directory"
    else
        echo "Installation cancelled by user."
        exit 1
    fi
fi

if [ ! -d "$ide_directory" ]; then
    mkdir -p "$ide_directory"
fi

# Check if idea.tar.gz exists and if so, delete it
if [ -f "$CODE_VERSION" ]; then
    # ask user if they want to delete the existing idea tar.gz file
    read -p "Visual Studio code download already exists. Do you want to delete it? (y/n) [default n] " delete_code
    delete_code=${delete_code:-n}
    if [ $delete_code == "y" ]; then
        rm "$CODE_VERSION"
        # download the latest version of VS Code
        download_code
    else
        # re-use the existing tar.gz file
        echo "Re-using existing $CODE_VERSION"
    fi
else
    # download the latest version of VS Code
    download_code    
fi

tar -vxzf "$CODE_VERSION" --strip-components=1 -C "$ide_directory"

echo "Build container image and generate users.list (if needed)"
./build.sh

echo "Installation complete. To start VS Code use: ./start.sh code"