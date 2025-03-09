#!/bin/bash
intellij_version="ideaIC-2024.3.4.1"

# function to download $intellij_version
function download_intellij {
    echo "Downloading IntelliJ IDEA"
    curl -L "https://download.jetbrains.com/idea/$intellij_version.tar.gz" -o "$intellij_version.tar.gz"
}

# Check if directory ide/ exists
if [ ! -d "ide" ]; then
    mkdir ide
else 
    #ask user if they want to delete the existing ide/ directory
    read -p "ide/ directory already exists. Do you want to delete it? (y/n) [default y] " delete_ide
    delete_ide=${delete_ide:-y}
    if [ $delete_ide == "y" ]; then
        rm -Rf ide/*
    else
        echo "Installation cancelled by user."
        exit 1
    fi
fi

# Check if a version was passed as an argument
if [ "$1" ]; then
    intellij_version=$1
fi

# Check if idea.tar.gz exists and if so, delete it
if [ -f "$intellij_version.tar.gz" ]; then
    # ask user if they want to delete the existing idea tar.gz file
    read -p "$intellij_version download already exists. Do you want to delete it? (y/n) [default n] " delete_idea
    delete_idea=${delete_idea:-n}
    if [ $delete_idea == "y" ]; then
        rm $intellij_version.tar.gz
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

tar -xzf $intellij_version.tar.gz --strip-components=1 -C ide/

# Check if docker-compose.yml exists and if so, delete it
if [ -f "docker-compose.override.yml" ]; then
    rm docker-compose.override.yml
fi

cp docker-compose.idea.override.yml docker-compose.override.yml

# Check if file start.sh exists and if so, delete it
if [ -f "start.sh" ]; then
    rm start.sh
fi

./build.sh

cp start_intellij.sh start.sh