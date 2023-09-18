# PNAS2018
This folder has my Matlab codes for the paper "Statistical Tests and Identifiability Conditions for Pooling and Analyzing Multisite Datasets". 

First, unzip Manopt_4.0.zip, which is an open source Matlab toolbox for optimization https://www.manopt.org/.

The folder has a code subsamplingMMD.m which runs the algorithm in the paper without infinitesimal Jacknife variance estimation and a code SSMMDIJ.m which also returns the infinitesimal Jacknife variance estimation. The RunSubsamplingMMD.m gives a simulation example to run subsamplingMMD.m and the RunSSMMDIJ.m gives a simulation example to run SSMMDIJ.m. The code fitMMD.m is the minimizing MMD algorithm which only considers distribution shift and, as mentioned in the paper, serves as the algorithm used in each iteration of subsampling MMD. To better see how p-value calculations work, one can replace subsamplingMMD by fitMMD in the RunSubsamplingMMD.m. Then, in this case, without subsampling, the distributions can not be matched and p-value would be close to 0. 

Other folders including manopt only need to exist in the path to support the above functions.

Please connact hzhou@stat.wisc.edu for questions. In future, we may upload an R package for this project. 
