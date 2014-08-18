function [p_Brain, F_Brain, Header] = y_CWAS(DataUpDir, SubID, AResultFilename, AMaskFilename, Regressor, iter, IsNeedDetrend, Band, TR)
% [p_Brain, F_Brain, Header] = y_CWAS(DataUpDir, SubID, AResultFilename, AMaskFilename, Regressor, iter, IsNeedDetrend, Band, TR)
% Perform CWAS
% Input:
% 	DataUpDir			The directory stored all the subjects' EPI imges (within each subject's own directory).
%                       E.g., {DataUpDir}/Sub001/rest.nii; {DataUpDir}/Sub002/rest.nii; {DataUpDir}/Sub003/rest.nii; 
%   SubID               The subject ID, n by 1 cell.
%                       E.g., {'Sub001';'Sub002';'Sub003'}
% 	AMaskFilename		the mask file name
%	AResultFilename		the output filename
%   Regressor           the regressors, nDimTimePoints by nRegressor matrix
%   iter                the iteration number of permutation test.
%   IsNeedDetrend       0: Dot not use Matlab's detrend; 1: Use Matlab's detrend
%   Band                filter band: matlab's ideal filter
%   TR                  The TR of scanning
% Output:
%	p_Brain         	the CWAS p brain
%   F_Brain             the psudo F brain
%   Header              the NIfTI header
%-----------------------------------------------------------
% Written by YAN Chao-Gan 120417.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com

if ~exist('CUTNUMBER','var')
    CUTNUMBER = 10;
end

if ~exist('IsNeedDetrend','var')
    IsNeedDetrend=0;
end

if ~exist('Band','var')
    Band=[];
end


theElapsedTime =cputime;
fprintf('\nComputing CWAS with:\t"%s"', DataUpDir);

nSubjectNum = length(SubID);

[AllVolume,VoxelSize,theImgFileList, Header] = y_ReadAll([DataUpDir,filesep,SubID{1}]);
[nDim1 nDim2 nDim3 nDimTimePoints]=size(AllVolume);
BrainSize = [nDim1 nDim2 nDim3];

if ~isempty(AMaskFilename)
    [MaskData,MaskVox,MaskHead]=y_ReadRPI(AMaskFilename);
else
    MaskData=ones(nDim1,nDim2,nDim3);
end
MaskDataOneDim=reshape(MaskData,1,[]);
nVoxels = length(find(MaskDataOneDim));

AllVolume2D_AllSubjects = single(zeros(nDimTimePoints,nVoxels));
AllVolume2D_AllSubjects = repmat(AllVolume2D_AllSubjects,[1,1,nSubjectNum]);

parfor i = 1:nSubjectNum
    [AllVolume,VoxelSize,theImgFileList, Header] = y_ReadAll([DataUpDir,filesep,SubID{i}]);
    % Convert into 2D
    AllVolume=reshape(AllVolume,[],nDimTimePoints)';
    
    AllVolume=AllVolume(:,find(MaskDataOneDim));%    ResultVolumeback=zeros(size(MaskData));    ResultVolumeback(1,find(MaskDataOneDim))=Result;    ResultVolumeback=reshape(ResultVolumeback,nDim1, nDim2, nDim3);
    
    % Detrend
    if IsNeedDetrend==1
        %AllVolume=detrend(AllVolume);
        fprintf('\n\t Detrending...');
        SegmentLength = ceil(size(AllVolume,2) / CUTNUMBER);
        for iCut=1:CUTNUMBER
            if iCut~=CUTNUMBER
                Segment = (iCut-1)*SegmentLength+1 : iCut*SegmentLength;
            else
                Segment = (iCut-1)*SegmentLength+1 : size(AllVolume,2);
            end
            AllVolume(:,Segment) = detrend(AllVolume(:,Segment));
            fprintf('.');
        end
    end
    
    % Filtering
    if ~isempty(Band)
        fprintf('\n\t Filtering...');
        SegmentLength = ceil(size(AllVolume,2) / CUTNUMBER);
        for iCut=1:CUTNUMBER
            if iCut~=CUTNUMBER
                Segment = (iCut-1)*SegmentLength+1 : iCut*SegmentLength;
            else
                Segment = (iCut-1)*SegmentLength+1 : size(AllVolume,2);
            end
            AllVolume(:,Segment) = y_IdealFilter(AllVolume(:,Segment), TR, Band);
            fprintf('.');
        end
    end

    % ZeroMeanOneStd
    AllVolume = (AllVolume-repmat(mean(AllVolume),size(AllVolume,1),1))./repmat(std(AllVolume),size(AllVolume,1),1);   %Zero mean and one std
    AllVolume(isnan(AllVolume))=0;
    
    AllVolume2D_AllSubjects(:,:,i) = single(AllVolume);
