function y_ICC_Image_LMM(Rate1Dir,Rate2Dir,OutputName,MaskFile)
% function y_ICC_Image_LMM(Rate1Dir,Rate2Dir,OutputName,MaskFile)
% Calculate the Intraclass correlation coefficient for brain images.
% Note: the ICC values were derived by linear mixed models (LMMs) as in Zuo et al. (2013): Zuo, X.N., Xu, T., Jiang, L., Yang, Z., Cao, X.Y., He, Y., Zang, Y.F., Castellanos, F.X., Milham, M.P., 2013. Toward reliable characterization of functional homogeneity in the human brain: preprocessing, scan duration, imaging resolution and computational space. Neuroimage 65, 374?386.
%   Input:
%     Group1Dir - Cell, directory of the first group. Take average if multiple sessions
%     Group2Dir - Cell, directory of the the second group. Take average if multiple sessions
%   Output:
%     OutputName - image with ICC
%___________________________________________________________________________
% Written by YAN Chao-Gan 140901.
% First used in the paper: Yan, C.G., Craddock, R.C., Zuo, X.N., Zang, Y.F., Milham, M.P., 2013. Standardizing the intrinsic brain: towards robust measurement of inter-individual variation in 1000 functional connectomes. Neuroimage 80, 246-262.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com


[ProgramPath, fileN, extn] = fileparts(which('y_ICC_Image_LMM.m'));
addpath([ProgramPath,filesep,'long_mixed_effects_matlab-tools']);
addpath([ProgramPath,filesep,'long_mixed_effects_matlab-tools',filesep,'univariate']);

Rate1Series=0;
for i=1:length(Rate1Dir)
    [Temp,VoxelSize,theImgFileList, Header] =y_ReadAll(Rate1Dir{i});
    Rate1Series = Rate1Series + Temp;
    fprintf('\n\tImage Files in Rate %d Directory %d:\n',1, i);
    for itheImgFileList=1:length(theImgFileList)
        fprintf('\t%s%s\n',theImgFileList{itheImgFileList},'.img');
    end
end
Rate1Series = Rate1Series ./ (length(Rate1Dir));


Rate2Series=0;
for i=1:length(Rate2Dir)
    [Temp,VoxelSize,theImgFileList, Header] =y_ReadAll(Rate2Dir{i});
    Rate2Series = Rate2Series + Temp;
    fprintf('\n\tImage Files in Rate %d Directory %d:\n',2, i);
    for itheImgFileList=1:length(theImgFileList)
        fprintf('\t%s%s\n',theImgFileList{itheImgFileList},'.img');
    end
end
Rate2Series = Rate2Series ./ (length(Rate2Dir));



if ~isfield(Header,'cdata') && ~isfield(Header,'MatrixNames') %YAN Chao-Gan 210402. If NIfTI data
    [nDim1,nDim2,nDim3,nDim4]=size(Rate2Series);
    if ~isempty(MaskFile)
        [MaskData,MaskVox,MaskHead]=y_ReadRPI(MaskFile);
    else
        MaskData=ones(nDim1,nDim2,nDim3);
    end
    ICCBrain=zeros(nDim1,nDim2,nDim3);
    %%%For LMM Only
    time = [ones(nDim4,1);2*ones(nDim4,1)];
    sID=[[1:nDim4]';[1:nDim4]'];
    %%%
    for i=1:nDim1
        for j=1:nDim2
            for k=1:nDim3
                if MaskData(i,j,k)
                    xA=squeeze(Rate1Series(i,j,k,:));
                    xB=squeeze(Rate2Series(i,j,k,:));
                    %ICCBrain(i,j,k)=IPN_icc([xA,xB],1,'single');
                    xAxB = [xA;xB];
                    if std(xAxB)~=0  %If no variance, then skip the calculation
                        ICCBrain(i,j,k) = do_ICC([xA;xB], time, [], [], sID);
                    else
                        ICCBrain(i,j,k) = 0;
                    end
                end
            end
        end
    end
else
    [nDimVertex nDimTimePoints]=size(Rate2Series);
    fprintf('\nLoad mask "%s".\n', MaskFile);
    if ~isempty(MaskFile)
        MaskData=y_ReadAll(MaskFile);
        if size(MaskData,1)~=nDimVertex
            error('The size of Mask (%d) doesn''t match the required size (%d).\n',size(MaskData,1), nDimVertex);
        end
        MaskData = double(logical(MaskData));
    else
        MaskData=ones(nDimVertex,1);
    end
    ICCBrain=zeros(nDimVertex,1);
    time = [ones(nDimTimePoints,1);2*ones(nDimTimePoints,1)];
    sID=[[1:nDimTimePoints]';[1:nDimTimePoints]'];
    for i=1:nDimVertex
        if MaskData(i,1)
            xA=Rate1Series(i,:)';
            xB=Rate2Series(i,:)';
            %ICCBrain(i,1)=IPN_icc([xA,xB],1,'single');
            xAxB = [xA;xB];
            if std(xAxB)~=0  %If no variance, then skip the calculation
                ICCBrain(i,1) = do_ICC([xA;xB], time, [], [], sID);
            else
                ICCBrain(i,1) = 0;
            end
        end
    end
end


ICCBrain(isnan(ICCBrain))=0;
y_Write(ICCBrain,Header,OutputName);


