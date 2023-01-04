function [Error]=DPARSF_run(CfgBasic)
% Adpat the DPARSF basic struct to Advanced struct, and then call DPARSFA_run
% FORMAT [Error]=DPARSF_run(AutoDataProcessParameter)
% Input:
%   AutoDataProcessParameter - the parameters for auto data processing
% Output:
%   The processed data that you want.
%-----------------------------------------------------------
% Written by YAN Chao-Gan 140815.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com


[ProgramPath, fileN, extn] = fileparts(which('DPARSFA_run.m'));

load([ProgramPath,filesep,'Jobmats',filesep,'Template_CalculateInMNISpace_TraditionalOrder.mat']);

Cfg.DPARSFVersion = CfgBasic.DPARSFVersion;
Cfg.WorkingDir = CfgBasic.WorkingDir;
Cfg.DataProcessDir = CfgBasic.DataProcessDir;
Cfg.SubjectID=CfgBasic.SubjectID;
Cfg.TimePoints=CfgBasic.TimePoints;
Cfg.TR=CfgBasic.TR;
Cfg.IsNeedConvertFunDCM2IMG=CfgBasic.IsNeedConvertFunDCM2IMG;
Cfg.IsRemoveFirstTimePoints=CfgBasic.IsRemoveFirstTimePoints;
Cfg.RemoveFirstTimePoints=CfgBasic.RemoveFirstTimePoints;
Cfg.IsSliceTiming=CfgBasic.IsSliceTiming;
Cfg.SliceTiming.SliceNumber=CfgBasic.SliceTiming.SliceNumber;
Cfg.SliceTiming.TR=CfgBasic.SliceTiming.TR;
Cfg.SliceTiming.TA=CfgBasic.SliceTiming.TA;
Cfg.SliceTiming.SliceOrder=CfgBasic.SliceTiming.SliceOrder;
Cfg.SliceTiming.ReferenceSlice=CfgBasic.SliceTiming.ReferenceSlice;
Cfg.IsRealign=CfgBasic.IsRealign;
Cfg.IsNormalize=CfgBasic.IsNormalize;

Cfg.IsNeedConvertT1DCM2IMG=CfgBasic.IsNeedConvertT1DCM2IMG;

switch Cfg.IsNormalize
    case 1
        Cfg.IsNeedT1CoregisterToFun=0;
        Cfg.IsSegment=0;
        Cfg.IsDARTEL=0;
    case 2
        Cfg.IsNeedT1CoregisterToFun=1;
        Cfg.IsSegment=1;
        Cfg.IsDARTEL=0;
    case 3
        Cfg.IsNeedT1CoregisterToFun=1;
        Cfg.IsSegment=2;
        Cfg.IsDARTEL=1;
end
Cfg.Segment.AffineRegularisationInSegmentation=CfgBasic.Normalize.AffineRegularisationInSegmentation;

Cfg.Normalize.BoundingBox=CfgBasic.Normalize.BoundingBox;
Cfg.Normalize.VoxSize=CfgBasic.Normalize.VoxSize;

Cfg.IsSmooth=CfgBasic.IsSmooth;
Cfg.Smooth.FWHM=CfgBasic.Smooth.FWHM;
Cfg.IsDetrend=CfgBasic.IsDetrend;

Cfg.IsCovremove=CfgBasic.IsCovremove;
Cfg.Covremove.PolynomialTrend = CfgBasic.Covremove.PolynomialTrend; %YAN Chao-Gan. 140815
Cfg.Covremove.HeadMotion=4*CfgBasic.Covremove.HeadMotion;
Cfg.Covremove.WholeBrain.IsRemove = CfgBasic.Covremove.WholeBrain;
Cfg.Covremove.CSF.IsRemove = CfgBasic.Covremove.CSF;
Cfg.Covremove.WM.IsRemove = CfgBasic.Covremove.WhiteMatter; %YAN Chao-Gan, 20160415. Fixed the bug. Cfg.Covremove.WM.IsRemov = CfgBasic.Covremove.WhiteMatter;
Cfg.Covremove.OtherCovariatesROI=CfgBasic.Covremove.OtherCovariatesROI; %YAN Chao-Gan added 091215./091212.

Cfg.MaskFile =CfgBasic.MaskFile;

Cfg.IsCalALFF=CfgBasic.IsCalALFF||CfgBasic.IsCalfALFF;
Cfg.CalALFF.AHighPass_LowCutoff=CfgBasic.CalALFF.AHighPass_LowCutoff;
Cfg.CalALFF.ALowPass_HighCutoff=CfgBasic.CalALFF.ALowPass_HighCutoff;

Cfg.IsFilter=CfgBasic.IsFilter;
Cfg.Filter.Timing='AfterNormalize'; %Another option: BeforeNormalize
Cfg.Filter.ALowPass_HighCutoff=CfgBasic.Filter.ALowPass_HighCutoff;
Cfg.Filter.AHighPass_LowCutoff=CfgBasic.Filter.AHighPass_LowCutoff;
Cfg.Filter.AAddMeanBack=CfgBasic.Filter.AAddMeanBack;

Cfg.IsCalReHo=CfgBasic.IsCalReHo;
Cfg.CalReHo.ClusterNVoxel=CfgBasic.CalReHo.ClusterNVoxel;
Cfg.CalReHo.SmoothReHo = CfgBasic.CalReHo.smReHo;

Cfg.IsCalFC = CfgBasic.IsCalFC;

Cfg.IsExtractROISignals = CfgBasic.IsExtractROISignals;
Cfg.CalFC.IsMultipleLabel = CfgBasic.CalFC.IsMultipleLabel;
Cfg.CalFC.ROIDef=CfgBasic.CalFC.ROIDef;


%Turn off Reorient, AutoMask, Bet if without Normalize process %YAN Chao-Gan, 150706
if Cfg.IsNormalize==0
    Cfg.IsNeedT1CoregisterToFun=0;
    Cfg.IsSegment=0;
    Cfg.IsDARTEL=0;
    
    Cfg.IsNeedReorientFunImgInteractively=0; 
    Cfg.IsNeedReorientT1ImgInteractively=0; 
    Cfg.IsBet=0; 
    Cfg.IsAutoMask=0;  
end

%Turn off VMHC
Cfg.IsNormalizeToSymmetricGroupT1Mean=0; %YAN Chao-Gan, 150706
Cfg.IsCalVMHC=0;


Cfg.StartingDirName=CfgBasic.StartingDirName;

[Error] = DPARSFA_run(Cfg);


