import numpy as np
import pandas as pd
from adv_model import train_adv
from utils import onehot_test_label
def adv_loss(raw_data,raw_label,gen_data,gen_label,advh5,dim_c):
    #y_true = np.full(raw_data.shape[0],1)
    #y_true = onehot_test_label(dim_c,raw_label)

    #y_false = np.full(gen_data.shape[0],0)
    #y_false = onehot_test_label(dim_c,gen_label)


    trian_on_raw = train_adv(raw_data,raw_label,5,advh5,dis_trainable='False')
    train_on_gen = train_adv(gen_data,gen_label,5,advh5,dis_trainable='False')
    adv_loss = np.mean(np.mean(trian_on_raw)+ np.mean(train_on_gen))

    return adv_loss
