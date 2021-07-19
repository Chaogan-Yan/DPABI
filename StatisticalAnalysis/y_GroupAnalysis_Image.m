function [b_OLS_brain, t_OLS_brain, TF_ForContrast_brain, r_OLS_brain, Header, SSE_OLS_brain, Cohen_f2_brain] = y_GroupAnalysis_Image(DependentVolume,Predictor,OutputName,MaskFile,CovVolume,Contrast,TF_Flag,IsOutputResidual,Header)
% function [b_OLS_brain, t_OLS_brain, TF_ForContrast_brain, r_OLS_brain, Header, SSE_OLS_brain] = y_GroupAnalysis_Image(DependentVolume,Predictor,OutputName,MaskFile,CovVolume,Contrast,TF_Flag,IsOutputResidual,Header)
% Perform regression analysis 
% Input:
% 	DependentVolume		-	1. For NIfTI: 4D data matrix (DimX*DimY*DimZ*DimTimePoints) or the directory of 3D image data file or the filename of one 4D data file
%                       -	2. For GIfTI: 2D data matrix (nDimVertex*DimTimePoints) or the directory of 1D image data file or the filename of one 2D data file
%   Predictor - the Predictors M (subjects) by N (traits). SHOULD INCLUDE the CONSTANT column if needed. The program will not add constant column automatically.
%   OutputName - the output name. (should not have extention such as .img,.nii)
%   MaskFile - the mask file.
%   CovVolume  [optional]        -	1. For NIfTI: 4D data matrix (DimX*DimY*DimZ*DimTimePoints) or the directory of image covariates, in which the files should be correspond to the DependentVolume
%                                -	2. For GIfTI: 2D data matrix (nDimVertex*DimTimePoints) or the directory of image covariates, in which the files should be correspond to the DependentVolume
%   Contrast [optional] - Contrast for T-test for F-test. 1*ncolX matrix.
%   TF_Flag [optional] - 'T' or 'F'. Specify if T-test or F-test need to be performed for the contrast
%   IsOutputResidual [optional] - 1: output the 4D/2D residuals. 
%                    - 0: don't output the 4D/2D residuals
%   Header [optional] - If DependentVolume is given as a 4D/2D Brain matrix, then Header should be designated.

% Output:
%   OutputName_b.nii, OutputName_T.nii     - beta and t value files results
%   OutputName_Cohen_f2.nii                - Cohen's f squared (Effect Size) for the contrast.
%   OutputName_Residual.nii (optional)     - Residual files
%___________________________________________________________________________
% Written by YAN Chao-Gan 120823.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com
% Revised by YAN Chao-Gan 170714, Added Cohen's f squared (Effect Size)
% Revised by YAN Chao-Gan 181204. Add GIfTI support.

if ~exist('MaskFile','var')
    MaskFile = '';
end

if ~exist('CovVolume','var')
    CovVolume = [];
end

if ~exist('Contrast','var')
    Contrast = [];
end



if ~isnumeric(DependentVolume)
    if (ischar(DependentVolume)) && (exist(DependentVolume,'file')==2) %YAN Chao-Gan, 210416. Read txt file
        [pathstr, name, ext] = fileparts(DependentVolume);
        if (strcmpi(ext, '.txt'))
            fid = fopen(DependentVolume);
            FileCell = textscan(fid,'%s\n');
            fclose(fid);
            DependentVolume=FileCell{1};
        end
    end
    [DependentVolume,VoxelSize,theImgFileList, Header] = y_ReadAll(DependentVolume);
    fprintf('\n\tImage Files in the Group:\n');
    for itheImgFileList=1:length(theImgFileList)
        fprintf('\t%s\n',theImgFileList{itheImgFileList});
    end
end

if (ischar(Predictor)) && (exist(Predictor,'file')==2) %YAN Chao-Gan, 210416. Read txt file
    Predictor=load(Predictor);
end

