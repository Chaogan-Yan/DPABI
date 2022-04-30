# Calcuate meta.
# args[1]: The input matlab .mat file. Has: 'TVal','N1','N2','nTests','Regressor'
# args[2]: The name for the output matlab .mat file.

# install the following R packages:
# 
# install.packages("metafor")
# install.packages("R.matlab")
# 
# More details about 'metafor' R package can be found at
# https://www.metafor-project.org/
# 
# Written by YAN Chao-Gan 220429
# Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
# ycg.yan@gmail.com


library("metafor")
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
EffectSize = matrix(0, nrow(TVal), nTests)

for (n in 1:nTests){

  y <- escalc(measure = "SMD", vtype = "UB",
              m1i = TVal[,n] * sqrt(1 / N1 + 1 / N2),
              n1i = N1, n2i = N2,
              m2i = rep(0, nrow(TVal)), sd1i = rep(1, nrow(TVal)), sd2i = rep(1, nrow(TVal)))
  
  if(length(Regressor) == 0){
    m <- rma(y)
  } else {
    m <- rma(y, mods = Regressor)
  }
  
  Z[n] = m['zval']
  P[n] = m['pval']
  EffectSize[,n] = as.matrix(y['yi'])
}

writeMat(OutputName, Z = Z, P = P, EffectSize = EffectSize)



