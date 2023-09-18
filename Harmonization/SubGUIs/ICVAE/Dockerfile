FROM tensorflow/tensorflow:2.0.0-py3

RUN pip3 install numpy pandas 
RUN pip3 install -Iv keras==2.2.4
#RUN pip3 install matplotlib --upgrade pip
RUN pip3 install scipy
RUN pip3 install h5py==2.10.0

COPY . .

ENTRYPOINT python3 train.py --ICVAE_Train_hdf5 /in
