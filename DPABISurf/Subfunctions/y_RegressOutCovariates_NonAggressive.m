function [VolumeAfterRemoveCov,Header] = y_RegressOutCovariates_NonAggressive(InFile,CovariablesDef,AResultFilename,MaskFilename)
% FORMAT [VolumeAfterRemoveCov,Header] = y_RegressOutCovariates_NonAggressive(InFile,CovariablesDef,AResultFilename,MaskFilename)
% Non agressively regressed out the covariates from data
% Input:
%   InFile         - The input surface time series file
%   CovariablesDef - A struct which defines the coviarbles.
%                 CovariablesDef.Regressors         - The Regressors
%                 CovariablesDef.ICsToBeRejected    - The ID of ICs need to be rejected
%   AResultFilename    - the output filename 
%   MaskFilename   - The mask file for regression. Empty means perform regression on all the brain voxels.
% Output:
%   VolumeAfterRemoveCov - The data after non agressively regressed out the covariates
%   Header               - The NIfTI or GIfTI Header
%   *.nii/gii            - The data file after non agressively regressed out the covariates
%___________________________________________________________________________
% Inherited from y_RegressOutImgCovariates.m
% Revised by YAN Chao-Gan 181228.
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com


if ~exist('MaskFilename','var')
    MaskFilename='';
end

if ischar(CovariablesDef.Regressors)
    CovariablesDef.Regressors=load(CovariablesDef.Regressors);
end

if ischar(CovariablesDef.ICsToBeRejected)
    CovariablesDef.ICsToBeRejected=load(CovariablesDef.ICsToBeRejected);
end

AlltheCovariables = CovariablesDef.Regressors;

ContrastOfWantedRegressors = ones(size(AlltheCovariables,2),1);
ContrastOfWantedRegressors(CovariablesDef.ICsToBeRejected) = 0;


[AllVolume,VoxelSize,theImgFileList, Header] = y_ReadAll(InFile);

if ~isfield(Header,'cdata') %YAN Chao-Gan 181204. If NIfTI data
    [nDim1,nDim2,nDim3,nDimTimePoints]=size(AllVolume);
    FinalDim=4;
    fprintf('\nLoad mask "%s".\n', MaskFilename);
    if ~isempty(MaskFilename)
        [MaskData,MaskVox,MaskHead]=y_ReadRPI(MaskFilename);
        if ~all(size(MaskData)==[nDim1 nDim2 nDim3])
            error('The size of Mask (%dx%dx%d) doesn''t match the required size (%dx%dx%d).\n',size(MaskData), [nDim1 nDim2 nDim3]);
        end
        MaskData = double(logical(MaskData));
    else
        MaskData=ones(nDim1,nDim2,nDim3);
    end
    
    
    MaskData = any(AllVolume,FinalDim) .* MaskData; % skip the voxels with all zeros
    VolumeAfterRemoveCov=zeros(nDim1,nDim2,nDim3, nDimTimePoints);

    fprintf('\n\tRegressing Out Covariates...\n');
    for i=1:nDim1
        fprintf('.');
        for j=1:nDim2
            for k=1:nDim3
                if MaskData(i,j,k)
                    DependentVariable=squeeze(AllVolume(i,j,k,:));
                    [b,r] = y_regress_ss(DependentVariable,AlltheCovariables);
                    VolumeAfterRemoveCov(i,j,k,:)=r + AlltheCovariables*(b.*ContrastOfWantedRegressors);
                end
            end
        end
    end
    
    Header.pinfo = [1;0;0];
    Header.dt    =[16,0];
else
    [nDimVertex, nDimTimePoints]=size(AllVolume);
    FinalDim=2;
    fprintf('\nLoad mask "%s".\n', MaskFilename);
    if ~isempty(MaskFilename)
        MaskData=y_ReadAll(MaskFilename);
        if size(MaskData,1)~=nDimVertex
            error('The size of Mask (%d) doesn''t match the required size (%d).\n',size(MaskData,1), nDimVertex);
        end
        MaskData = double(logical(MaskData));
    else
        MaskData=ones(nDimVertex,1);
    end

    MaskData = any(AllVolume,FinalDim) .* MaskData; % skip the voxels with all zeros
    VolumeAfterRemoveCov=zeros(nDimVertex, nDimTimePoints);

    fprintf('\n\tRegressing Out Covariates...\n');
    for i=1:nDimVertex
        if MaskData(i,1)
            DependentVariable=AllVolume(i,:)';
            [b,r] = y_regress_ss(DependentVariable,AlltheCovariables);
            VolumeAfterRemoveCov(i,:)=r + AlltheCovariables*(b.*ContrastOfWantedRegressors);
        end
    end
end

VolumeAfterRemoveCov(isnan(VolumeAfterRemoveCov))=0;


%Save all images to disk
fprintf('\n\t Saving covariates regressed images.\tWait...');

y_Write(VolumeAfterRemoveCov,Header,AResultFilename);

fprintf('\n\tRegressing Out Covariates finished.\n');

