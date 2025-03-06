FROM nvcr.io/nvidia/cuda-dl-base:24.12-cuda12.6-devel-ubuntu24.04

# Install dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
    python3 \
    python3-dev \
    python3-pip \
    python3-wheel \
    python3-venv \
    python3-yaml \
    build-essential \
    pkg-config \
    ffmpeg \
    libgl1 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

ARG UID
ARG GID
RUN addgroup --gid ${GID} user && \
   adduser --uid ${UID} --gid ${GID} --shell /bin/sh user