end
clear AllVolume

F_Set = zeros(nVoxels,size(Regressor,2));
p_Set = zeros(nVoxels,size(Regressor,2));
% AllVolume = AllVolume-repmat(mean(AllVolume),size(AllVolume,1),1);
% AllVolumeSTD= squeeze(std(AllVolume, 0, 1));
% AllVolumeSTD(find(AllVolumeSTD==0))=inf;

parfor iVoxel=1:nVoxels

%     FCBrain=AllVolume(:,ii)'*AllVolume/(nDimTimePoints-1);
%     FCBrain=(FCBrain./AllVolumeSTD)/AllVolumeSTD(ii);


    FCBrain_AllSubjects = zeros(nVoxels,nSubjectNum);
    for i = 1:nSubjectNum
        FCBrain=squeeze(AllVolume2D_AllSubjects(:,iVoxel,i))'*squeeze(AllVolume2D_AllSubjects(:,:,i))/(nDimTimePoints-1);
        FCBrain_AllSubjects(:,i) = FCBrain;
    end
    
    FCBrain_AllSubjects(iVoxel,:) = []; % Will not include the voxel itself because r == 1! r == 1 will cause problem when do Fisher's r-to-z.
    FCBrain_AllSubjects = 0.5 * log((1 + FCBrain_AllSubjects)./(1 - FCBrain_AllSubjects));
    
    
    Distance = 1- corrcoef(FCBrain_AllSubjects);
    
    [F p] = y_mdmr(Distance,Regressor,iter);

    F_Set(iVoxel,:) = F';
    p_Set(iVoxel,:) = p';
    fprintf('CWAS for voxel %d\n',iVoxel);
end

for iRegressor=1:size(Regressor,2)
    F_Brain=zeros(size(MaskDataOneDim));
    F_Brain(find(MaskDataOneDim))=F_Set(:,iRegressor);
    F_Brain=reshape(F_Brain,nDim1, nDim2, nDim3);
    
    p_Brain=zeros(size(MaskDataOneDim));
    p_Brain(find(MaskDataOneDim))=p_Set(:,iRegressor);
    p_Brain=reshape(p_Brain,nDim1, nDim2, nDim3);
    
    Header.pinfo = [1;0;0];
    Header.dt    =[64,0];
    
    [pathstr, name, ext] = fileparts(AResultFilename);
    
    y_Write(F_Brain,Header,[pathstr, filesep, 'F_', num2str(iRegressor),'_',name, ext]);
    y_Write(p_Brain,Header,[pathstr, filesep, 'p_', num2str(iRegressor),'_',name, ext]);
end

theElapsedTime =cputime - theElapsedTime;
fprintf('\n\t CWAS compution over, elapsed time: %g seconds.\n', theElapsedTime);








