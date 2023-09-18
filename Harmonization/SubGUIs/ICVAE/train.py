import pandas as pd
import numpy as np
import scipy.io
import h5py

import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
import multiprocessing 
from math import ceil

import vae_model as VAE
from vae_model import vae_model
from utils import onehot_test_label


def ICVAE_harmonize(HDF5):  
    file = h5py.File(HDF5, 'r')

    # Hierachical level 1
    RawData = file['RawData'][:]  
    TrainData = pd.DataFrame(RawData)  

    TrainZObj= file['OnehotEncoding']
    HarmoZObj= file['OnehotEncoding']
    #OutputdirObj = file['Output']
	
    # Hierachical level 2
    TrainZ = TrainZObj['zTrain'][()] 
    HarmoZ = HarmoZObj['zHarmonize'][()]
    #Outputdir = OutputdirObj['Outputdir'][0].decode()
    #print(TrainZ.shape)
    #print(HarmoZ.shape)
    #Outputdir = '/Users/dianewang/Documents/GitHub/Aug_hamonization/ICVAE/outputfile'
    file.close()

    Harmonized = pd.DataFrame()    
    
    pool=multiprocessing.Pool() 
    # take the input data down by fixed data shape, here is 512
    for i in range(ceil(TrainData.shape[1]/512)):
        # param save path
        path = os.path.join('/ICVAE/params') # make params file - save params for each part
        if not os.path.exists(path):
            os.makedirs(path) 
            print(path)
            print('complete mkdir')
        
        ICVAE_h5 = os.path.join(path,"icvae_%i.h5"  % i)
        adv_h5 = os.path.join(path,"adv_%i.h5"  % i)
        
        # batch? kept
        if i != ceil(TrainData.shape[1]/512)-1: 
            Train_data = TrainData.loc[:,i*512:i*512+511]
        else:
            Train_data = TrainData.iloc[:,-512:]

        # train
        pool.apply_async(vae_model,args=(Train_data,TrainZ,1,ICVAE_h5,adv_h5,'train'))
    
    pool.close()   
    pool.join()
    
    for i in range(ceil(TrainData.shape[1]/512)):
        #  harmonize
        if i != ceil(TrainData.shape[1]/512)-1:
            p_data = TrainData.loc[:,i*512:i*512+511]
            x_hat = pd.DataFrame(VAE.vae_model(p_data,HarmoZ,10000,ICVAE_h5,adv_h5,state='predict'))
        else:
            p_data = TrainData.iloc[:,-512:]
            x_hat = pd.DataFrame(VAE.vae_model(p_data,HarmoZ,10000,ICVAE_h5,adv_h5,state='predict'))
            
            cut = 512*i-TrainData.shape[1] 
            x_hat = x_hat.iloc[:,cut:]        
            
        Harmonized = pd.concat([Harmonized,x_hat],axis=1)
    scipy.io.savemat(os.path.join('/ICVAE/ICVAE_Harmonized.mat'),{'ICVAE':Harmonized.to_numpy()})
    
        


if __name__ == "__main__":   
    import argparse
    
    parser = argparse.ArgumentParser(prog='ICVAE_harmonize',
                                     description = 'ICVAE Model for harmonizing multisite RfMRI data')
    parser.add_argument(
        '--ICVAE_Train_hdf5',
        metavar = 'h5',
        type = str,
        required = True)   
    
    args = parser.parse_args()
    ICVAE_harmonize(HDF5=args.ICVAE_Train_hdf5) 
       
