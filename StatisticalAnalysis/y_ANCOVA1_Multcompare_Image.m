function [ANCOVA_F,Header,PairwiseDiff_Brain,Pairwise_p_Brain,Pairwise_Z_Brain] = y_ANCOVA1_Multcompare_Image(DependentDirs,OutputName,MaskFile,CovariateDirs,OtherCovariates, ctype)
% function [ANCOVA_F,Header,PairwiseDiff_Brain,Pairwise_p_Brain,Pairwise_Z_Brain] = y_ANCOVA1_Multcompare_Image(DependentDirs,OutputName,MaskFile,CovariateDirs,OtherCovariates, ctype)
% Perform one-way ANOVA or ANCOVA analysis on Images, with multiple comparison corrections
% Input:
%   DependentDirs - the image directory of dependent variable, each directory indicate a group. Group number by 1 cell
%   OutputName - the output name.
%   MaskFile - the mask file.
%   CovariateDirs - the image directory of covariates, in which the files should be correspond to the DependentDirs. Group number by 1 cell
%   OtherCovariates - The other covariates. Group number by 1 cell
%                     Perform ANOVA analysis if all the covariates are empty.
%   ctype -         The type of multiple comparison correction.  Choices are 'None'
%                   'tukey-kramer' or 'hsd' (default), 'lsd', 'dunn-sidak', 'bonferroni',
%                   'scheffe'. See more details in multcompare.m
% Output:
%   ANCOVA_F - the F value, also write image file out indicated by OutputName
%   PairwiseDiff_Brain - the group mean differences for each pair of groups
%   Pairwise_p_Brain - the p value of the pairwise group differences, under the multiple comparison correction strategy specified by 'ctype'
%   Pairwise_Z_Brain - the Z values (two-tailed) correspondes to Pairwise_p_Brain
%___________________________________________________________________________
% Written by YAN Chao-Gan 151126.
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com


if nargin<=4
    OtherCovariates=[];
    if nargin<=3
        CovariateDirs=[];
        if nargin<=2
            MaskFile=[];
        end
    end
end

if ~exist('ctype','var')
    ctype='None';
end


GroupNumber=length(DependentDirs);

DependentVolume=[];
CovariateVolume=[];
GroupLabel=[];
OtherCovariatesMatrix=[];
for i=1:GroupNumber
    [AllVolume,VoxelSize,theImgFileList, Header] = y_ReadAll(DependentDirs{i});
    if ~isfield(Header,'cdata') && ~isfield(Header,'MatrixNames') %YAN Chao-Gan 181204. If NIfTI data
        FinalDim=4;
    else
        FinalDim=2;
    end
    fprintf('\n\tImage Files in Group %d:\n',i);
    for itheImgFileList=1:length(theImgFileList)
        fprintf('\t%s\n',theImgFileList{itheImgFileList});
    end
    DependentVolume=cat(FinalDim,DependentVolume,AllVolume);
    if ~isempty(CovariateDirs)
        [AllVolume,VoxelSize,theImgFileList, Header_Covariate] = y_ReadAll(CovariateDirs{i});
        fprintf('\n\tImage Files in Covariate %d:\n',i);
        for itheImgFileList=1:length(theImgFileList)
            fprintf('\t%s\n',theImgFileList{itheImgFileList});
        end
        CovariateVolume=cat(FinalDim,CovariateVolume,AllVolume);
        
        SizeDependentVolume=size(DependentVolume);
        SizeCovariateVolume=size(CovariateVolume);
        if ~isequal(SizeDependentVolume,SizeCovariateVolume)
            msgbox('The dimension of covariate image is different from the dimension of group image, please check them!','Dimension Error','error');
            return;
        end
    end
    if ~isempty(OtherCovariates)
        OtherCovariatesMatrix=[OtherCovariatesMatrix;OtherCovariates{i}];
    end
    GroupLabel=[GroupLabel;ones(size(AllVolume,FinalDim),1)*i];
    clear AllVolume
end