if exist('CovVolume','var') && (~isnumeric(CovVolume))
    if (ischar(CovVolume)) && (exist(CovVolume,'file')==2) %YAN Chao-Gan, 210416. Read txt file
        [pathstr, name, ext] = fileparts(CovVolume);
        if (strcmpi(ext, '.txt'))
            fid = fopen(CovVolume);
            FileCell = textscan(fid,'%s\n');
            fclose(fid);
            CovVolume=FileCell{1};
        end
    end
    [CovVolume,VoxelSize,theImgFileList] = y_ReadAll(CovVolume);%YAN Chao-Gan, 160119. Fixed a bug.  %[CovVolume] = y_ReadAll(DependentVolume);
    fprintf('\n\tImage Files as covariates:\n');
    for itheImgFileList=1:length(theImgFileList)
        fprintf('\t%s%s\n',theImgFileList{itheImgFileList});
    end
end

if ~isfield(Header,'cdata') && ~isfield(Header,'MatrixNames') %YAN Chao-Gan 181204. If NIfTI data
    [nDim1,nDim2,nDim3,nDim4]=size(DependentVolume);
    if ~isempty(MaskFile)
        [MaskData,MaskVox,MaskHead]=y_ReadRPI(MaskFile);
    else
        MaskData=ones(nDim1,nDim2,nDim3);
    end
    MaskData = any(DependentVolume,4) .* MaskData; % skip the voxels with all zeros
    if exist('CovVolume','var') && ~isempty(CovVolume)
        b_OLS_brain=zeros(nDim1,nDim2,nDim3,size(Predictor,2)+1);
        t_OLS_brain=zeros(nDim1,nDim2,nDim3,size(Predictor,2)+1);
    else
        b_OLS_brain=zeros(nDim1,nDim2,nDim3,size(Predictor,2));
        t_OLS_brain=zeros(nDim1,nDim2,nDim3,size(Predictor,2));
    end
    
    TF_ForContrast_brain=zeros(nDim1,nDim2,nDim3);
    Cohen_f2_brain=zeros(nDim1,nDim2,nDim3); %YAN Chao-Gan 170714, Added Cohen's f squared (Effect Size)
    
    %YAN Chao-Gan, 130227
    r_OLS_brain=zeros(nDim1,nDim2,nDim3,nDim4);
    SSE_OLS_brain=zeros(nDim1,nDim2,nDim3); %YAN Chao-Gan, 151125. Also outpur the SSE Brain.

    fprintf('\n\tRegression Calculating...\n');
    for i=1:nDim1
        fprintf('.');
        for j=1:nDim2
            for k=1:nDim3
                if MaskData(i,j,k)
                    DependentVariable=squeeze(DependentVolume(i,j,k,:));
                    if ~isempty(CovVolume)
                        CovVariable=squeeze(CovVolume(i,j,k,:));
                    else
                        CovVariable = [];
                    end
                    if ~isempty(Contrast)
                        [b,r,SSE,SSR, T, TF_ForContrast, Cohen_f2] = y_regress_ss(DependentVariable,[Predictor,CovVariable],Contrast,TF_Flag); %YAN Chao-Gan 170714, Added Cohen's f squared (Effect Size) %[b,r,SSE,SSR, T, TF_ForContrast] = y_regress_ss(DependentVariable,[Predictor,CovVariable],Contrast,TF_Flag);
                        b_OLS_brain(i,j,k,:)=b;
                        t_OLS_brain(i,j,k,:)=T;
                        TF_ForContrast_brain(i,j,k)=TF_ForContrast;
                        Cohen_f2_brain(i,j,k)=Cohen_f2;
                    else
                        [b,r,SSE,SSR,T] = y_regress_ss(DependentVariable,[Predictor,CovVariable]);
                        b_OLS_brain(i,j,k,:)=b;
                        t_OLS_brain(i,j,k,:)=T;
                    end
                    r_OLS_brain(i,j,k,:)=r;
                    SSE_OLS_brain(i,j,k)=SSE; %YAN Chao-Gan, 151125. Also outpur the SSE Brain.
                end
            end
        end
    end
    
    b_OLS_brain(isnan(b_OLS_brain))=0;
    t_OLS_brain(isnan(t_OLS_brain))=0;
    TF_ForContrast_brain(isnan(TF_ForContrast_brain))=0;
    Cohen_f2_brain(isnan(Cohen_f2_brain))=0;

    Header.pinfo = [1;0;0];
    Header.dt    = [16,0];
    
    DOF = nDim4 - size(Predictor,2) - (~isempty(CovVolume));
    
    VoxelSize = sqrt(sum(Header.mat(1:3,1:3).^2));
    [dLh,resels,FWHM, nVoxels] = y_Smoothest(r_OLS_brain, MaskFile, DOF, VoxelSize);
    
    HeaderTWithDOF=Header;
    HeaderTWithDOF.descrip=sprintf('DPABI{T_[%.1f]}{dLh_%f}{FWHMx_%fFWHMy_%fFWHMz_%fmm}',DOF,dLh,FWHM(1),FWHM(2),FWHM(3));
    
