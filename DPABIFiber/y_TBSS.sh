#!/bin/bash
cp -rf $1/Results/DwiVolu/TensorMetrics/FA/* $1/Results/DwiVolu/TBSS/Working/
cd $1/Results/DwiVolu/TBSS/Working/
tbss_1_preproc *.nii.gz
tbss_2_reg -T
tbss_3_postreg -S
tbss_4_prestats 0.2

cp -rf $1/Results/DwiVolu/TensorMetrics/AD $1/Results/DwiVolu/TBSS/Working/
tbss_non_FA AD

cp -rf $1/Results/DwiVolu/TensorMetrics/ADC $1/Results/DwiVolu/TBSS/Working/
tbss_non_FA ADC

cp -rf $1/Results/DwiVolu/TensorMetrics/RD $1/Results/DwiVolu/TBSS/Working/
tbss_non_FA RD

