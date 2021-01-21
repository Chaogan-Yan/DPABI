FROM nipreps/fmriprep:20.2.1

MAINTAINER Chao-Gan Yan <ycg.yan@gmail.com>

# Update system and istall pakages
RUN apt-get -qq update && apt-get -qq install -y \
    x11vnc xvfb suckless-tools stterm connectome-workbench parallel wget unzip qt4-default libjpeg62 && \
    apt-get update


# Setup x11vnc
RUN mkdir -p ~/.vnc && \
    x11vnc -storepasswd dpabi ~/.vnc/passwd && \
    chmod 0600 ~/.vnc/passwd && \
    export USER=$(whoami) && \
    export DISPLAY=$HOSTNAME:25
    
    
# Install MATLAB MCR
ENV MATLAB_VERSION R2020a
RUN mkdir /opt/mcr_install && \
    mkdir /opt/mcr && \
    wget --quiet -P /opt/mcr_install http://ssd.mathworks.com/supportfiles/downloads/R2020a/Release/0/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_R2020a_glnxa64.zip && \
    unzip -q /opt/mcr_install/MATLAB_Runtime_R2020a_glnxa64.zip -d /opt/mcr_install && \
    /opt/mcr_install/install -destinationFolder /opt/mcr -agreeToLicense yes -mode silent && \
    rm -rf /opt/mcr_install /tmp/*

# Configure environment
ENV MCR_VERSION v98
ENV LD_LIBRARY_PATH /usr/lib/fsl/5.0:/opt/mcr/${MCR_VERSION}/runtime/glnxa64:/opt/mcr/${MCR_VERSION}/bin/glnxa64:/opt/mcr/${MCR_VERSION}/sys/os/glnxa64:/opt/mcr/${MCR_VERSION}/sys/opengl/lib/glnxa64
ENV MCR_INHIBIT_CTF_LOCK 1
ENV MCRPath /opt/mcr/${MCR_VERSION}

# Configure DPABI
RUN mkdir /opt/DPABI
COPY . /opt/DPABI
RUN chmod +x /opt/DPABI/DPABI_StandAlone/run_DPABI_StandAlone.sh
RUN chmod +x /opt/DPABI/DPABI_StandAlone/DPABI_StandAlone
RUN chmod +x /opt/DPABI/DPABI_StandAlone/run_DPARSFA_run_StandAlone.sh
RUN chmod +x /opt/DPABI/DPABI_StandAlone/DPARSFA_run_StandAlone
RUN chmod +x /opt/DPABI/DPABI_StandAlone/run_DPABISurf_run_StandAlone.sh
RUN chmod +x /opt/DPABI/DPABI_StandAlone/DPABISurf_run_StandAlone

# Extract ctf for singularity support
RUN /opt/DPABI/DPABI_StandAlone/run_DPABI_StandAlone.sh /opt/mcr/${MCR_VERSION} || true
RUN /opt/DPABI/DPABI_StandAlone/run_DPARSFA_run_StandAlone.sh /opt/mcr/${MCR_VERSION} || true
RUN /opt/DPABI/DPABI_StandAlone/run_DPABISurf_run_StandAlone.sh /opt/mcr/${MCR_VERSION} || true

ENTRYPOINT []

# Start VNC after launching
# x11vnc -forever -shared -usepw -create -rfbport 5925 &

    
