#!/bin/bash

# Setup script to redirect safetensors cache to /home/caches
# This script ensures all model files are stored in /home/caches instead of the local ckpts directory

CACHE_DIR="/home/caches"
CKPTS_DIR="/workspace/Wan2GP/ckpts"

echo "Setting up models cache directory at $CACHE_DIR"

# Create cache directory if it doesn't exist
mkdir -p "$CACHE_DIR"

# If ckpts exists and is a directory (not a symlink), move its contents to cache
if [ -d "$CKPTS_DIR" ] && [ ! -L "$CKPTS_DIR" ]; then
    echo "Moving existing model files to cache directory..."
    cp -r "$CKPTS_DIR"/* "$CACHE_DIR"/ 2>/dev/null || echo "No files to move"
    rm -rf "$CKPTS_DIR"
fi

# Remove existing symlink if present
if [ -L "$CKPTS_DIR" ]; then
    rm -f "$CKPTS_DIR"
fi

# Create symlink from ckpts to cache directory
ln -sf "$CACHE_DIR" "$CKPTS_DIR"

echo "✅ Successfully set up symlink: $CKPTS_DIR -> $CACHE_DIR"
echo "All safetensors and model files will now be stored in $CACHE_DIR"

# Verify the setup
if [ -L "$CKPTS_DIR" ] && [ -d "$CACHE_DIR" ]; then
    echo "✅ Setup verification successful"
    ls -la "$CKPTS_DIR"
else
    echo "❌ Setup verification failed"
    exit 1
fi