function [F p] = y_mdmr(yDis,x,iter)
% Revised from Dave Jones's FATHOM Toolbox: 
% f_distlm.m, f_distlmUtil.m and f_shuffle.m
% <djones@rsmas.miami.edu> Aug-2003
% http://www.rsmas.miami.edu/personal/djones/
% -----References:-----
% Anderson, M. J. 2002. DISTML v.2: a FORTRAN computer program to calculate a
%   distance-based multivariate analysis for a linear model. Dept. of Statistics
%   University of Auckland. (http://www.stat.auckland.ac.nz/PEOPLE/marti/)
% Anderson, M. J. 2001. A new method for non-parametric multivariate
%   analysis of variance. Austral Ecology 26: 32-46.
% Legendre, P. & L. Legendre. 1998. Numerical ecology. 2nd English ed.
%   Elsevier Science BV, Amsterdam.
% McArdle, B. H. and M. J. Anderson. 2001. Fitting multivariate models to
%   community data: a comment on distance-based redundancy analysis. Ecology
%   290-297.
% Neter, J., M. H. Kutner, C. J. Nachtsheim, and W. Wasserman. 1996.
%   Applied linear statistical models. 4th ed. Irwin, Chicago, Illinois.
%________________________________
% Revised to calculate F value for each regressor by YAN Chao-Gan 120416.
% Ref: Reiss, P.T., Stevens, M.H., Shehzad, Z., Petkova, E., Milham, M.P., 2010. On distance-based permutation tests for between-group comparisons. Biometrics 66, 636-643.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com

n = size(yDis,1);
nRegressor = size(x,2); %YAN Chao-Gan, 120917
A   = -0.5*(yDis.^2);
I   = eye(n,n);
uno = ones(n,1);
G   = (I-(1/n)*uno*uno')*A*(I-(1/n)*uno*uno'); % Gower's centered matrix (Anderson, 2002)
%SST = trace(G); % Total Sum-of-Squares
%ncX = size(x,2); % # of explanatory variables

xx = [ones(n,1) x];            % add intercept
[Q1,R1] = qr(xx,0); 
H= Q1*Q1'; % compute Hat-matrix via QR
m = size(xx,2);                % # of parameters in design matrix

%fprintf('\nPermuting the data %d times...\n',iter-1);

% degrees of freedom:
%df.among = m-1; Will not used, YAN Chao-Gan
df.resid = n-m;
df.total = n-1;

% Sum-of-Squares:
%SS.among = trace(H*G*H); Will not used, YAN Chao-Gan
SS.resid = trace((I-H)*G*(I-H));
SS.total = trace(G);

% Mean Square:
%MS.among = SS.among/df.among; Will not used, YAN Chao-Gan
MS.resid = SS.resid/df.resid;

% pseudo-F:
H_Regressor_Set = zeros(n,n,nRegressor);
F = zeros(nRegressor,1);
for iRegressor=1:nRegressor
    xTemp = x(:,iRegressor);
    
    [Q1,R1] = qr(xTemp,0); 
    H_Regressor_Set(:,:,iRegressor) = Q1*Q1'; % compute Hat-matrix via QR  %H_Regressor = xTemp*inv(xTemp'*xTemp)*xTemp';
    
    F(iRegressor) = trace(H_Regressor_Set(:,:,iRegressor)*G*H_Regressor_Set(:,:,iRegressor))/1/MS.resid;  %F = MS.among/MS.resid;
end

%-----Permutation Tests:-----
if iter>0
   rand('state',sum(100*clock)); % set random generator to new state

   F_perm = zeros(iter-1,nRegressor); % preallocate results array
   
   for iITER = 1:(iter-1) % observed value is considered a permutation

      IndexRandPerm = randperm(n); % get permuted indices
      G_perm = G(IndexRandPerm,:);       % permute rows
      G_perm = G_perm(:,IndexRandPerm);       % permute cols
      
      for iRegressor=1:nRegressor
          MS_perm  = trace(H_Regressor_Set(:,:,iRegressor)*G_perm*H_Regressor_Set(:,:,iRegressor))/1;  %MS_perm  = trace(H*G_perm*H)/df.among;
          MSE_perm = trace((I-H)*G_perm*(I-H))/df.resid;
          F_perm(iITER,iRegressor) = MS_perm/MSE_perm;
      end
   end;
   
   p = ones(nRegressor,1);
   for iRegressor=1:nRegressor
       j = find(F_perm(:,iRegressor) >= F(iRegressor)); %j = find(F_perm >= F);     % get randomized stats >= to observed statistic
       p(iRegressor) = (length(j)+1)./(iter); % count values & convert to probability
   end
else
   p = NaN(nRegressor,1);
end;

