Dockfile containing LightGBM, Pytorch and TorchText with GPU Cuda acceleration

# How to Use

Download all files in one folder.

Add your key information to authorized_keys.

Build the image in the folder with the following command.

```bash
docker build -t datawhale/lightgbm_pytorch_torchtext:12.3 .
```

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
