#!/bin/bash

# function to download $intellij_version
function download_intellij {
    echo "Downloading Visual Studio Code"
    curl -L 'https://code.visualstudio.com/sha/download?build=stable&os=linux-x64' -o 'code.tar.gz'
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
if [ -f "code.tar.gz" ]; then
    # ask user if they want to delete the existing idea tar.gz file
    read -p "Visual Studio code download already exists. Do you want to delete it? (y/n) [default n] " delete_code
    delete_code=${delete_code:-n}
    if [ $delete_code == "y" ]; then
        rm code.tar.gz
        # download the latest version of IntelliJ IDEA
        download_intellij
    else
        # re-use the existing tar.gz file
        echo "Re-using existing $intellij_version"
    fi
else
    # download the latest version of IntelliJ IDEA
    download_intellij    
fi

tar -xzf code.tar.gz --strip-components=1 -C ide/

# Check if docker-compose.yml exists and if so, delete it
if [ -f "docker-compose.override.yml" ]; then
    rm docker-compose.override.yml
fi

cp docker-compose.vscode.override.yml docker-compose.override.yml

# Check if file start.sh exists and if so, delete it
if [ -f "start.sh" ]; then
    rm start.sh
fi

./build.sh

cp start_code.sh start.sh