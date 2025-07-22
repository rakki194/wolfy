#!/bin/bash
set -e

# Clone Apex if not already present
if [ ! -d "apex" ]; then
  git clone https://github.com/NVIDIA/apex.git
fi
cd apex

# Clean previous builds
rm -rf build dist *.egg-info

# Install Apex with CUDA and C++ extensions
pip install -v --disable-pip-version-check --no-cache-dir --no-build-isolation \
  --global-option="--cpp_ext" --global-option="--cuda_ext" ./ 