else %YAN Chao-Gan 181204. Take care GIfTI data
    [nDimVertex nDimTimePoints]=size(DependentVolume);
    fprintf('\nLoad mask "%s".\n', MaskFile);
    if ~isempty(MaskFile)
        MaskData=gifti(MaskFile);
        MaskData=MaskData.cdata;
        if size(MaskData,1)~=nDimVertex
            error('The size of Mask (%d) doesn''t match the required size (%d).\n',size(MaskData,1), nDimVertex);
        end
        MaskData = double(logical(MaskData));
    else
        MaskData=ones(nDimVertex,1);
    end
    MaskData = any(DependentVolume,2) .* MaskData; % skip the voxels with all zeros
    if exist('CovVolume','var') && ~isempty(CovVolume)
        b_OLS_brain=zeros(nDimVertex,size(Predictor,2)+1);
        t_OLS_brain=zeros(nDimVertex,size(Predictor,2)+1);
    else
        b_OLS_brain=zeros(nDimVertex,size(Predictor,2));
        t_OLS_brain=zeros(nDimVertex,size(Predictor,2));
    end
    
    TF_ForContrast_brain=zeros(nDimVertex, 1);
    Cohen_f2_brain=zeros(nDimVertex, 1); 
    
    %YAN Chao-Gan, 130227
    r_OLS_brain=zeros(nDimVertex,nDimTimePoints);
    SSE_OLS_brain=zeros(nDimVertex, 1); 
    
    fprintf('\n\tRegression Calculating...\n');

    for i=1:nDimVertex
        if MaskData(i,1)
            DependentVariable=DependentVolume(i,:)';
            if ~isempty(CovVolume)
                CovVariable=squeeze(CovVolume(i,:));
            else
                CovVariable = [];
            end
            if ~isempty(Contrast)
                [b,r,SSE,SSR, T, TF_ForContrast, Cohen_f2] = y_regress_ss(DependentVariable,[Predictor,CovVariable],Contrast,TF_Flag); %YAN Chao-Gan 170714, Added Cohen's f squared (Effect Size) %[b,r,SSE,SSR, T, TF_ForContrast] = y_regress_ss(DependentVariable,[Predictor,CovVariable],Contrast,TF_Flag);
                b_OLS_brain(i,:)=b;
                t_OLS_brain(i,:)=T;
                TF_ForContrast_brain(i,1)=TF_ForContrast;
                Cohen_f2_brain(i,1)=Cohen_f2;
            else
                [b,r,SSE,SSR,T] = y_regress_ss(DependentVariable,[Predictor,CovVariable]);
                b_OLS_brain(i,:)=b;
                t_OLS_brain(i,:)=T;
            end
            r_OLS_brain(i,:)=r;
            SSE_OLS_brain(i,1)=SSE; %YAN Chao-Gan, 151125. Also outpur the SSE Brain.
        end
    end

    b_OLS_brain(isnan(b_OLS_brain))=0;
    t_OLS_brain(isnan(t_OLS_brain))=0;
    TF_ForContrast_brain(isnan(TF_ForContrast_brain))=0;
    Cohen_f2_brain(isnan(Cohen_f2_brain))=0;
    
    DOF = nDimTimePoints - size(Predictor,2) - (~isempty(CovVolume));

    HeaderTWithDOF=Header;
    
    if isfield(Header,'cdata')
        [FWHM] = w_Smoothest_Surf([],{r_OLS_brain}, {MaskFile});
        %FWHM=w_Smoothest_Surf(SurfFiles, ResidualFiles, MskFiles)
        HeaderTWithDOF.private.metadata = [HeaderTWithDOF.private.metadata, struct('name','DOF','value',sprintf('DPABI{T_[%.1f]}{FWHM_%fmm}',DOF,FWHM))];
    elseif isfield(Header,'MatrixNames') %YAN Chao-Gan 210122. Add DPABINet Matrix support.
        HeaderTWithDOF.OtherInfo.StatOpt.TestFlag='T';
        HeaderTWithDOF.OtherInfo.StatOpt.Df=DOF;
    end
