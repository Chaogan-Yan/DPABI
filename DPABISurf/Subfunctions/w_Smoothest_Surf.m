function FWHM=w_Smoothest_Surf(SurfFiles, ResidualFiles, MskFiles)
% Estimate global FWHM for surface files
% %------------------------------------------------------------------------
% Usage: FWHM=w_Smoothest_Surf(SurfFiles, ResidualFiles, MskFiles)
%
% Input:
%   SurfFiles     - Surface file list, nx1 cell. e.g., {'fsaverage5_lh_white.surf.gii'}
%   ResidualFiles - Residual file list generated from statistical module, nx1 cell.
%                   Or residual matrix, within nx1 cell.
%   MskFiles      - Mask file list for region of interest, nx1 cell. e.g., {'fsaverage5_rh_cortex.label.gii'}
%
% Output:
%   FWHM          - The estimated full width half high of smooth kernel.
%
% Written by Sandy Wang 20200527.
% Montreal Neurological Institute (MNI), McGill University.
% sandywang.rest@gmail.com

% Revised by YAN Chao-Gan, 20200528.

if numel(SurfFiles)~=numel(ResidualFiles)
    error('Unmatched number of Surface and Residual files');
end

if exist('MskFiles', 'var') && ~isempty(MskFiles)
    if numel(SurfFiles)~=numel(MskFiles)
        error('Applied Mask files, but unmatched number of Surface and Mask files');
    end
end

NumEstimate=numel(SurfFiles);
FWHM=zeros(NumEstimate, 1);
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
    
    if ~isnumeric(ResidualFiles{n}) %YAN Chao-Gan, 20200528. Should also accept residual matrices.
        ResVal=y_ReadAll(ResidualFiles{n});
        if size(ResVal, 1)~=size(SurfStruct.vertices, 1)
            error('Unmatched number of vertices for %s and %s',...
                SurfFiles{n}, ResidualFiles{n});
        end
    else
        ResVal=ResidualFiles{n};
        if size(ResVal, 1)~=size(SurfStruct.vertices, 1)
            error('Unmatched number of vertices for %s and residual matrix',...
                SurfFiles{n});
        end
    end
    
    
    % Calculate Total Area
    TotalArea=spm_mesh_area(SurfStruct);
    Vertices=SurfStruct.vertices;
    Faces=SurfStruct.faces;
    
    NumVertex=size(Vertices, 1);
    NumFace=size(Faces, 1);
    
    % Load Mask files if exist
    Msk=true(NumVertex, 1);
    if exist('MskFiles', 'var') && ~isempty(MskFiles{n})
        MskStruct=gifti(MskFiles{n});
        if size(MskStruct.cdata, 1)~=size(SurfStruct.vertices, 1)
            error('Unmatched number of vertices for %s and %s',...
                SurfFiles{n}, MskFiles{n});
        end
        Msk=logical(MskStruct.cdata);
    end    

    VD=zeros(NumVertex, 1);
    VAR1=zeros(NumVertex, 1);
    for i=1:NumVertex
        v_ind=sum(Faces==i, 2)~=0;
        n_ind=unique(Faces(v_ind, :));
        
        % Obtain Neibor Vertex
        n_ind=n_ind(~(n_ind==i));
        % Estimate Inter-Vertex Distance
        CoordVertex=Vertices(i, :);
        CoordNeibor=Vertices(n_ind, :);
        d=pdist2(CoordVertex, CoordNeibor);
        VD(i, 1)=mean(d);
        
        if ~Msk(i)
            continue
        end        
        % Exclude Ripped Vertices
        n_ind=n_ind(Msk(n_ind));
        
        % Estimate AR1 Vertex-by-Vertex
        ResSeriesVertex=ResVal(i, :)';
        ResSeriesNeibor=ResVal(n_ind, :)';
        
        r=corr(ResSeriesVertex, ResSeriesNeibor);
        r(isnan(r))=[];
        VAR1(i, 1)=mean(r);
        
    end
    Scale=sqrt(GroupSurface/TotalArea);
    VAR1(isnan(VAR1))=0;
    FWHM(n ,1) =Scale.*mean(VD)*sqrt(-log(256)/(4*log(mean(VAR1(Msk)))));
end

