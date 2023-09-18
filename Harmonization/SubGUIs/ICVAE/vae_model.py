import tensorflow as tf
from tensorflow import keras
import tensorflow.keras.backend as K
from tensorflow.keras.models import Model
import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'
import numpy as np
import pandas as pd

import kl_tools
from adv_model import train_adv
from loss import adv_loss
from utils import onehot_test_label
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'
tf.compat.v1.logging.set_verbosity(tf.compat.v1.logging.ERROR)

class PlotLosses(keras.callbacks.Callback):
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

    def on_train_end(self,log={}):    
        clear_output(wait=True)
        plt.plot(self.x, self.losses, label="loss")
        plt.plot(self.x, self.val_losses, label="val_loss")
        plt.xlabel('Epoch')
        plt.ylabel('Loss')
        plt.legend()
        plt.show()
        

plot_losses = PlotLosses()

def vae_model(train_x,train_y,epoch,h5_fname,advh5_name,state = 'train'):
    # 设置初始超参数
    params = {
                "a":1.0,
                "lambda" : 0.1,
                "gamma" : 10.0
                }   
    # 设置中间表征z 和 类别信息c 的网络参数：层数（纬度），激活函数
    DIM_Z = 32
    DIM_C = np.size(train_y,0)
    INPUT_SHAPE= 512
    ACTIVATION="tanh"
    learning_rate = 0.0001
    # 设置桥梁：层与层间链接的搭建 （元素设定）
    input_x = keras.layers.Input( shape = [INPUT_SHAPE], name="x" )

    enc_hidden_1 = keras.layers.Dense(256, activation=ACTIVATION, name="enc_h1")(input_x)
    enc_hidden_2 = keras.layers.Dense(128, activation=ACTIVATION, name="enc_h2")(enc_hidden_1)
    enc_hidden_3 = keras.layers.Dense(64, activation=ACTIVATION, name="enc_h3")(enc_hidden_2)
   
    # stolen straight from the docs
    # https://keras.io/examples/variational_autoencoder/
    # 现在我们得到的不是一个向量，得到的是一个分布，而分布是无法使用梯度下降的
    def sampling(args):
        """Reparameterization trick by sampling from an isotropic unit Gaussian.

        # Arguments
            args (tensor): mean and log of variance of Q(z|X)

        # Returns
            z (tensor): sampled latent vector
        """

        z_mean, z_log_var = args
        batch = K.shape(z_mean)[0]
        #print(batch)
        dim = K.int_shape(z_mean)[1]
        #print(dim)
        # by default, random_normal has mean = 0 and std = 1.0
        epsilon = K.random_normal(shape=(batch, dim))
        return z_mean + K.exp(0.5 * z_log_var) * epsilon
    
    z_mean = keras.layers.Dense(DIM_Z, activation="tanh")(enc_hidden_3)
    z_log_sigma_sq = keras.layers.Dense(DIM_Z, activation="linear")(enc_hidden_3)
    # 利用重参数技巧得到z
    z = keras.layers.Lambda(sampling, output_shape=(DIM_Z,), name='z')([z_mean, z_log_sigma_sq])
    
    ## this is the concat operation!
    ##  拼接操作，把z和c拼接在一起作为decoder的输入
    input_c = keras.layers.Input( shape = [DIM_C], name="c")
    z_with_c = keras.layers.concatenate([z,input_c])
    z_mean_with_c = keras.layers.concatenate([z_mean,input_c])
    ## 解码网络
    dec_h1 = keras.layers.Dense(64, activation=ACTIVATION, name="dec_h1")
    dec_h2 = keras.layers.Dense(128, activation=ACTIVATION, name="dec_h2")
    dec_h3 = keras.layers.Dense(256, activation=ACTIVATION, name="dec_h3")

    output_layer = keras.layers.Dense( INPUT_SHAPE, name="x_hat" )

    dec_hidden_1 = dec_h1(z_with_c)
    dec_hidden_2 = dec_h2(dec_hidden_1)
    dec_hidden_3 = dec_h3(dec_hidden_2)
    x_hat = output_layer(dec_hidden_3)


    ## encoder model
    cvae = Model(inputs=[input_x,input_c], outputs=x_hat, name="ICVAE") 
    #dv = keras.models.Model(inputs = x_hat.shape ,outputs = s_hat, name = 'ADV')


    mean_dec_hidden_1 = dec_h1(z_mean_with_c)
    mean_dec_hidden_2 = dec_h2(mean_dec_hidden_1)
    mean_dec_hidden_3 = dec_h3(mean_dec_hidden_2)
    mean_x_hat = output_layer(mean_dec_hidden_3)

    ## decoder model
    mean_cvae = Model(
    inputs=[input_x, input_c],
    outputs=mean_x_hat,name="mean_VAE",
    )
    #print(mean_cvae.summary())
    ## okay, now we have a network. Let's build the losses
    ## 建构损失函数

    #重建损失 recon
    #与原文章似乎也有区别
    recon_loss = keras.losses.mse(input_x, x_hat) #｜输出端-输入端｜
    recon_loss *= INPUT_SHAPE #optional, in the tutorial code though

    #kl from prior 
    kl_loss = 1 + z_log_sigma_sq - K.square(z_mean) - K.exp(z_log_sigma_sq)
    kl_loss = K.sum(kl_loss, axis=-1)
    kl_loss *= -0.5

    #z的边界分布一致
    kl_qzx_qz_loss = kl_tools.kl_conditional_and_marg(z_mean, z_log_sigma_sq, DIM_Z)

    train_y = np.transpose(train_y)
    
    cvae_loss = K.mean((1 + params["lambda"]) * recon_loss + 
                       params["a"]*kl_loss + 
                       params["lambda"]*kl_qzx_qz_loss + 
                       params["gamma"]*adv_loss(train_x,train_y,mean_cvae.predict([train_x,train_y]),train_y,advh5_name,DIM_C))
    
    cvae.add_loss(cvae_loss)

    ##模型编译
    opt = tf.keras.optimizers.Adamax(lr=learning_rate)
    cvae.compile( optimizer=opt, )
    if not isinstance(train_x,np.ndarray):
        train_x = train_x.to_numpy()
    
    if state == 'train':
        if not os.path.exists(h5_fname):
            cvae.fit({ "x" : train_x , "c" : train_y},shuffle=True,epochs=epoch,validation_split = 0.3,verbose=0)
            try: 
               cvae.save_weights(h5_fname)
            except Exception as e:
               print("error saving :",str(e))                  
        else:
            cvae.load_weights(h5_fname)
            cvae.fit({ "x" : train_x, "c" : train_y},shuffle=True,epochs=epoch,validation_split = 0.3,verbose=0) 
            cvae.save_weights(h5_fname)
    elif state == 'predict':
        cvae.load_weights(h5_fname)
        x_hat = mean_cvae.predict([train_x,train_y])
        return x_hat
    else:
        print('please improve your model ASAP!!!')
	
    

