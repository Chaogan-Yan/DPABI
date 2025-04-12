FROM ubuntu:22.04
MAINTAINER Chao-Gan Yan "ycg.yan@gmail.com"

ENV DEBIAN_FRONTEND=noninteractive \
    TZ="America/New_York"
# Update system and install packages

RUN apt-get update && apt-get install -y --no-install-recommends \
    x11vnc xvfb stterm parallel wget unzip \
    curl \
    ca-certificates \
    bc \
    dc \
    libgl1 \
    libglib2.0-0 \
    libglu1-mesa \
    libqt5core5a \
    libqt5widgets5 \
    libqt5network5 \
    python3 \
    python3-pip \
    python3-numpy \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/releases/fslinstaller.py -O /tmp/fslinstaller.py \
    && python3 /tmp/fslinstaller.py --fslconda --dest=/opt/fsl \
    && rm /tmp/fslinstaller.py

ENV FSLDIR=/opt/fsl \
    PATH=/opt/fsl/bin:$PATH \
    FSLOUTPUTTYPE=NIFTI_GZ



# Setup x11vnc
RUN mkdir -p ~/.vnc && \
    x11vnc -storepasswd dpabi ~/.vnc/passwd && \
    chmod 0600 ~/.vnc/passwd && \
    export USER=$(whoami) && \
    export DISPLAY=$HOSTNAME:25


RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh \
    && bash ~/miniconda.sh -b -p /opt/conda \
    && rm ~/miniconda.sh \
    && /opt/conda/bin/conda clean -afy


ENV PATH=/opt/conda/bin:$PATH

RUN conda install -c mrtrix3 mrtrix3

RUN conda install -c conda-forge libstdcxx-ng 

ENTRYPOINT []

# Start VNC after launching
# x11vnc -forever -shared -usepw -create -rfbport 5925 &

