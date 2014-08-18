function [SphereData, Header] = y_Sphere(Center, Radius, RefFile, OutFile, Unit)
%function [SphereData, Header] = y_Sphere(Center, Radius, RefFile, OutFile, Unit)
% Create a Sphere ROI
% ------------------------------------------------------------------------
% Input:
% Center - the coordinates of the center of a shpere ROI. 1 by 3 vector, could use XYZ mm,
%                                                                        or IJK index
% Radius - the Radius of the center of a shpere ROI. Could use XYZ mm,
%                                               or number of voxels
% RefFile - the reference image file, based on whose header and brain size to create the sphere ROI
% [OutFile] - The filename to output the sphere ROI
% [Unit] - The unit of Center and Radius, could be:
%        - 'XYZ' (default): the unit of center and Radius is mm coordinates
%        - 'IJK': the unit of center and Radius is matrix IJK index
% Output:
% ShpereData - The 3D matrix within which contains a sphere
% Header - The NIfTI header.
% And a sphere ROI image file is outputed into OutFile.
%__________________________________________________________________________
% Written by YAN Chao-Gan 130716.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com

if ~exist('Unit', 'var')
    Unit='XYZ';
end

if ~isstruct(RefFile) %RefFile is a NIfTI file
    [Data VoxelSize Header] = y_ReadRPI(RefFile,1);
else %RefFlie is actually a NIfTI Header struct
    Header = RefFile;
    VoxelSize = sqrt(sum(Header.mat(1:3,1:3).^2));
end

nDim1 = Header.dim(1);nDim2 = Header.dim(2);nDim3 = Header.dim(3);

if strcmpi(Unit,'XYZ') % XYZ mm unit

    Center = round((inv(Header.mat)*[Center,1]')); %Get the center voxel IJK from input center XYZ mm
    CenterXYZRevised = Header.mat*Center; %Center voxel IJK rounded, so revise the XYZ mm
    CenterXYZRevised = CenterXYZRevised(1:3);
    
    Center = Center(1:3)';
    
    Min = Center - ([Radius,Radius,Radius]./VoxelSize);
    Min = fix(max(1,Min));
    
    Max = Center + ([Radius,Radius,Radius]./VoxelSize);
    Max = ceil(min([nDim1,nDim2,nDim3],Max));

    SphereData = zeros(nDim1,nDim2,nDim3);

    for i=Min(1):Max(1)
        for j=Min(2):Max(2)
            for k=Min(3):Max(3)

                XYZ = Header.mat*[i j k 1]';
                XYZ = XYZ(1:3);
                
                if sqrt(sum( (XYZ - CenterXYZRevised).^2 )) <= Radius
                    SphereData(i,j,k) = 1;
                end

            end
        end
    end

else % IJK index unit
    Min = Center - [Radius,Radius,Radius];
    Min = fix(max(1,Min));
    
    Max = Center + [Radius,Radius,Radius];
    Max = ceil(min([nDim1,nDim2,nDim3],Max));

    SphereData = zeros(nDim1,nDim2,nDim3);
    for i=Min(1):Max(1)
        for j=Min(2):Max(2)
            for k=Min(3):Max(3)
                
                if sqrt(sum( ([i j k] - Center).^2 )) <= Radius
                    SphereData(i,j,k) = 1;
                end

            end
        end
    end

end

if exist('OutFile', 'var')
    y_Write(SphereData,Header,OutFile);
end

fprintf('Sphere ROI Center: %g %g %g\tRadius: %g\tBrain Size: %g %g %g\tVoxel Size: %g %g %g\nContained Voxels: %g\n', Center(1),Center(2),Center(3), Radius, nDim1,nDim2,nDim3, VoxelSize(1),VoxelSize(2),VoxelSize(3), length(find(SphereData)) );
