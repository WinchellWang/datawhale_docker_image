Dockfile containing LightGBM, Pytorch and TorchText with GPU Cuda acceleration

# How to Use

## Docker

Download all files in one folder.

Add your key information to authorized_keys.

Build the image in the folder with the following command.

```bash
docker build -t datawhale/lightgbm_pytorch_torchtext:12.3 .
```

After build the image, creat the container.

```bash
docker run -itd \
    -e PUID=1000 -e PGID=1000 \
    --gpus all \
    --name=datawhale \
    --restart=on-failure \
    -v ~/work_folder/:/home \
    -p 1234:22 \
    datawhale/lightgbm_pytorch_torchtext:12.3
```

## Local Computer

Set the SSH config file with the following

```
Host DataWhale
    HostName 0.0.0.0 # your docker server IP
    User root # password is winchellwang
    Port 1234 # math with the forward port
    IdentityFile ~\.ssh\id_rsa # id_rsa should match with your key in authorized_keys
```

Open remote connection in VS Code.

# What it has inside

Built in CONDA environment

```bash
conda 24.3.0
# conda environments:
#
base                  *  /opt/miniforge
LightGBM                 /opt/miniforge/envs/LightGBM
Pytorch                  /opt/miniforge/envs/Pytorch
TorchText                /opt/miniforge/envs/TorchText
```

LightGBM, Pytorch, and TorchText are already CUDA compatible.

# Requirement

Ubuntu 22.04 has Nvidia GPU with CUDA > 12.3
