function y_ICC_Image_ReML(Rate1Dir,Rate2Dir,OutputName,MaskFile)
% function y_ICC_Image_ReML(Rate1Dir,Rate2Dir,OutputName,MaskFile)
% Calculate the Intraclass correlation coefficient for brain images.
% Note: the ICC calculation is based on Xi-Nian Zuo's LFCD_lmm0
% Use ReML Model; Zuo, X.N., Xing, X.X., 2011. Effects of non-local diffusion on structural MRI preprocessing and default network mapping: statistical comparisons with isotropic/anisotropic diffusion. PLoS ONE 6, e26703.
%   Input:
%     Group1Dir - Cell, directory of the first group. Take average if multiple sessions
%     Group2Dir - Cell, directory of the the second group. Take average if multiple sessions
%   Output:
%     OutputName - image with ICC
%___________________________________________________________________________
% Written by YAN Chao-Gan 110901.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com

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
    for i=1:nDim1
        for j=1:nDim2
            for k=1:nDim3
                if MaskData(i,j,k)
                    xA=squeeze(Rate1Series(i,j,k,:));
                    xB=squeeze(Rate2Series(i,j,k,:));
                    xAxB = [xA,xB];
                    if any(std(xAxB))  %If no variance, then skip the calculation
                        ICCBrain(i,j,k)=LFCD_lmm0( xAxB ); % Use ReML Model; Zuo, X.N., Xing, X.X., 2011. Effects of non-local diffusion on structural MRI preprocessing and default network mapping: statistical comparisons with isotropic/anisotropic diffusion. PLoS ONE 6, e26703.
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
    for i=1:nDimVertex
        if MaskData(i,1)
            xA=Rate1Series(i,:)';
            xB=Rate2Series(i,:)';
            %ICCBrain(i,1)=IPN_icc([xA,xB],1,'single');
            xAxB = [xA,xB];
            if any(std(xAxB))  %If no variance, then skip the calculation
                ICCBrain(i,1)=LFCD_lmm0( xAxB ); % Use ReML Model; Zuo, X.N., Xing, X.X., 2011. Effects of non-local diffusion on structural MRI preprocessing and default network mapping: statistical comparisons with isotropic/anisotropic diffusion. PLoS ONE 6, e26703.
            else
                ICCBrain(i,1) = 0;
            end
        end
    end
end


ICCBrain(isnan(ICCBrain))=0;
y_Write(ICCBrain,Header,OutputName);




