import tensorflow as tf
from tensorflow.keras.layers import Input, Dense
from tensorflow.keras.models import Model
import tensorflow.keras.callbacks

import os
import numpy as np

import tensorflow.keras.backend as K
from utils import onehot_test_label

class LossHistory(tensorflow.keras.callbacks.Callback):
    def on_train_begin(self, logs={}):
        self.losses = []
 
    def on_batch_end(self, batch, logs={}):
        self.losses.append(logs.get('loss'))

class PlotLosses(tensorflow.keras.callbacks.Callback):
    def on_train_begin(self, logs={}):
        self.i = 0
        self.x = []
        self.losses = []
        self.val_losses = []
        
        self.fig = plt.figure()
        
        self.logs = []

    def on_epoch_end(self, epoch, logs={}):
        
        self.logs.append(logs)
        self.x.append(self.i)
        self.losses.append(logs.get('loss'))
        self.val_losses.append(logs.get('val_loss'))
        self.i += 1
        
        clear_output(wait=True)
        plt.plot(self.x, self.losses, label="loss")
        plt.plot(self.x, self.val_losses, label="val_loss")
        plt.legend()
        if epoch%100==0:
            plt.show();
        
plot_losses = PlotLosses()

def adv_model(c):
   # This returns a tensor
    inputs = Input(shape=(512,))
    # a layer instance is callable on a tensor, and returns a tensor
    x = Dense(32, activation='tanh')(inputs)
    x = Dense(32, activation='tanh')(x)
    predictions = Dense(c, activation='softmax')(x)
  
    return Model(inputs,predictions)

def train_adv(samples,labels,epoch,advh5_name,dis_trainable):     
#history = LossHistory()
    adv = adv_model(np.size(labels,1))
    
    adv.compile(optimizer='Adam',
                loss='categorical_crossentropy',
                metrics=['accuracy'])
    if not isinstance(samples,np.ndarray):
        samples = samples.to_numpy()

    if dis_trainable == 'True':
        if not os.path.exists(advh5_name):  
            adv.fit(x = samples, y = labels, validation_split = 0.3,epochs=epoch,verbose=0)
            adv.save_weights(advh5_name)     
        else:
            adv.load_weights(advh5_name)
            adv.fit(x = samples, y = labels, validation_split = 0.3,epochs=epoch,verbose=0)
            adv.save_weights(advh5_name)
    else:
        if not os.path.exists(advh5_name): 
            #print("currenctly there is no pre-trained discriminator, you may train one first or load from others")
            dis_trainable = 'True'
            adv.fit(x = samples, y = labels, validation_split = 0.3,epochs=100,verbose=0)
            adv.save_weights(advh5_name) 
            
        
        adv.load_weights(advh5_name)
        # predict 
        loss,accuracy = adv.evaluate(samples,labels,verbose=3)
        #print('loss:',loss,'accuracy:',accuracy)
        return loss