end


[Path, Name, Ext]=fileparts(OutputName); %YAN Chao-Gan, 200516. Deal with the Ext
if isempty(Ext)
    if isfield(Header,'cdata')
        Ext='.gii';
    elseif isfield(Header,'MatrixNames') %YAN Chao-Gan 210122. Add DPABINet Matrix support.
        Ext='.mat';
    else
        Ext='.nii';
    end
end
Name=fullfile(Path, Name);

if exist('Contrast','var') && ~isempty(Contrast)
    if strcmpi(TF_Flag,'F') %If TF_Flag is 'T', then still use the previously defined T Header.
        Df_Group = length(find(Contrast));
        if ~isfield(Header,'cdata') && ~isfield(Header,'MatrixNames') %YAN Chao-Gan 181204. If NIfTI data
            Df_E = nDim4 - size(Predictor,2) - (~isempty(CovVolume));
            HeaderTWithDOF=Header;
            HeaderTWithDOF.descrip=sprintf('DPABI{F_[%.1f,%.1f]}{dLh_%f}{FWHMx_%.3fFWHMy_%.3fFWHMz_%.3fmm}',Df_Group,Df_E,dLh,FWHM(1),FWHM(2),FWHM(3));
        else
            Df_E = nDimTimePoints - size(Predictor,2) - (~isempty(CovVolume));
            HeaderTWithDOF=Header;

            if isfield(Header,'cdata')
                HeaderTWithDOF.private.metadata = [HeaderTWithDOF.private.metadata, struct('name','DOF','value',sprintf('DPABI{F_[%.1f,%.1f]}{FWHM_%fmm}',Df_Group,Df_E,FWHM))];
            elseif isfield(Header,'MatrixNames') %YAN Chao-Gan 210122. Add DPABINet Matrix support.
                HeaderTWithDOF.OtherInfo.StatOpt.TestFlag='F';
                HeaderTWithDOF.OtherInfo.StatOpt.Df=Df_Group;
                HeaderTWithDOF.OtherInfo.StatOpt.Df2=Df_E;
            end

        end
    end
    
    y_Write(TF_ForContrast_brain,HeaderTWithDOF,[Name,Ext]);  %y_Write(TF_ForContrast_brain,HeaderTWithDOF,[OutputName,'_',TF_Flag,'_ForContrast','.nii']);
    y_Write(Cohen_f2_brain,HeaderTWithDOF,[Name,'_Cohen_f2',Ext]); %YAN Chao-Gan 170714, Added Cohen's f squared (Effect Size)

else % Output all the T files.
    
    if ~isfield(Header,'cdata') && ~isfield(Header,'MatrixNames') %YAN Chao-Gan 210330. If NIfTI data
        for ii=1:size(b_OLS_brain,4)
            y_Write(squeeze(b_OLS_brain(:,:,:,ii)),Header,[Name,'_b',num2str(ii),Ext]);
            y_Write(squeeze(t_OLS_brain(:,:,:,ii)),HeaderTWithDOF,[Name,'_T',num2str(ii),Ext]);
        end
    else
        for ii=1:size(b_OLS_brain,2)
            y_Write(squeeze(b_OLS_brain(:,ii)),Header,[Name,'_b',num2str(ii),Ext]);
            y_Write(squeeze(t_OLS_brain(:,ii)),HeaderTWithDOF,[Name,'_T',num2str(ii),Ext]);
        end
    end
end

%YAN Chao-Gan, 130227
if exist('IsOutputResidual','var') && (IsOutputResidual==1)
    y_Write(r_OLS_brain,Header,[Name,'_Residual',Ext]);
	%SSE_r_OLS_brain=sum(r_OLS_brain.^2, 4); %Add error sum of square by Sandy
	%y_Write(SSE_r_OLS_brain,Header,[Name,'_Residual_SSE','.nii']);
    y_Write(SSE_OLS_brain,Header,[Name,'_Residual_SSE',Ext]); %YAN Chao-Gan, 151125. Just save the already stored one.
end

Header = HeaderTWithDOF;

fprintf('\n\tRegression Calculation finished.\n');