if ~isfield(Header,'cdata') && ~isfield(Header,'MatrixNames') %YAN Chao-Gan 181204. If NIfTI data
    [nDim1,nDim2,nDim3,nDimTimePoints]=size(DependentVolume);
else
    [nDimVertex nDimTimePoints]=size(DependentVolume);
end

GroupLabelUnique=unique(GroupLabel);
Df_Group=length(GroupLabelUnique)-1;
GroupDummyVariable=zeros(nDimTimePoints,Df_Group);
for i=1:Df_Group
    GroupDummyVariable(:,i)=GroupLabel==GroupLabelUnique(i);
end


Regressors = [GroupDummyVariable,ones(nDimTimePoints,1),OtherCovariatesMatrix];

if exist('CovariateDirs','var') && ~isempty(CovariateDirs)
    Contrast = zeros(1,size(Regressors,2)+1);
else
    Contrast = zeros(1,size(Regressors,2));
end
Contrast(1:Df_Group) = 1;


[b_OLS_brain, t_OLS_brain, ANCOVA_F, r_OLS_brain, Header, SSE_OLS_brain] = y_GroupAnalysis_Image(DependentVolume,Regressors,OutputName,MaskFile,CovariateVolume,Contrast,'F',0,Header);
%[b_OLS_brain, t_OLS_brain, TF_ForContrast_brain, r_OLS_brain, Header, SSE_OLS_brain] = y_GroupAnalysis_Image(DependentVolume,Predictor,OutputName,MaskFile,CovVolume,Contrast,TF_Flag,IsOutputResidual,Header)

fprintf('\n\tANCOVA Test Calculation finished.\n');

