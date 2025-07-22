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
  npm install
  npm run build
  
  # Clean up old wheel and build artifacts
  echo "Cleaning up old wheel and build artifacts..."
  cd comfyui_frontend_package
  rm -rf build dist comfyui_frontend_package.egg-info
  # Remove old static files if present
  rm -rf comfyui_frontend_package/static
  # Copy the built frontend static files into the Python package
  cp -r ../dist ./comfyui_frontend_package/static
  
  # Build the wheel
  echo "Building the frontend Python wheel..."
  python3 setup.py bdist_wheel
  cd ../..
  echo "Frontend wheel package created at ComfyUI_frontend/comfyui_frontend_package/dist/"
else
  echo "ComfyUI_frontend directory not found. Skipping frontend build."
fi


echo "Building Docker images..."
#export UID=$(id -u) 
#export GID=$(id -g)

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
