#!/bin/bash

set -e

# Update ComfyUI repository from upstream master
if [ -d "ComfyUI" ]; then
  echo "Updating ComfyUI from upstream master..."
  cd ComfyUI
  git checkout master
  git pull --no-ff origin master
  #git pull --no-ff upstream master
  cd ..
else
  echo "ComfyUI directory not found."
fi

# Update ComfyUI_frontend repository from upstream main
if [ -d "ComfyUI_frontend" ]; then
  echo "Updating ComfyUI_frontend from upstream main..."
  cd ComfyUI_frontend
  git checkout main
  git pull --no-ff origin main
  #git pull --no-ff upstream main
  cd ..
else
  echo "ComfyUI_frontend directory not found."
fi

# Update all custom nodes in ComfyUI/custom_nodes that have a .git directory
if [ -d "ComfyUI/custom_nodes" ]; then
  echo "Updating custom nodes in ComfyUI/custom_nodes..."
  for dir in ComfyUI/custom_nodes/*/ ; do
    if [ -d "$dir/.git" ]; then
      echo "Updating custom node in $dir..."
      cd "$dir"
      git pull --no-ff
      cd - > /dev/null
    fi
  done
else
  echo "ComfyUI/custom_nodes directory not found."
fi

