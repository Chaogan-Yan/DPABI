function [ReHoBrain_AllWindow, GHeader] = y_reho_Surf_Window(WindowSize, WindowStep, WindowType,InFile, NNeighbor, AMaskFilename, AResultFilename, SurfFile, IsNeedDetrend, CUTNUMBER)
% Calculate dynamic regional homogeneity (i.e. ReHo) from the 2D surface brain
% FORMAT     [ReHoBrain_AllWindow, GHeader] = y_reho_Surf_Window(WindowSize, WindowStep, WindowType,InFile, NNeighbor, AMaskFilename, AResultFilename, SurfFile, CUTNUMBER)
% Input:
%   WindowSize      -   the size of the sliding window
%   WindowStep      -   the step size
%   WindowType      -   the type of window (e.g., hamming)
% 	InFile	        	The input surface time series file
%   NNeighbor           The number of vertex neighbor. Can be 1 or 2
% 	AMaskFilename		the mask file name, only compute the point within the mask
%	AResultFilename		the output filename
%   SurfFile        -   The surface file
%   IsNeedDetrend       0: Dot not detrend; 1: Use Matlab's detrend
%   CUTNUMBER       -   Cut the data into pieces if small RAM memory e.g. 4GB is available on PC. It can be set to 1 on server with big memory (e.g., 50GB).
%                       default: 10
% Output:
%	ReHoBrain_AllWindow       -   The ReHo results of the windows
%   GHeader         -   The GIfTI Header
%	AResultFilename	the filename of ReHo result
%-----------------------------------------------------------
% Inherited from y_reho_Window.m
% Revised by YAN Chao-Gan 190625.
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com

if ~exist('CUTNUMBER','var')
    CUTNUMBER = 10;
end

theElapsedTime =cputime;

% Examine the NNeighbor
% --------------------------------------------------------------------------
if NNeighbor ~= 1 & NNeighbor ~= 2
    error('The number of vertex neighbor should be 1 or 2. Please re-examine it.');
end

fprintf('\nComputing ReHo...\n');

GHeader=gifti(InFile);
AllVolume=GHeader.cdata;
[nDimVertex nDimTimePoints]=size(AllVolume);

% First dimension is time
AllVolume=AllVolume';

% Detrend
if exist('IsNeedDetrend','var') && IsNeedDetrend==1
    %AllVolume=detrend(AllVolume);
    fprintf('\n\t Detrending...');
    SegmentLength = ceil(size(AllVolume,2) / CUTNUMBER);
    for iCut=1:CUTNUMBER
        if iCut~=CUTNUMBER
            Segment = (iCut-1)*SegmentLength+1 : iCut*SegmentLength;
        else
            Segment = (iCut-1)*SegmentLength+1 : size(AllVolume,2);
        end
        AllVolume(:,Segment) = detrend(AllVolume(:,Segment));
        fprintf('.');
    end
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


nWindow = fix((nDimTimePoints - WindowSize)/WindowStep) + 1;

ReHoBrain_AllWindow = zeros([nDimVertex nWindow]);

if ischar(WindowType)
    eval(['WindowType = ',WindowType,'(WindowSize);'])
end
WindowMultiplier = repmat(WindowType(:),1,size(AllVolume,2));
for iWindow = 1:nWindow
    fprintf('\nProcessing window %g of total %g windows\n', iWindow, nWindow);
    
    AllVolumeWindow = AllVolume((iWindow-1)*WindowStep+1:(iWindow-1)*WindowStep+WindowSize,:);
    AllVolumeWindow = AllVolumeWindow.*WindowMultiplier;
    % Calcualte the rank
    fprintf('\n\t Rank calculating...\n');
    
    Ranks_AllVolume = repmat(zeros(1,size(AllVolumeWindow,2)), [size(AllVolumeWindow,1), 1]);
    
    SegmentLength = ceil(size(AllVolumeWindow,2) / CUTNUMBER);
    for iCut=1:CUTNUMBER
        if iCut~=CUTNUMBER
            Segment = (iCut-1)*SegmentLength+1 : iCut*SegmentLength;
        else
            Segment = (iCut-1)*SegmentLength+1 : size(AllVolumeWindow,2);
        end
        
        AllVolume_Piece = AllVolumeWindow(:,Segment);
        nVoxels_Piece = size(AllVolume_Piece,2);
        
        [AllVolume_Piece,SortIndex] = sort(AllVolume_Piece,1);
        db=diff(AllVolume_Piece,1,1);
        db = db == 0;
        sumdb=sum(db,1);
        
        SortedRanks = repmat([1:WindowSize]',[1,nVoxels_Piece]);
        % For those have the same values at the current time point and previous time point (ties)
        if any(sumdb(:))
            TieAdjustIndex=find(sumdb);
            for i=1:length(TieAdjustIndex)
                ranks=SortedRanks(:,TieAdjustIndex(i));
                ties=db(:,TieAdjustIndex(i));
                tieloc = [find(ties); WindowSize+2];
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
        SortIndexBase = repmat([0:nVoxels_Piece-1].*WindowSize,[WindowSize,1]);
        SortIndex=SortIndex+SortIndexBase;
        clear SortIndexBase;
        Ranks_Piece = zeros(WindowSize,nVoxels_Piece);
        Ranks_Piece(SortIndex)=SortedRanks;
        clear SortIndex SortedRanks;
        
        Ranks_AllVolume(:,Segment) = Ranks_Piece;
        fprintf('.');
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
    ReHoBrain_AllWindow(:,iWindow) = ReHoBrain;
end
y_Write(ReHoBrain_AllWindow,GHeader,AResultFilename);

theElapsedTime = cputime - theElapsedTime;
fprintf('\n\tRegional Homogeneity computation over, elapsed time: %g seconds\n', theElapsedTime);


% calculate kcc for a time series
%---------------------------------------------------------------------------
function B = f_kendall(A)
nk = size(A); n = nk(1); k = nk(2);
SR = sum(A,2); SRBAR = mean(SR);
S = sum(SR.^2) - n*SRBAR^2;
B = 12*S/k^2/(n^3-n);