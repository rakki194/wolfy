# Quick Start ComfyUI with Docker (Hotdog)

Follow these steps for a working ComfyUI + ComfyUI_frontend Docker setup:

```bash
git clone https://github.com/rakki194/ComfyUI
git clone https://github.com/rakki194/ComfyUI_frontend
cd ComfyUI_frontend
npm install
npm run build
cd comfyui_frontend_package
# Remove old builds if present
rm -rf build dist comfyui_frontend_package.egg-info
# Copy the built frontend static files into the Python package
cp -r ../dist ./comfyui_frontend_package/static
# Build the wheel
python3 setup.py bdist_wheel
cd ../..
## Build the Docker Images
docker-compose build
docker-compose run --rm create-venv
docker-compose up comfyui
```

- Access the UI at: http://localhost:8188
