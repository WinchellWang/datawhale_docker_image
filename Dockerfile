FROM nvidia/cuda:12.3.2-cudnn9-devel-ubuntu22.04

#################################################################################################################
#           Global
#################################################################################################################
# apt-get to skip any interactive post-install configuration steps with DEBIAN_FRONTEND=noninteractive and apt-get install -y
COPY .bashrc /root
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ARG DEBIAN_FRONTEND=noninteractive

#################################################################################################################
#           Global Path Setting
#################################################################################################################

ENV CUDA_HOME /usr/local/cuda
ENV LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:${CUDA_HOME}/lib64
ENV LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:/usr/local/lib

ENV OPENCL_LIBRARIES /usr/local/cuda/lib64
ENV OPENCL_INCLUDE_DIR /usr/local/cuda/include

#################################################################################################################
#           TINI
#################################################################################################################

# Install tini
ENV TINI_VERSION v0.14.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

#################################################################################################################
#           SYSTEM
#################################################################################################################
# update: downloads the package lists from the repositories and "updates" them to get information on the newest versions of packages and their
# dependencies. It will do this for all repositories and PPAs.

RUN apt-get update && \
apt-get install -y --no-install-recommends \
build-essential \
curl \
bzip2 \
ca-certificates \
libglib2.0-0 \
libxext6 \
libsm6 \
libxrender1 \
git \
vim \
mercurial \
subversion \
cmake \
libboost-dev \
libboost-system-dev \
libboost-filesystem-dev \
gcc \
g++

# Add OpenCL ICD files for LightGBM
RUN mkdir -p /etc/OpenCL/vendors && \
    echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

#################################################################################################################
#           CONDA
#################################################################################################################
WORKDIR /root
ARG CONDA_DIR=/opt/miniforge
# add to path
ENV PATH $CONDA_DIR/bin:$PATH

# Install miniforge
RUN echo "export PATH=$CONDA_DIR/bin:"'$PATH' > /etc/profile.d/conda.sh && \
    curl -sL https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -o ~/miniforge.sh && \
    /bin/bash ~/miniforge.sh -b -p $CONDA_DIR && \
    rm ~/miniforge.sh

RUN /bin/bash -c "conda init"
RUN /bin/bash -c "source .bashrc"
RUN conda config --set always_yes yes --set changeps1 yes && \
    conda create -y -q -n LightGBM numpy scipy scikit-learn jupyter notebook ipython pandas matplotlib && \
    conda create -y -q -n Pytorch pytorch torchvision torchaudio pytorch-cuda=12.1 numpy scipy scikit-learn jupyter notebook ipython pandas matplotlib -c pytorch -c nvidia && \
    conda create -y -q -n TorchText pytorch torchvision torchaudio pytorch-cuda=12.1 torchtext=0.17 numpy scipy scikit-learn jupyter notebook ipython pandas matplotlib jieba sacrebleu -c pytorch -c nvidia

#################################################################################################################
#           LightGBM
#################################################################################################################

RUN cd /usr/local/src && mkdir lightgbm && cd lightgbm && \
    git clone --recursive --branch stable --depth 1 https://github.com/microsoft/LightGBM && \
    cd LightGBM && \
    cmake -B build -S . -DUSE_GPU=1 -DOpenCL_LIBRARY=/usr/local/cuda/lib64/libOpenCL.so -DOpenCL_INCLUDE_DIR=/usr/local/cuda/include/ && \
    OPENCL_HEADERS=/usr/local/cuda-12.3/targets/x86_64-linux/include LIBOPENCL=/usr/local/cuda-12.3/targets/x86_64-linux/lib cmake --build build

ENV PATH /usr/local/src/lightgbm/LightGBM:${PATH}

RUN /bin/bash -c "source activate LightGBM && cd /usr/local/src/lightgbm/LightGBM && sh ./build-python.sh install --precompile && source deactivate"

#################################################################################################################
#           JUPYTER
#################################################################################################################

# password: keras
# password key: --NotebookApp.password='sha1:98b767162d34:8da1bc3c75a0f29145769edc977375a373407824'

# Add a notebook profile.
# RUN mkdir -p -m 700 ~/.jupyter/ && \
#     echo "c.NotebookApp.ip = '*'" >> ~/.jupyter/jupyter_notebook_config.py

# VOLUME /home
# WORKDIR /home

# IPython
# EXPOSE 8888

# ENTRYPOINT [ "/tini", "--" ]
# CMD /bin/bash -c "source activate py3 && jupyter notebook --allow-root --no-browser --NotebookApp.password='sha1:98b767162d34:8da1bc3c75a0f29145769edc977375a373407824' && source deactivate"

#################################################################################################################
#           Install SSH
#################################################################################################################

RUN apt-get update && apt-get install -y --no-install-recommends \
        openssh-server && \
    rm -rf /var/lib/apt/lists/*

COPY sshd_config /etc/ssh
# import authorized_keys to image allowing login without password
COPY authorized_keys /root/.ssh/authorized_keys
# set ssh Password to qaz123
RUN echo 'root:winchellwang' | chpasswd

EXPOSE 22
ENTRYPOINT service ssh start && bash

WORKDIR /home

#################################################################################################################
#           System CleanUp
#################################################################################################################
# apt-get autoremove: used to remove packages that were automatically installed to satisfy dependencies for some package and that are no more needed.
# apt-get clean: removes the aptitude cache in /var/cache/apt/archives. You'd be amazed how much is in there! the only drawback is that the packages
# have to be downloaded again if you reinstall them.

RUN apt-get autoremove -y && apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    conda clean -a -y