if ~strcmp(ctype,'None')
    fprintf('\n\tMultiple comparison test begin...\n');
    
    Df_E = size(Regressors,1) - size(Contrast,2);
    s_brain = sqrt(SSE_OLS_brain/Df_E);
    
    if ~isfield(Header,'cdata') && ~isfield(Header,'MatrixNames') %YAN Chao-Gan 181204. If NIfTI data
        for iGroup = 1:length(GroupLabelUnique)
            GroupMeans(:,:,:,iGroup) = mean(DependentVolume(:,:,:,find(GroupLabel==GroupLabelUnique(iGroup))),4);
            n(iGroup,1) = length(find(GroupLabel==GroupLabelUnique(iGroup)));
        end
        
        if ~isempty(MaskFile)
            [MaskData,MaskVox,MaskHead]=y_ReadRPI(MaskFile);
        else
            MaskData=ones(nDim1,nDim2,nDim3);
        end
        
        MaskData = any(DependentVolume,4) .* MaskData; % skip the voxels with all zeros
        
        M = nchoosek(1:GroupNumber, 2);      % all pairs of group numbers
        PairwiseDiff_Brain = zeros(nDim1,nDim2,nDim3,size(M,1));
        Pairwise_p_Brain = zeros(nDim1,nDim2,nDim3,size(M,1));
        Pairwise_Z_Brain = zeros(nDim1,nDim2,nDim3,size(M,1));
        alpha = 0.05;
        for i=1:nDim1
            fprintf('.');
            for j=1:nDim2
                for k=1:nDim3
                    if MaskData(i,j,k)
                        gmeans = squeeze(GroupMeans(i,j,k,:));
                        df = Df_E;
                        s = s_brain(i,j,k);
                        ng = sum(n>0);
                        gcov = diag((s^2)./n);
                        
                        [mn,se] = tValue(gmeans,gcov);
                        t = mn./se;
                        
                        [crit,pval] = getcrit(ctype, alpha, df, ng, t);
                        
                        PairwiseDiff_Brain(i,j,k,:) = mn;
                        Pairwise_p_Brain(i,j,k,:) = pval;
                        
                        %ZTemp=norminv(1 - PTemp); % Doing one tailed!!!
                        ZTemp = norminv(1 - pval/2).*sign(mn); % Doing two tailed!!!
                        Pairwise_Z_Brain(i,j,k,:) = ZTemp;
                    end
                end
            end
        end
        
        Header.pinfo = [1;0;0];
        Header.dt    = [16,0];
        [Path, Name, Ext]=fileparts(OutputName);
        Name=fullfile(Path, Name);
        for i=1:size(M,1)
            Header.descrip=sprintf('PairwiseDiff: mean');
            y_Write(PairwiseDiff_Brain(:,:,:,i),Header,sprintf('%s_PairwiseDiff_G%gvsG%g.nii',Name,M(i,1),M(i,2)));
            Header.descrip=sprintf('PairwiseDiff: p');
            y_Write(Pairwise_p_Brain(:,:,:,i),Header,sprintf('%s_PairwiseDiff_p_G%gvsG%g.nii',Name,M(i,1),M(i,2)));
            Header.descrip=sprintf('DPABI{Z_[%.1f]}',1);
            y_Write(Pairwise_Z_Brain(:,:,:,i),Header,sprintf('%s_PairwiseDiff_Z_G%gvsG%g.nii',Name,M(i,1),M(i,2)));
        end
        
    else %If GIfTI data
        for iGroup = 1:length(GroupLabelUnique)
            GroupMeans(:,iGroup) = mean(DependentVolume(:,find(GroupLabel==GroupLabelUnique(iGroup))),2);
            n(iGroup,1) = length(find(GroupLabel==GroupLabelUnique(iGroup)));
        end
        
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
        
        M = nchoosek(1:GroupNumber, 2);      % all pairs of group numbers
        PairwiseDiff_Brain = zeros(nDimVertex,size(M,1));
        Pairwise_p_Brain = zeros(nDimVertex,size(M,1));
        Pairwise_Z_Brain = zeros(nDimVertex,size(M,1));
        alpha = 0.05;
        for i=1:nDimVertex
            if MaskData(i,1)
                gmeans = squeeze(GroupMeans(i,:))';
                df = Df_E;
                s = s_brain(i,1);
                ng = sum(n>0);
                gcov = diag((s^2)./n);
                
                [mn,se] = tValue(gmeans,gcov);
                t = mn./se;
                
                [crit,pval] = getcrit(ctype, alpha, df, ng, t);
                
                PairwiseDiff_Brain(i,:) = mn;
                Pairwise_p_Brain(i,:) = pval;
                
                %ZTemp=norminv(1 - PTemp); % Doing one tailed!!!
                ZTemp = norminv(1 - pval/2).*sign(mn); % Doing two tailed!!!
                Pairwise_Z_Brain(i,:) = ZTemp;
            end
        end

        [Path, Name, Ext]=fileparts(OutputName);
        Name=fullfile(Path, Name);
        for i=1:size(M,1)
            if isfield(Header,'cdata')
                Header.private.metadata = [Header.private.metadata, struct('name','FileType','value',sprintf('PairwiseDiff: mean'))];
                y_Write(PairwiseDiff_Brain(:,i),Header,sprintf('%s_PairwiseDiff_G%gvsG%g.gii',Name,M(i,1),M(i,2)));
                Header.private.metadata = [Header.private.metadata, struct('name','FileType','value',sprintf('PairwiseDiff: p'))];
                y_Write(Pairwise_p_Brain(:,i),Header,sprintf('%s_PairwiseDiff_p_G%gvsG%g.gii',Name,M(i,1),M(i,2)));
                Header.private.metadata = [Header.private.metadata, struct('name','DOF','value',sprintf('DPABI{Z_[%.1f]}',1))];
                y_Write(Pairwise_Z_Brain(:,i),Header,sprintf('%s_PairwiseDiff_Z_G%gvsG%g.gii',Name,M(i,1),M(i,2)));
            elseif isfield(Header,'MatrixNames') %YAN Chao-Gan 210122. Add DPABINet Matrix support.
                y_Write(PairwiseDiff_Brain(:,i),Header,sprintf('%s_PairwiseDiff_G%gvsG%g.mat',Name,M(i,1),M(i,2)));
                y_Write(Pairwise_p_Brain(:,i),Header,sprintf('%s_PairwiseDiff_p_G%gvsG%g.mat',Name,M(i,1),M(i,2)));
                HeaderTWithDOF=Header;
                HeaderTWithDOF.OtherInfo.StatOpt.TestFlag='Z';
                HeaderTWithDOF.OtherInfo.StatOpt.Df=1;
                y_Write(Pairwise_Z_Brain(:,i),HeaderTWithDOF,sprintf('%s_PairwiseDiff_Z_G%gvsG%g.mat',Name,M(i,1),M(i,2)));
            end
        end

        fprintf('\n\tMultiple comparison test finished.\n');
    end
