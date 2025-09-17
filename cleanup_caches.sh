#!/bin/bash

# Script to clean up existing caches and free disk space for WanGP

echo "WanGP Cache Cleanup and Migration Script"
echo "========================================"

# Function to get directory size
get_size() {
    if [ -d "$1" ]; then
        du -sh "$1" 2>/dev/null | cut -f1
    else
        echo "0B"
    fi
}

# Function to safely move directory if it exists and has content
safe_move() {
    local src="$1"
    local dst="$2"
    
    if [ -d "$src" ] && [ "$(ls -A "$src" 2>/dev/null)" ]; then
        echo "Moving $src ($(get_size "$src")) to $dst"
        mkdir -p "$(dirname "$dst")"
        mv "$src" "$dst" 2>/dev/null || {
            echo "Failed to move $src, copying instead..."
            cp -r "$src" "$dst" 2>/dev/null && rm -rf "$src"
        }
    else
        echo "Skipping $src (empty or doesn't exist)"
    fi
}

# Create target directory structure
echo "Creating cache directory structure in /home/caches..."
mkdir -p /home/caches/{huggingface,torch,pip,transformers,datasets,gradio,tmp}

# Common cache locations to check and migrate
declare -A cache_locations=(
    ["~/.cache/huggingface"]="/home/caches/huggingface"
    ["~/.cache/torch"]="/home/caches/torch"
    ["~/.cache/pip"]="/home/caches/pip"
    ["~/.cache/transformers"]="/home/caches/transformers"
    ["~/.cache/huggingface_hub"]="/home/caches/huggingface/hub"
    ["/root/.cache/huggingface"]="/home/caches/huggingface"
    ["/root/.cache/torch"]="/home/caches/torch"
    ["/root/.cache/pip"]="/home/caches/pip"
    ["/root/.cache/transformers"]="/home/caches/transformers"
    ["/tmp"]="/home/caches/tmp"
)

echo ""
echo "Checking for existing cache directories to migrate..."

# Migrate existing caches
for src_pattern in "${!cache_locations[@]}"; do
    # Expand tilde
    src=$(eval echo "$src_pattern")
    dst="${cache_locations[$src_pattern]}"
    
    if [ -d "$src" ]; then
        echo "Found: $src ($(get_size "$src"))"
        # Only migrate if destination doesn't exist or is smaller
        if [ ! -d "$dst" ] || [ $(du -s "$src" 2>/dev/null | cut -f1) -gt $(du -s "$dst" 2>/dev/null | cut -f1) ]; then
            safe_move "$src" "$dst"
        else
            echo "Destination $dst already exists and is larger, removing source..."
            rm -rf "$src"
        fi
    fi
done

echo ""
echo "Cleaning up other temporary and cache directories..."

# Clean up other temporary directories that might be using space
temp_dirs=(
    "/tmp/gradio"
    "/tmp/transformers"
    "/tmp/torch"
    "/var/tmp"
    "/workspace/Wan2GP/venv_wan2gp/lib/python3.10/site-packages/__pycache__"
)

for dir in "${temp_dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo "Cleaning $dir ($(get_size "$dir"))"
        rm -rf "$dir"/*
    fi
done

# Clean Python cache files
echo "Cleaning Python cache files..."
find /workspace/Wan2GP -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null
find /workspace/Wan2GP -name "*.pyc" -delete 2>/dev/null

echo ""
echo "Cache cleanup and migration completed!"
echo "New cache structure:"
echo "  /home/caches/huggingface ($(get_size "/home/caches/huggingface"))"
echo "  /home/caches/torch ($(get_size "/home/caches/torch"))"
echo "  /home/caches/pip ($(get_size "/home/caches/pip"))"
echo "  /home/caches/transformers ($(get_size "/home/caches/transformers"))"
echo "  /home/caches/datasets ($(get_size "/home/caches/datasets"))"
echo "  /home/caches/gradio ($(get_size "/home/caches/gradio"))"

echo ""
echo "Disk space after cleanup:"
df -h / | tail -1

echo ""
echo "You can now run WanGP with: ./start_wan2gp.sh --i2v"
