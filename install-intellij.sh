# Host-side installer for IntelliJ (stores into ide/idea)
INTELLIJ_VERSION="${1:-${INTELLIJ_VERSION:-latest}}"
IDE_DIR="ide/idea"
# Will compute TMPFILE (download path) after resolving the download URL so
# the filename includes the released archive name/version and is stored in CWD.
DOWNLOAD_DIR="${PWD}"



has_jq() { command -v jq >/dev/null 2>&1; }

get_from_api() {
    local api json url
    api="https://data.services.jetbrains.com/products?code=IIC"
    json=$(curl -fsS "$api" || return 1)
    if has_jq; then
        url=$(echo "$json" | jq -r '
            .IIC[0].releases[0].downloads.linux.link //
            .IIC[0].releases[0].downloads.find(.platform=="linux")?.link //
            .IIC[0].downloads.linux.link // empty
        ' 2>/dev/null || true)
        if [ -n "$url" ] && [ "$url" != "null" ]; then
            echo "$url"
            return 0
        fi
        url=$(echo "$json" | jq -r '.. | objects | .link? // empty' 2>/dev/null | grep -E 'ideaIC.*\.tar\.gz|/idea/.*tar\.gz' | head -n1 || true)
        if [ -n "$url" ]; then
            echo "$url"
            return 0
        fi
    fi
    
    # Fallback when `jq` is not installed (or jq lookups failed): try multiple text-based extractions
    # 1) Prefer extracting the explicit "linux" -> "link" value using the provided pattern
    # Use a robust sed pattern that finds the IIC release block and captures the linux.link value
        url=$(echo "$json" | grep -oP '(?s)"code":"IIC".*?"type":"release".*?"downloads":\{.*?"linux":\{.*?"link":"\K[^\"]+' | head -n1 || true)
    if [ -n "$url" ]; then
        if echo "$url" | grep -q '^/'; then
            url="https://download.jetbrains.com${url}"
        fi
        echo "$url"
        return 0
    fi

    return 1
}

get_latest_url() {
    if [ "$INTELLIJ_VERSION" != "latest" ]; then
        echo "https://download.jetbrains.com/idea/${INTELLIJ_VERSION}.tar.gz"
        return 0
    fi
    if url=$(get_from_api); then
        echo "$url"
        return 0
    fi
    return 1
}

download_and_extract() {
    local url="$1"
    echo "Using URL: $url"
    if ! curl -fsS -I "$url" >/dev/null 2>&1; then
        echo "ERROR: download URL not reachable: $url" >&2
        return 1
    fi
    echo "Downloading to: $TMPFILE"
    curl -fsSL "$url" -o "$TMPFILE"
    echo "Extracting to ${IDE_DIR}..."
    tar -vxzf "$TMPFILE" --strip-components=1 -C "$IDE_DIR"
    # Keep the downloaded archive in the current directory for reuse
}

URL=$(get_latest_url) || { echo "Could not determine IntelliJ download URL"; exit 1; }

# Normalize URL if it is a relative path returned from API
if echo "$URL" | grep -q '^/'; then
    URL="https://download.jetbrains.com${URL}"
fi

# Derive filename from URL (strip query string) and set TMPFILE in current dir
BASENAME=$(basename "${URL%%\?*}")
FILENAME="$BASENAME"
TMPFILE="${DOWNLOAD_DIR}/${FILENAME}"

echo "Resolved download file: $FILENAME"

# Only download/extract if the target directory is empty or the user agrees to delete it
if [ -d "$IDE_DIR" ] && [ "$(ls -A "$IDE_DIR" 2>/dev/null)" ]; then
    read -p "${IDE_DIR} already exists and is not empty. Delete and reinstall? (y/n) [default y] " delete_ide
    delete_ide=${delete_ide:-y}
    if [ "$delete_ide" = "y" ]; then
        rm -rf "${IDE_DIR}"/*
        mkdir -p "$IDE_DIR"
    else
        echo "Installation cancelled by user."
        exit 1
    fi
else
    mkdir -p "$IDE_DIR"
fi

if [ -f "$TMPFILE" ]; then
    # Ask user whether to delete and re-download or reuse existing file
    read -p "$FILENAME already exists. Do you want to delete it? (y/n) [default n] " delete_archive
    delete_archive=${delete_archive:-n}
    if [ "$delete_archive" = "y" ]; then
        rm -f -- "$TMPFILE"
        download_and_extract "$URL"
    else
        echo "Re-using existing $FILENAME"
        echo "Extracting to ${IDE_DIR}..."
        tar -vxzf "$TMPFILE" --strip-components=1 -C "$IDE_DIR"
    fi
else
    download_and_extract "$URL"
fi

echo "Build container image and generate users.list (if needed)"
./build.sh

echo "Installation complete. To start IntelliJ use: ./start.sh intellij"