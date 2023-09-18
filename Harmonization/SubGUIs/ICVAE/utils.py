# -*- coding:utf-8 -*-
import numpy as np
import pandas as pd
# update in 7/14 correct onehot function
def onehot_test_label(num_classes,class4Decoder):
    # num_classes : how many classes you decide to have
    # class4Decoder : if dataframe can be directly applied
    # if np, with length()
    if  type(class4Decoder) is np.ndarray:
        max_level = max(class4Decoder)
    else:
        print('what is your data type ?')
		
    num_labels = class4Decoder.shape[0]
    
    if max_level > num_classes :
        levels = np.unique(class4Decoder)
        for i in range(num_classes):
            class4Decoder[class4Decoder==levels[i]]=i
    test_label = np.eye(num_labels,num_classes)[class4Decoder]
 
    return test_label
