function FWHM=w_Smoothest_Surf(SurfFiles, ResidualFiles, MskFiles)
% Estimate global FWHM for surface files
% %------------------------------------------------------------------------
% Usage: FWHM=w_Smoothest_Surf(SurfFiles, ResidualFiles, MskFiles)
%
% Input:
%   SurfFiles     - Surface file list, nx1 cell. e.g., {'fsaverage5_lh_white.surf.gii'}
%                 - If empty, then determine from MskFiles
%   ResidualFiles - Residual (Alternatively, Statistical) file list generated from statistical module, nx1 cell.
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


if exist('MskFiles', 'var') && ~isempty(MskFiles)
    if numel(ResidualFiles)~=numel(MskFiles)
        error('Applied Mask files, but unmatched number of data and Mask files');
    end
end

NumEstimate=numel(ResidualFiles);
FWHM=zeros(NumEstimate, 1);
SurfFilesInput=SurfFiles;
for n=1:NumEstimate
    % Set Group Surface Area
    
    if isempty(SurfFilesInput)
        if exist('MskFiles', 'var') && ~isempty(MskFiles{n})
            [Path, fileN, extn] = fileparts(MskFiles{n});
            DPABISurfPath=fileparts(which('DPABISurf.m'));
            switch fileN
                case 'fsaverage_lh_cortex.label'
                    SurfFiles{n}=fullfile(DPABISurfPath, 'SurfTemplates', 'fsaverage_lh_white.surf.gii');
                case 'fsaverage_rh_cortex.label'
                    SurfFiles{n}=fullfile(DPABISurfPath, 'SurfTemplates', 'fsaverage_rh_white.surf.gii');
                case 'fsaverage5_lh_cortex.label'
                    SurfFiles{n}=fullfile(DPABISurfPath, 'SurfTemplates', 'fsaverage5_lh_white.surf.gii');
                case 'fsaverage5_rh_cortex.label'
                    SurfFiles{n}=fullfile(DPABISurfPath, 'SurfTemplates', 'fsaverage5_rh_white.surf.gii');
                otherwise
                    error('As you didn''t define SurfFiles, you can only use standard masks such as fsaverage5_lh_white.surf.gii')
            end
        else
            error('As you didn''t define SurfFiles, you have to define MskFiles with standard masks such as fsaverage5_lh_white.surf.gii')
        end
    end
    
    
    
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
    
    if size(ResVal, 2)==1
        IsStatMap=true;
    else
        IsStatMap=false;
    end
    SSminus=0;
    S2=0;
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
        
        if IsStatMap
            SSminus=SSminus+mean(ResVal(i, 1).*ResVal(n_ind, 1));
            S2=S2+0.5*(ResVal(i, 1)^2+mean(ResVal(n_ind, 1).^2));
            %r=2*mean(ResVal(i, 1).*ResVal(n_ind, 1))./mean(ResVal(i, 1)^2+ResVal(n_ind, 1).^2);
            %VAR1(i, 1)=mean(r);
        else
            % Estimate AR1 Vertex-by-Vertex
            ResSeriesVertex=ResVal(i, :)';
            ResSeriesNeibor=ResVal(n_ind, :)';
            
            r=corr(ResSeriesVertex, ResSeriesNeibor);
            r(isnan(r))=[];
            VAR1(i, 1)=mean(r);
        end
        
    end
    
    if IsStatMap
        Scale=sqrt(GroupSurface/TotalArea);
        sigmasq=-1/(4*log(abs(SSminus/S2)));
        FWHM(n, 1)=Scale*sqrt(8*log(2)*sigmasq);
    else
        Scale=sqrt(GroupSurface/TotalArea);
        VAR1(isnan(VAR1))=0;
        FWHM(n ,1) =Scale.*mean(VD)*sqrt(-log(256)/(4*log(mean(VAR1(Msk)))));
    end
end

