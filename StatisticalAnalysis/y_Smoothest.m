function [dLh,resels,FWHM, nVoxels]=y_Smoothest(StatsImgFile, MaskFile, DOF, VoxelSize)
% function [dLh,resels,FWHM, nVoxels]=y_Smoothest(StatsImgFile, MaskFile, DOF, VoxelSize)
% Function to estimate smoothness like smoothest in FSL.
% Reference: Flitney, D.E., & Jenkinson, M. 2000. Cluster Analysis Revisited. Tech. rept. Oxford Centre for Functional Magnetic Resonance Imaging of the Brain, Department of Clinical Neurology, Oxford University, Oxford, UK. TR00DF1.
% Input:
%     StatsImgFile      - The Z statistcal image file name.
%     MaskFile          - The mask file name. If empty (i.e., ''), then all voxels are included.
%     DOF               - Degree of freedom if residule images are used. Only effective when the time points in StatsImgFile is bigger than 1.
%     VoxelSize         - if StatsImgFile is not given as the file name but as the data matrix, then VoxelSize need to be specified also.
% Output:
%     dLh               - Smoothness estimated as sqrt(det(Lambda)), can be used in inference.
%     resels            - The size of one Resel: volume of space with dimensions FWHMx, FWHMy and FWHMz (in voxels).
%     FWHM              - FWHM in x, y, z. Note: in mm
%     nVoxels           - Number of voxels in the mask
%___________________________________________________________________________
% Written by YAN Chao-Gan 120120.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com

if nargin<3
    DOF=100; %Used when nDimTimePoints > 1
end

if ischar(StatsImgFile)
    [AllVolume, VoxelSize, Header] =y_ReadRPI(StatsImgFile);
else
    AllVolume = StatsImgFile;
end

[nDim1 nDim2 nDim3 nDimTimePoints]=size(AllVolume);
if ~isempty(MaskFile)
    if ischar(MaskFile)
        [MaskData,MaskVox,MaskHead]=y_ReadRPI(MaskFile);
    else
        MaskData=MaskFile;
    end
else
    MaskData=ones(nDim1,nDim2,nDim3);
end
AllVolume=single(AllVolume);
if nDimTimePoints>2
    AllVolume = (AllVolume-repmat(mean(AllVolume,4),[1,1,1, nDimTimePoints]))./repmat(std(AllVolume,0,4),[1,1,1, nDimTimePoints]);   %Zero mean and one std
    AllVolume(isnan(AllVolume))=0;
end

SSminus=[0 0 0];
S2=[0 0 0];

N=0;
for x=2:nDim1
    for y=2:nDim2
        for z=2:nDim3
            if MaskData(x, y, z) && MaskData(x-1, y, z) && MaskData(x, y-1, z) && MaskData(x, y, z-1)
                N=N+1;
                for t=1:nDimTimePoints
                    SSminus(1) = SSminus(1) + AllVolume(x, y, z, t) * AllVolume(x-1, y, z, t);
                    SSminus(2) = SSminus(2) + AllVolume(x, y, z, t) * AllVolume(x, y-1, z, t);
                    SSminus(3) = SSminus(3) + AllVolume(x, y, z, t) * AllVolume(x, y, z-1, t);
                    
                    S2(1) = S2(1) + 0.5 * ((AllVolume(x, y, z, t)^2) + (AllVolume(x-1, y, z, t)^2));
                    S2(2) = S2(2) + 0.5 * ((AllVolume(x, y, z, t)^2) + (AllVolume(x, y-1, z, t)^2));
                    S2(3) = S2(3) + 0.5 * ((AllVolume(x, y, z, t)^2) + (AllVolume(x, y, z-1, t)^2));
                end
            end
        end
    end
    fprintf('.');
end

if SSminus(1)>0.99999999*S2(1)
    SSminus(1)=0.99999999*S2(1);
    warning('possibly biased smootheness in X');
end
if SSminus(2)>0.99999999*S2(2)
    SSminus(2)=0.99999999*S2(2);
    warning('possibly biased smootheness in Y');
end
if SSminus(3)>0.99999999*S2(3)
    SSminus(3)=0.99999999*S2(3);
    warning('possibly biased smootheness in Z');
end

sigmasq(1) = -1 / (4 * log(abs(SSminus(1)/S2(1))));
sigmasq(2) = -1 / (4 * log(abs(SSminus(2)/S2(2))));
sigmasq(3) = -1 / (4 * log(abs(SSminus(3)/S2(3))));

dLh=((sigmasq(1)*sigmasq(2)*sigmasq(3))^-0.5)*(8^-0.5);

if nDimTimePoints > 1
    fprintf('DLH %f voxels^-3 before correcting for temporal DOF\n',dLh);
    
    lut(6)   = 1.5423138; lut(7)   = 1.3757105; lut(8)   = 1.2842680;
    lut(9)   = 1.2272151; lut(10)  = 1.1885232; lut(11)  = 1.1606988;
    lut(12)  = 1.1398000; lut(13)  = 1.1235677; lut(14)  = 1.1106196;
    lut(15)  = 1.1000651; lut(16)  = 1.0913060; lut(17)  = 1.0839261;
    lut(18)  = 1.0776276; lut(19)  = 1.0721920; lut(20)  = 1.0674553;
    lut(21)  = 1.0632924; lut(26)  = 1.0483053; lut(31)  = 1.0390117;
    lut(41)  = 1.0281339; lut(51)  = 1.0219834; lut(61)  = 1.0180339;
    lut(71)  = 1.0152850; lut(81)  = 1.0132621; lut(91)  = 1.0117115;
    lut(101) = 1.0104851; lut(151) = 1.0068808; lut(201) = 1.0051200;
    lut(301) = 1.0033865; lut(501) = 1.0020191;
    
    y = lut(lut~=0);
    x = find(lut~=0);
    xi=[1:501];
    lut_interpolated=interp1(x,y,xi,'linear');
    
    if (DOF < 6)
        dLh=dLh * 1.1;
    elseif (DOF>500)
        dLh=dLh * (1.0321/DOF +1)^0.5;
    else
        retval=(lut_interpolated(floor(DOF)+1)-lut_interpolated(floor(DOF)))*(DOF-floor(DOF)+1) + ...
            lut_interpolated(floor(DOF)+1);
        dLh=dLh * retval^0.5;
    end
    
end

FWHM(1) =  sqrt(8 * log(2) * sigmasq(1));
FWHM(2) =  sqrt(8 * log(2) * sigmasq(2));
FWHM(3) =  sqrt(8 * log(2) * sigmasq(3));

resels = FWHM(1)*FWHM(2)*FWHM(3);
fprintf('\nFWHMx = %f voxels\nFWHMy = %f voxels\nFWHMz = %f voxels\n',FWHM(1),FWHM(2),FWHM(3));
FWHM=FWHM.*VoxelSize;
fprintf('FWHMx = %f mm\nFWHMy = %f mm\nFWHMz = %f mm\n',FWHM(1),FWHM(2),FWHM(3));
nVoxels=length(find(MaskData));
fprintf('DLH = %f\nVOLUME = %d\nRESELS = %f\n',dLh,nVoxels,resels);
