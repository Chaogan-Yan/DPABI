# Calcuate meta.
# args[1]: The input matlab .mat file. Has: 'TVal','N1','N2','nTests'
# args[2]: The name for the output matlab .mat file.

# install the following R packages:
# 
# install.packages("metansue")
# install.packages("R.matlab")
# 
# More details about 'metansue' R package can be found at
# https://www.metansue.com/
# 
# Written by YAN Chao-Gan 170208.
# Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
# ycg.yan@gmail.com


library("metansue")
library("R.matlab")

args = commandArgs(trailingOnly=TRUE)
InputName <- args[1]
OutputName <- args[2]

mat <- readMat(InputName)

TVal <- mat[["TVal"]]
N1 <- mat[["N1"]]
N2 <- mat[["N2"]]
nTests <- mat[["nTests"]]
Regressor <- mat[["Regressor"]]


# initial setup
Z = matrix(0, nTests, 1)
P = matrix(0, nTests, 1)
D = matrix(0, nTests, 1)
EffectSize = matrix(0, nrow(TVal), nTests)

for (n in 1:nTests){
  
  if(length(N2) == 0){
    x <- smc_from_t(c(TVal[,n]),c(N1))
  } else {
    x <- smd_from_t(c(TVal[,n]),c(N1),c(N2))
  }
  
  
  if(length(Regressor) == 0){
    m <- meta(x)
  } else {
    m <- meta(x, ~ Regressor)
  }
  
  Z[n] = m[['hypothesis']][['z']]
  P[n] = m[['hypothesis']][['p.value']]
  D[n] = m[['hypothesis']][['coef']]
  EffectSize[,n] = x[['y']]
}

writeMat(OutputName, Z = Z, P = P, D = D, EffectSize = EffectSize)



