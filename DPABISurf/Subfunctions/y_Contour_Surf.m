function [Contour, GHeader] = y_Contour_Surf(LabelFile, SurfFile, AResultFilename)
% Calculate Contour from the 2D surface brain
% FORMAT     [Contour, GHeader] = y_Contour_Surf(LabelFile, SurfFile, AResultFilename)
% Input:
% 	LabelFile	        The input Label file
%   SurfFile        -   The surface file
%	AResultFilename		the output filename
% Output:
%	Contour         -   The Contour
%   GHeader         -   The GIfTI Header
%	AResultFilename	the filename of Contour result
%-----------------------------------------------------------
% Written by YAN Chao-Gan 181129. Based on algorithm written by Xi-Nian Zuo at IPCAS
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com

theElapsedTime =cputime;
fprintf('\nComputing Contour...\n');

GHeader=gifti(LabelFile);
LabelData=GHeader.cdata;
[nDimVertex nDimTimePoints]=size(LabelData);

%Get the neighbors (algorithm written by Xi-Nian Zuo at IPCAS)
Surf = gifti(SurfFile);
edge = spm_mesh_adjacency(Surf); 
nbrs = cell(nDimVertex,1) ;
for k=1:nDimVertex
    nbrs{k} = find(edge(k,:)>0);
end

Contour=zeros(size(LabelData));
for vid=1:nDimVertex
    tmpneighbours = LabelData(nbrs{vid});
    [ModeNumber Modefrequency] = mode(tmpneighbours);
    Modefrequency = Modefrequency/length(tmpneighbours);
    if Modefrequency > 0.33 && Modefrequency < 0.67  %YAN Chao-Gan, 20181129. Narrow the boarder. %if numel(unique(tmpneighbours))>=2
        Contour(vid) = 1;
    end
end

y_Write(Contour,GHeader,AResultFilename);

theElapsedTime = cputime - theElapsedTime;
fprintf('\n\tContour computation over, elapsed time: %g seconds\n', theElapsedTime);

