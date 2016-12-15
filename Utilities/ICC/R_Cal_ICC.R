# Calcuate ICC for metrics.
# args[1]: The input matlab .mat file. Has: 'AllVolume','CovW','CovB','time','sID','nSubj','nSession','nVoxels'
# args[2]: The name for the output matlab .mat file.
# Called by y_ICC_Image_LMM_CallR.m (in DPABI), which handles the input brain imaging file and covariates, and write out .nii ICC files.
# Original written by Ting Xu (xutingxt@gmail.com) 2015.12.16
# Revised by Chao-Gan Yan (ycg.yan@gmail.com) to interface with y_ICC_Image_LMM_CallR.m 2016.11.15
# Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
# 
# ## ----------------------------- Model Instruction ----------------------------- ##
# Intra-Class Correlation (ICC) Calculation with Linear Mixed Model (LME)
# Author: Ting Xu (xutingxt@gmail.com), Date: Dec 27, 2016
# Chinese Academy of Sciences, China; Child Mind Institute, NY USA
# ## ----------------------------------------------------------------------------- ##
# This function performs the Linear Mixed Model (LME) to calculate ICC, the within- and 
# between- subjects variability, and the corresponding group averaged map across all input 
# images. It's required to install R (https://www.r-project.org/). Alternatively you may 
# install the following R packages:
# 
# install.packages("nlme")
# install.packages("R.matlab")
# 
# More details about the LME in 'nlme' R package can be found at
# https://cran.r-project.org/web/packages/nlme/index.html
# 
# The basic linear mixed model are built to estimate ICC with ReML (Restricted Maximum 
# Likelihood) estimation. The Linear Mixed Model allows missing data included. In addition, 
# ReML method avoids the negative ICC estimation. Random effects are set for the intercept 
# in the model. 
# 
# The basic model without covariates is as follow:
# 
# Y(i,j) = mu + gamma(i) + e(i,j)
# 
# e(i,j) ~ i.i.d. N(0, delta-square)
# gamma(i) ~ i.i.d N(0, tao-square)
# 
#         
# Y(i,j) is the dependent variable (e.g., functional connectivity, ALFF, ReHo, etc.) for the 
# i-th session in j-th subject. The random effects (gamma) and the residual term (e) are
# assumed to be independent identical normally distributed (i.i.d) with mean zero and 
# variance delta-square and tao-square. ICC is estimated as the follow:
# 
#                    between-individual variation  
# ICC =  -------------------------------------------------------------
#        (between-individual variation + within-individual variation)
#        
#                 tao-square
#     =  -----------------------------
#         (tao-square + delta-square)
#         
# 
# In addition, the model can incorporate the within- and between- individual covariates. 
# When the within-individual covariates are included, the random effect are also set for 
# the within-individual covariates but constrains no correlations between any of the random 
# effects or residuals.
# 
# Notice: 
# 1) The demean step should and is applied outside this function in 'y_ICC_Image_LMM_CalR.m'.
# Usually, the grand-mean centering is required for quantitative variables. 
# 
# 2) When including categorical variables as covariates (for instances, sex), make sure 
# dummy coding the variables (zeros and ones). 
# 
# 3) Be cautious with covariates, in most of the cases, the demean or dummy coding steps 
# does not affect the ICC estimation. However, the intercept (estimated average map) 
# and its interpretation is dependent on how you deal with covariates (demean, dummy coding).
# Ref: Zuo et al. (2013): Zuo, X.N., Xu, T., Jiang, L., Yang, Z., Cao, X.Y., He, Y., Zang, Y.F., Castellanos, F.X., Milham, M.P., 2013. Toward reliable characterization of functional homogeneity in the human brain: preprocessing, scan duration, imaging resolution and computational space. Neuroimage 65, 374?386.
#  
# ==========================================================================================


library("nlme")
library("R.matlab")

args = commandArgs(trailingOnly=TRUE)
InputName <- args[1]
OutputName <- args[2]

mat <- readMat(InputName)

nsubj <- mat[["nSubj"]]
nsession <- mat[["nSession"]]
nVoxels <- mat[["nVoxels"]]
# load data
metric <- mat[["AllVolume"]]
# load nuisance
CovW <- mat[["CovW"]]
CovB <- mat[["CovB"]]
subid <- mat[['sID']]
xvisit <- mat[['time']]
# initial setup
icc = matrix(0, nVoxels, 1)
interT = matrix(0, nVoxels, 1)
interP = matrix(0, nVoxels, 1)
avemetric = matrix(0, nVoxels, 1)
varb = matrix(0, nVoxels, 1)
varw = matrix(0, nVoxels, 1)
varb_rate = matrix(0, nVoxels, 1)
varw_rate = matrix(0, nVoxels, 1)

for (n in 1:nVoxels){
  y = metric[,n]
  dataframe = data.frame(y,subid)
  if (length(CovB)!=0) dataframe = data.frame(dataframe,CovB)
  if (length(CovW)!=0) dataframe = data.frame(dataframe,CovW)
  ColumnNames<-names(dataframe)
  
  lmeExpression <- "y ~ "
  if (length(ColumnNames)>3) {
    for (iColumn in 3:(length(ColumnNames)-1)){
      lmeExpression <- sprintf('%s%s+', lmeExpression,ColumnNames[iColumn])
    }
  }
  if (length(ColumnNames)>2) {
    lmeExpression <- sprintf('%s%s', lmeExpression,ColumnNames[length(ColumnNames)])
  }
  if (length(ColumnNames)==2) {
    lmeExpression <- sprintf('%s1', lmeExpression)
  }
  if (length(CovW)==0) {
    lmeExpression <- sprintf('fm <- lme(%s, random = ~ 1 |subid, data = dataframe)', lmeExpression)
  } else {
    WithinCovName <- sprintf('%s', ColumnNames[(length(ColumnNames)-ncol(CovW)+1)])
    if (ncol(CovW)>1) {
      for (iColumn in (length(ColumnNames)-ncol(CovW)+2):(length(ColumnNames))){
        WithinCovName <- sprintf('%s+%s', WithinCovName, ColumnNames[iColumn])
      }
    }
    lmeExpression <- sprintf('fm <- lme(%s, random = list(subid = pdDiag(~ %s)), data = dataframe)', lmeExpression, WithinCovName)
  } 
  
  try({eval(parse(text=lmeExpression))
  output <- summary(fm)
  sigma_r = output$sigma^2
  sigma_b = getVarCov(fm)[1,1]
  icc[n] = sigma_b/(sigma_r+sigma_b)
  interT[n] = output$tTable['(Intercept)', 't-value']
  interP[n] = output$tTable['(Intercept)', 'p-value']
  avemetric[n] = output$tTable['(Intercept)', 'Value']
  varb[n] = sigma_b
  varw[n] = sigma_r
  vary = var(y)
  varb_rate[n] = sigma_b / vary
  varw_rate[n] = sigma_r / vary
  }, silent = FALSE)
}

writeMat(OutputName, icc = icc, varb = varb, varw = varw, average = avemetric, varb_rate = varb_rate, varw_rate = varw_rate)



