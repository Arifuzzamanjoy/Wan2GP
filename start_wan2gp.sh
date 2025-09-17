#!/bin/bash

# WanGP startup script with cache redirection to /home/caches
# This script sets up all necessary environment variables to redirect caches away from default locations

# Create cache directories
mkdir -p /home/caches/huggingface
mkdir -p /home/caches/torch
mkdir -p /home/caches/pip
mkdir -p /home/caches/transformers
mkdir -p /home/caches/datasets
mkdir -p /home/caches/gradio

# Set Hugging Face cache directories
export HF_HOME="/home/caches/huggingface"
export HUGGINGFACE_HUB_CACHE="/home/caches/huggingface/hub"
export TRANSFORMERS_CACHE="/home/caches/transformers"
export HF_DATASETS_CACHE="/home/caches/datasets"

# Set PyTorch cache directory
export TORCH_HOME="/home/caches/torch"

# Set pip cache directory
export PIP_CACHE_DIR="/home/caches/pip"

# Set other common cache directories
export XDG_CACHE_HOME="/home/caches"
export GRADIO_TEMP_DIR="/home/caches/gradio"

# Optional: Set memory mapped files location (for large models)
export TMPDIR="/home/caches/tmp"
mkdir -p /home/caches/tmp

# Show cache directories being used
echo "Cache directories set to:"
echo "  HF_HOME: $HF_HOME"
echo "  HUGGINGFACE_HUB_CACHE: $HUGGINGFACE_HUB_CACHE"
echo "  TRANSFORMERS_CACHE: $TRANSFORMERS_CACHE"
echo "  TORCH_HOME: $TORCH_HOME"
echo "  PIP_CACHE_DIR: $PIP_CACHE_DIR"
echo "  TMPDIR: $TMPDIR"
echo ""

# Activate virtual environment
source venv_wan2gp/bin/activate

# Run WanGP with the provided arguments
python wgp.py "$@"
