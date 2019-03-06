function [theCovariables] = y_RegressOutCovariates_OnSurf(InFile,CovariablesDef,AResultFilename,MaskFilename)
% FORMAT [theCovariables] = y_RegressOutCovariates_OnSurf(InFile,CovariablesDef,AResultFilename,MaskFilename)
% Input:
%   InFile         - The input surface time series file
%   CovariablesDef - A struct which defines the coviarbles.
%                 CovariablesDef.polort    - The order of the polynomial like 3dfim+.
%                                            0: constant
%                                            1: constant + linear trend
%                                            2: constant + linear trend + quadratic trend.
%                                            3: constant + linear trend + quadratic trend + cubic trend.   ...
%                 CovariablesDef.ort_file  - The filename of the text file which contains the covaribles.
%                 CovariablesDef.CovMat    - Covariable Matrix. Time points by Cov number matrix
%                 CovariablesDef.IsAddMeanBack - If 1 or 'Yes', the regression mean will be added back to the residual
%   AResultFilename    - the output filename 
%   MaskFilename   - The mask file for regression. Empty means perform regression on all the brain voxels.
% Output:
%   theCovariables - The covariables used in the regression model.
%   *.gii          - data removed the effect of covariables.
%___________________________________________________________________________
% Inherited from y_RegressOutImgCovariates.m
% Revised by YAN Chao-Gan 181126.
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com


if ~exist('MaskFilename','var')
    MaskFilename='';
end

GHeader=gifti(InFile);
AllVolume=GHeader.cdata;
[nDimVertex, nDimTimePoints]=size(AllVolume);

fprintf('\nLoad mask "%s".\n', MaskFilename);
if ~isempty(MaskFilename)
    MaskData=gifti(MaskFilename);
    MaskData=MaskData.cdata;
    if size(MaskData,1)~=nDimVertex
        error('The size of Mask (%d) doesn''t match the required size (%d).\n',size(MaskData,1), nDimVertex);
    end
    MaskData = double(logical(MaskData));
else
    MaskData=ones(nDimVertex,1);
end
MaskDataOneDim=reshape(MaskData,1,[]);


theCovariables=[];
%Add polynomial in the baseline model according to 3dfim+.pdf
if isfield(CovariablesDef,'polort')
    thePolOrt=[];
    if CovariablesDef.polort>=0,
        thePolOrt =(1:nDimTimePoints)';
        thePolOrt =repmat(thePolOrt, [1, (1+CovariablesDef.polort)]);
        for x=1:(CovariablesDef.polort+1),
            thePolOrt(:, x) =thePolOrt(:, x).^(x-1) ;
        end
    end
    theCovariables =[theCovariables,thePolOrt];
end

if isfield(CovariablesDef,'CovMat')
    theCovariables=[theCovariables,CovariablesDef.CovMat];
end

if isfield(CovariablesDef,'ort_file')
    if exist(CovariablesDef.ort_file, 'file')==2,
        theCovariablesFromFile =load(CovariablesDef.ort_file);
        theCovariables =[theCovariables,theCovariablesFromFile];
    else
        warning(sprintf('\n\nCovariables definition text file "%s" doesn''t exist, please check! This covariables will not be regressed out this time.', CovariablesDef.ort_file));
    end
end

MaskData = any(AllVolume,2) .* MaskData; % skip the voxels with all zeros

VolumeAfterRemoveCov=zeros(nDimVertex, nDimTimePoints);
MeanBrain=zeros(nDimVertex,1);

AlltheCovariables = theCovariables;
AlltheCovariables(:,2:end) = (AlltheCovariables(:,2:end)-repmat(mean(AlltheCovariables(:,2:end)),size(AlltheCovariables,1),1)); %YAN Chao-Gan, 20160415. Demean, then the constant models the mean. At the end, could add the mean back.

fprintf('\n\tRegressing Out Covariates...\n');
for i=1:nDimVertex
    if MaskData(i,1)
        DependentVariable=AllVolume(i,:)';
        [b,r] = y_regress_ss(DependentVariable,AlltheCovariables);
        VolumeAfterRemoveCov(i,:)=r;
        MeanBrain(i,1)=b(1);
    end
end

VolumeAfterRemoveCov(isnan(VolumeAfterRemoveCov))=0;


if isfield(CovariablesDef,'IsAddMeanBack') %YAN Chao-Gan, 20160415. Add the mean back.
    if CovariablesDef.IsAddMeanBack==1 || strcmpi(CovariablesDef.IsAddMeanBack, 'Yes')
        VolumeAfterRemoveCov = VolumeAfterRemoveCov + repmat(MeanBrain,[1,nDimTimePoints]);
    end
end

%Save all images to disk
fprintf('\n\t Saving covariates regressed images.\tWait...');

y_Write(VolumeAfterRemoveCov,GHeader,AResultFilename);

fprintf('\n\tRegressing Out Covariates finished.\n');

