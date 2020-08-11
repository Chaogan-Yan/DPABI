function NumIters=w_FWHMToNITERS_Surf(FWHM, SurfFiles)
% Estimate number of iterations for specific FWHM
% %------------------------------------------------------------------------
% Usage: FWHM=w_FWHMToNITERS_Surf(FWHM, SurfFiles)
%
% Input:
%     FWHM      - Full width half high kernel for smoothing.
%     SurfFiles - Surface file list used to estimate iteration, nx1 cell.
%
% Output:
%     NumIters  - Number of iterations matching FWHM.
%
% Written by Sandy Wang 20200723.
% Montreal Neurological Institute (MNI), McGill University.
% sandywang.rest@gmail.com

% Revised by YAN Chao-Gan, 20200811.

NumEstimate=numel(SurfFiles);
NumIters=zeros(NumEstimate, 1);

for n=1:NumEstimate
    % Set Group Surface Area
    
    [Path, fileN, extn] = fileparts(SurfFiles{n});

    switch fileN
        case 'fsaverage_lh_white.surf'
            GroupSurface=82219.960938;
        case 'fsaverage_rh_white.surf'
            GroupSurface=82167.578125;
        case 'fsaverage5_lh_white.surf'
            GroupSurface=84969.304688;
        case 'fsaverage5_rh_white.surf'
            GroupSurface=85131.226562;
        otherwise
            error('Invalid Surface file: %s, please select fsaverage or fsaverage5 from SurfTemplates folder',...
                SurfFiles{n})
    end
    
    
    % Load Surface files and Residual files
    SurfStruct=gifti(SurfFiles{n});
    
    % Calculate Total Area
    TotalArea=spm_mesh_area(SurfStruct);
    Vertices=SurfStruct.vertices;
    %Faces=SurfStruct.faces;
    
    NumVertex=size(Vertices, 1);
    
    % Calculate scale between specific surface and fsaverage
    Scale=GroupSurface/TotalArea;
    
    % Calculate the average area for each vertex
    AvgVtxArea=TotalArea./NumVertex;
    AvgVtxArea=AvgVtxArea.*Scale;
    
    gstd=FWHM./sqrt(log(256));
    NumIters(n, 1)=floor( 1.14 * (4*pi*(gstd*gstd))./(7.*AvgVtxArea) + 0.5 );
end
