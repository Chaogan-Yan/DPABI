FROM pennbbl/qsiprep:0.16.0RC3

MAINTAINER Chao-Gan Yan <ycg.yan@gmail.com>

# Update system and istall pakages

RUN apt-get -qq update && DEBIAN_FRONTEND="noninteractive" TZ="America/New_York" apt-get install -y tzdata && apt-get update

RUN apt-get -qq update && apt-get -qq install -y \
    x11vnc xvfb parallel && \
    apt-get update

# x11vnc xvfb suckless-tools stterm parallel wget unzip time qt5-default && \


# Setup x11vnc
RUN mkdir -p ~/.vnc && \
    x11vnc -storepasswd dpabi ~/.vnc/passwd && \
    chmod 0600 ~/.vnc/passwd && \
    export USER=$(whoami) && \
    export DISPLAY=$HOSTNAME:25

RUN conda install -c mrtrix3 mrtrix3

RUN /opt/fsl-6.0.5.1/etc/fslconf/fslpython_install.sh -f /opt/fsl-6.0.5.1

COPY ./MissingCommands/* /opt/fsl-6.0.5.1/bin/

RUN mv /opt/fsl-6.0.5.1/bin/LowerCingulum_1mm.nii.gz /opt/fsl-6.0.5.1/data/standard/LowerCingulum_1mm.nii.gz

# python fslinstaller.py -f /fslraw/fsl-6.0.5.1-centos7_64.tar.gz -M -D -d /opt/fsl-6.0.5.1

# cp /fslraw/MissingCommands/LowerCingulum_1mm.nii.gz /opt/fsl-6.0.5.1/data/standard/


ENTRYPOINT []

# Start VNC after launching
# x11vnc -forever -shared -usepw -create -rfbport 5925 &

    
