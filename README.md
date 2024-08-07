Dockfile containing LightGBM, Pytorch and TorchText with GPU Cuda acceleration

# How to Use

## Docker Image

[winchellwang/datawhalelearning:12.3.2](https://hub.docker.com/r/winchellwang/datawhalelearning)

```bash
docker pull winchellwang/datawhalelearning
```

```bash
docker run -itd \
    -e PUID=1000 -e PGID=1000 \
    --gpus all \
    --name=datawhale \
    --restart=on-failure \
    -v /your/work/folder/:/home \
    -v /your/pub/key/id_rsa.pub:/root/.ssh/authorized_keys \
    -p 1234:22 \
    winchellwang/datawhalelearning:12.3.2
```

## Docker Build

Download all files in one folder.

Add your SSH key information to authorized_keys.

Build the image in the folder with the following command.

```bash
docker build -t winchellwang/datawhalelearning:12.3.2 .
```

After build the image, create the container.

```bash
docker run -itd \
    -e PUID=1000 -e PGID=1000 \
    --gpus all \
    --name=datawhale \
    --restart=on-failure \
    -v /your/work/folder/:/home \
    -p 1234:22 \
    winchellwang/datawhalelearning:12.3.2
```

## Local Computer

Set the SSH config file with the following

```
Host DataWhale
    HostName 0.0.0.0 # your docker server IP
    User root # default password is winchellwang for root user
    Port 1234 # same with the forward port in container deployment
    IdentityFile ~\.ssh\id_rsa # id_rsa should match your key in authorized_keys.
```

Open remote connection in VS Code.

# What it has inside

Built in CONDA environment

```bash
conda 24.3.0
# conda environments:
#
base                  *  /opt/miniforge
LightGBM                 /opt/miniforge/envs/LightGBM # for machine learning course
Pytorch                  /opt/miniforge/envs/Pytorch # for multimodality course (vision, audio, image)
TorchText                /opt/miniforge/envs/TorchText # for natural language processing course
```

LightGBM, Pytorch, and TorchText are already CUDA compatible.

# Requirement

Nvidia GPU with CUDA > 12.3
