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



# Build ComfyUI_frontend and create wheel package
if [ -d "ComfyUI_frontend" ]; then
  echo "Building ComfyUI_frontend..."
  cd ComfyUI_frontend
  
  # Install npm dependencies and build
  npm ci
  npm run fetch-templates
  npm run build
  
  # Get version from package.json
  VERSION=$(node -p "require('./package.json').version")
  echo "Frontend version: $VERSION"
  
  # Setup and build the Python package
  echo "Creating Python wheel package..."
  mkdir -p comfyui_frontend_package/comfyui_frontend_package/static/
  cp -r dist/* comfyui_frontend_package/comfyui_frontend_package/static/
  
  # Set version environment variable for the build
  export COMFYUI_FRONTEND_VERSION=$VERSION
  
  # Build the wheel
  cd comfyui_frontend_package
  python -m pip install --user build
  python -m build
  cd ..
  
  echo "Frontend wheel package created at comfyui_frontend_package/dist/"
  cd ..
else
  echo "ComfyUI_frontend directory not found. Skipping frontend build."
fi


echo "Building Docker images..."
export UID=$(id -u) 
export GID=$(id -g)
docker compose build

echo "Creating/Updating Python environment..."
docker-compose --profile init up create-venv


# Update all custom nodes in ComfyUI/custom_nodes that have a .git directory
if [ -d "ComfyUI/custom_nodes" ]; then
  echo "Updating custom nodes in ComfyUI/custom_nodes..."
  for dir in ComfyUI/custom_nodes/*/ ; do
    if [ -d "$dir/.git" ]; then
      echo "Updating custom node in $dir..."
      cd "$dir"
      if ! git pull --no-ff; then
        echo "Failed to update custom node in $dir. Skipping..."
      fi
      cd - > /dev/null
    fi
  done
else
  echo "ComfyUI/custom_nodes directory not found."
fi

echo "Update process completed successfully!"