end




function [crit,pval] = getcrit(ctype, alpha, df, ng, t)
% Get the minimum of the specified critical values
crit = Inf;
[onetype,ctype] = strtok(ctype);

while(~isempty(onetype))
    if (length(onetype) == 1)
        switch onetype
            case 't', onetype = 'tukey-kramer';
            case 'd', onetype = 'dunn-sidak';
            case 'b', onetype = 'bonferroni';
            case 's', onetype = 'scheffe';
            case 'h', onetype = 'tukey-kramer';
            case 'l', onetype = 'lsd';
        end
    end
    if (isequal(onetype, 'hsd')), onetype = 'tukey-kramer'; end
    
    switch onetype
        case 'tukey-kramer' % or hsd
            crit1 = internal.stats.stdrinv(1-alpha, df, ng) / sqrt(2);
            
            % The T-K algorithm is inaccurate for small alpha, so compute
            % an upper bound for it and make sure it's in range.
            ub = getcrit('dunn-sidak', alpha, df, ng, t);
            if (crit1 > ub), crit1 = ub; end
            pval = 0*t;
            for j=1:numel(t)
                pval(j) = 1 - y_stdrcdf(sqrt(2)*abs(t(j)),df,ng);
            end
            
        case 'dunn-sidak'
            kstar = nchoosek(ng, 2);
            alf = 1-(1-alpha).^(1/kstar);
            if (isinf(df))
                crit1 = norminv(1-alf/2);
            else
                crit1 = tinv(1-alf/2, df);
            end
            pval = 1 - (1-2*tcdf(-abs(t),df)).^kstar;
            
        case 'bonferroni'
            kstar = nchoosek(ng, 2);
            if (isinf(df))
                crit1 = norminv(1 - alpha / (2*kstar));
            else
                crit1 = tinv(1 - alpha / (2*kstar), df);
            end
            pval = 2*kstar*tcdf(-abs(t),df);
            
        case 'lsd'
            if (isinf(df))
                crit1 = norminv(1 - alpha / 2);
            else
                crit1 = tinv(1 - alpha / 2, df);
            end
            pval = 2*tcdf(-abs(t),df);
            
        case 'scheffe'
            if (isinf(df))
                tmp = chi2inv(1-alpha, ng-1) / (ng-1);
            else
                tmp = finv(1-alpha, ng-1, df);
            end
            crit1 = sqrt((ng-1) * tmp);
            pval = fcdf((t.^2)/(ng-1),ng-1,df,'upper');
            
        otherwise
            error(message('stats:multcompare:BadCType', ctype));
    end
    
    pval(pval>1) = 1;
    if (~isnan(crit1)), crit = min(crit, crit1); end
    [onetype,ctype] = strtok(ctype);
end



function [mn,se]= tValue(gmeans,gcov)
% Make sure NaN groups don't affect other results
t = isnan(gmeans);
if any(t)
    gcov(t,:) = 0;
    gcov(:,t) = 0;
end
ng = length(gmeans);
M = nchoosek(1:ng, 2);      % all pairs of group numbers
g1 = M(:,1);
g2 = M(:,2);
mn = gmeans(g1) - gmeans(g2);
i12 = sub2ind(size(gcov), g1, g2);
gvar = diag(gcov);
se = sqrt(gvar(g1) + gvar(g2) - 2 * gcov(i12));



