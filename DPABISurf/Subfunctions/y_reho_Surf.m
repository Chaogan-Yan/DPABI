function [ReHoBrain, GHeader] = y_reho_Surf(InFile, NNeighbor, AMaskFilename, AResultFilename, SurfFile, CUTNUMBER)
% Calculate regional homogeneity (i.e. ReHo) from the 2D surface brain
% FORMAT     [ReHoBrain, OutHeader] = y_reho_Surf(InFile, NNeighbor, AMaskFilename, AResultFilename, SurfFile, CUTNUMBER)
% Input:
% 	InFile	        	The input surface time series file
%   NNeighbor           The number of vertex neighbor. Can be 1 or 2
% 	AMaskFilename		the mask file name, only compute the point within the mask
%	AResultFilename		the output filename
%   SurfFile        -   The surface file
%   CUTNUMBER       -   Cut the data into pieces if small RAM memory e.g. 4GB is available on PC. It can be set to 1 on server with big memory (e.g., 50GB).
%                       default: 10
% Output:
%	ReHoBrain       -   The ReHo results
%   GHeader         -   The GIfTI Header
%	AResultFilename	the filename of ReHo result
%-----------------------------------------------------------
% Inherited from y_reho.m
% Revised by YAN Chao-Gan 181119.
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com

if ~exist('CUTNUMBER','var')
    CUTNUMBER = 10;
end

theElapsedTime =cputime;

% Examine the NNeighbor
% --------------------------------------------------------------------------
if NNeighbor ~= 1 & NNeighbor ~= 2
    error('The number of vertex neighbor should be 1 or 2. Please re-exmamin it.');
end

fprintf('\nComputing ReHo...\n');

GHeader=gifti(InFile);
AllVolume=GHeader.cdata;
[nDimVertex nDimTimePoints]=size(AllVolume);

fprintf('\nLoad mask "%s".\n', AMaskFilename);
if ~isempty(AMaskFilename)
    MaskData=gifti(AMaskFilename);
    MaskData=MaskData.cdata;
    if size(MaskData,1)~=nDimVertex
        error('The size of Mask (%d) doesn''t match the required size (%d).\n',size(MaskData,1), nDimVertex);
    end
    MaskData = double(logical(MaskData));
else
    MaskData=ones(nDimVertex,1);
end
MaskDataOneDim=reshape(MaskData,1,[]);


% First dimension is time
AllVolume=AllVolume';

% Calcualte the rank
fprintf('\n\t Rank calculating...\n');

Ranks_AllVolume = repmat(zeros(1,size(AllVolume,2)), [size(AllVolume,1), 1]);

SegmentLength = ceil(size(AllVolume,2) / CUTNUMBER);
for iCut=1:CUTNUMBER
    if iCut~=CUTNUMBER
        Segment = (iCut-1)*SegmentLength+1 : iCut*SegmentLength;
    else
        Segment = (iCut-1)*SegmentLength+1 : size(AllVolume,2);
    end
    
    AllVolume_Piece = AllVolume(:,Segment);
    nVoxels_Piece = size(AllVolume_Piece,2);
    
    [AllVolume_Piece,SortIndex] = sort(AllVolume_Piece,1);
    db=diff(AllVolume_Piece,1,1);
    db = db == 0;
    sumdb=sum(db,1);
    
    SortedRanks = repmat([1:nDimTimePoints]',[1,nVoxels_Piece]);
    % For those have the same values at the current time point and previous time point (ties)
    if any(sumdb(:))
        TieAdjustIndex=find(sumdb);
        for i=1:length(TieAdjustIndex)
            ranks=SortedRanks(:,TieAdjustIndex(i));
            ties=db(:,TieAdjustIndex(i));
            tieloc = [find(ties); nDimTimePoints+2];
            maxTies = numel(tieloc);
            tiecount = 1;
            while (tiecount < maxTies)
                tiestart = tieloc(tiecount);
                ntied = 2;
                while(tieloc(tiecount+1) == tieloc(tiecount)+1)
                    tiecount = tiecount+1;
                    ntied = ntied+1;
                end
                % Compute mean of tied ranks
                ranks(tiestart:tiestart+ntied-1) = ...
                    sum(ranks(tiestart:tiestart+ntied-1)) / ntied;
                tiecount = tiecount + 1;
            end
            SortedRanks(:,TieAdjustIndex(i))=ranks;
        end
    end
    clear db sumdb;
    SortIndexBase = repmat([0:nVoxels_Piece-1].*nDimTimePoints,[nDimTimePoints,1]);
    SortIndex=SortIndex+SortIndexBase;
    clear SortIndexBase;
    Ranks_Piece = zeros(nDimTimePoints,nVoxels_Piece);
    Ranks_Piece(SortIndex)=SortedRanks;
    clear SortIndex SortedRanks;
    
    Ranks_AllVolume(:,Segment) = Ranks_Piece;
    fprintf('.');
end


%Get the neighbors (algorithm written by Xi-Nian Zuo at IPCAS)
Surf = gifti(SurfFile);
edge = spm_mesh_adjacency(Surf); 
edge2 = edge^2; %length-two paths
edge12 = edge + edge2;
nbrs = cell(nDimVertex,1) ; nbrs2 = cell(nDimVertex,1);
for k=1:nDimVertex
    nbrs{k} = find(edge(k,:)>0);
    nbrs2{k} = find(edge12(k,:)>0);
end


% calulate the kcc for the data set
% ------------------------------------------------------------------------
fprintf('\n\t Calculate the kcc on vertex by vertex for the data set.\n');
ReHoBrain = zeros(nDimVertex,1); 
for i = 1:nDimVertex
    if MaskData(i)~=0
        if NNeighbor==1
            tmp_nbrs = [i, nbrs{i}]; %should include the vertex itself
        elseif  NNeighbor==2
            tmp_nbrs = nbrs2{i}; %nbrs2 include the vertex itself already
        end
        Ranks_nbrs = Ranks_AllVolume(:,tmp_nbrs);
        ReHoBrain(i) = f_kendall(Ranks_nbrs);
    end
end

y_Write(ReHoBrain,GHeader,AResultFilename);

theElapsedTime = cputime - theElapsedTime;
fprintf('\n\tRegional Homogeneity computation over, elapsed time: %g seconds\n', theElapsedTime);


% calculate kcc for a time series
%---------------------------------------------------------------------------
function B = f_kendall(A)
nk = size(A); n = nk(1); k = nk(2);
SR = sum(A,2); SRBAR = mean(SR);
S = sum(SR.^2) - n*SRBAR^2;
B = 12*S/k^2/(n^3-n);
