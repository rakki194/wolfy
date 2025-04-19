# ComfyUI Docker Environment

This repository contains a Docker setup for ComfyUI, allowing for easy development and deployment.

## Prerequisites

For docker GPU support, this project requires:

- Docker and Docker Compose installed
- NVIDIA GPU with compatible drivers
- NVIDIA Container Toolkit installed

While ComfyUI runs inside a slim NVIDIA container, the frontend build process requires some dependencies on the host:

- Node.js and npm
- Python 3.x

## Setup and Usage

### Initial Setup

1. **Clone this repository and required components**:

   ```bash
   git clone https://github.com/rakki194/wolfy.git
   cd comfy-docker
   git clone https://github.com/comfyanonymous/ComfyUI.git
   git clone https://github.com/Comfy-Org/ComfyUI_frontend.git
   ```

2. **Create directories for models and other data**:
   ```bash
   mkdir -p models
   ```

Then proceed to build the docker images with `./update.sh` as outlined below.

### Update and Build Process

The repository includes an update script that handles:

- Updating the ComfyUI backend code
- Updating the ComfyUI frontend code
- Building the frontend and creating a wheel package
- Updating custom nodes

To run the complete update process:

```bash
./update.sh
```

This script will:

1. Pull the latest changes from the ComfyUI and ComfyUI_frontend repositories
2. Update all git-managed custom nodes
3. Build the frontend using npm
4. Create a Python wheel package for the frontend

### Starting ComfyUI

Once the environment is created, you can start ComfyUI:

```bash
UID=$(id -u) GID=$(id -g) docker-compose up comfyui
```

This command:

- Starts the ComfyUI container
- Maps port 8188 to localhost
- Mounts the necessary volumes for ComfyUI
- Activates the Python virtual environment and runs ComfyUI

ComfyUI will be accessible at [http://localhost:8188](http://localhost:8188).


### Installing Custom Node Dependencies

Many custom nodes require additional Python packages. The logs show which dependencies are missing when you start ComfyUI. To install them:

```bash
UID=$(id -u) GID=$(id -g) docker-compose --profile init run --rm create-venv /bin/dash -c ". /app/venv/bin/activate && pip install opencv-python diffusers insightface trimesh statsmodels numba gguf bitsandbytes simpleeval timm transparent_background piexif resampy webcolors jaxtyping onnxruntime-gpu pymunk numexpr dlib sd_mecha imageio_ffmpeg pillow_jxl_plugin librosa segment_anything /app/ComfyUI/custom_nodes/stable-point-aware-3d/uv_unwrapper"

```

Or start an interactive shell and manually install the dependencies:
```bash
UID=$(id -u) GID=$(id -g) docker-compose --profile init run --rm create-venv /bin/bash
. /app/venv/bin/activate
pip install [...]
```

### Creating a Named Container for Easy Restart

To create a named container that can be easily restarted, you can use:

```bash
UID=$(id -u) GID=$(id -g) docker-compose up --detach comfyui
```

This creates a container named something like `comfy-comfyui-1` (depending on your directory name).

You can then stop and restart it easily:

```bash
# Stop the container
docker stop comfy-comfyui-1

# Restart with attachment to see logs
docker start --attach comfy-comfyui-1
```

### Update

For development:

1. **Update and build everything**:
   ```bash
   ./update.sh
   ```

## Manual update

### Building the Docker Images

The Docker images are built using the provided Dockerfile. To build them:

```bash
UID=$(id -u) GID=$(id -g) docker-compose build
```

This builds the base image that will be used by both the main ComfyUI service and the environment creation service.

### Creating the Python Environment

Before running ComfyUI, you need to create the Python virtual environment with all required dependencies:

```bash
UID=$(id -u) GID=$(id -g) docker-compose --profile init up create-venv
```

This command:

- Uses the `init` profile to run only the `create-venv` service
- Creates a Python virtual environment in the `./venv` directory
- Installs all requirements specified in `ComfyUI/requirements.txt`
- Installs the ComfyUI frontend package from the locally built wheel

The environment is created inside the container but stored in the mounted `./venv` directory, so it persists across container restarts.

### Frontend Development

When making changes to the frontend:

1. **Make changes in the ComfyUI_frontend directory**
2. **Build the frontend and create the wheel package**:
   ```bash
   cd ComfyUI_frontend
   npm ci
   npm run build
   # Then create the wheel package as done in update.sh
   ```
3. **Reinstall the frontend package in the venv**:
   ```bash
   docker exec -it comfy-comfyui-1 /bin/bash -c "source /app/venv/bin/activate && pip install /app/frontend-wheel/comfyui_frontend_package-*.whl"
   ```
   Or recreate the venv completely using the `create-venv` service.

### Production Deployment

For production deployment, you can:

1. **Run the update script to get latest code and build frontend**:

   ```bash
   ./update.sh
   ```

2. **Build the images on your production server**:

   ```bash
   UID=$(id -u) GID=$(id -g) docker-compose build
   ```

3. **Initialize the environment**:

   ```bash
   UID=$(id -u) GID=$(id -g) docker-compose --profile init up create-venv
   ```

4. **Start ComfyUI in detached mode**:

   ```bash
   UID=$(id -u) GID=$(id -g) docker-compose up --detach comfyui
   ```

5. **Set up automatic restarts**:
   ```bash
   docker update --restart=unless-stopped comfy-comfyui-1
   ```

## File Structure

- `ComfyUI/`: The ComfyUI backend code (git repository)
- `ComfyUI_frontend/`: The ComfyUI frontend code (git repository)
- `models/`: Directory for model files (mounted to `/app/ComfyUI/models/` in the container)
- `venv/`: Python virtual environment (mounted to `/app/venv/` in the container)
- `docker-compose.yml`: Docker Compose configuration
- `Dockerfile`: Docker image definition
- `update.sh`: Script to update repositories and build frontend

## Configuration Options

The ComfyUI service is started with the following options:

- `--listen 0.0.0.0`: Listen on all network interfaces
- `--preview-method taesd`: Use TAESD for previews
- `--use-pytorch-cross-attention`: Use PyTorch's cross-attention implementation
- `--disable-xformers`: Disable xformers for compatibility

You can modify these options in the `docker-compose.yml` file.

## Troubleshooting

### GPU Issues

- Ensure NVIDIA drivers and NVIDIA Container Toolkit are installed
- Check Docker logs with `docker logs comfy-comfyui-1`
### Environment Issues

- If changes to requirements are made, rebuild the environment with:
  ```bash
  docker-compose --profile init up create-venv
  ```

### Frontend Issues

- If frontend changes aren't appearing, ensure you've built the frontend and reinstalled the wheel package

### Permission Issues

- Ensure the UID and GID environment variables are set correctly
- Check permissions of mounted directories

