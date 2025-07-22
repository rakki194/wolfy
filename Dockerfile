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
    cmake \
    ffmpeg \
    libgl1 \
    ninja-build \
    git \
    && rm -rf /var/lib/apt/lists/*

# Build and install NVIDIA Apex with CUDA and C++ extensions
RUN git clone https://github.com/NVIDIA/apex.git /tmp/apex && \
    cd /tmp/apex && \
    pip install -v --disable-pip-version-check --no-cache-dir --no-build-isolation --global-option="--cpp_ext" --global-option="--cuda_ext" ./ && \
    cd / && rm -rf /tmp/apex

# Set working directory
WORKDIR /app

ARG UID
ARG GID
RUN addgroup --gid ${GID} user && \
   adduser --uid ${UID} --gid ${GID} --shell /bin/sh user
