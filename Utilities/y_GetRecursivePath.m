function PathList = y_GetRecursivePath(InPath,PathList)
% function OutPath = y_GetRecursivePath(InPath)
% Get Recursive Path List
% Input:
% 	InPath	 -   The input path
%   PathList         -   The previous Path List 
% Output:
% 	PathList       -   The output Path List which has added the files in InPath
%-----------------------------------------------------------
% Written by YAN Chao-Gan 150518.
% Institute of Psychology, Chinese Academy Sciences
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com

SubjStruct=dir(InPath);
Index=cellfun(...
    @(IsDir, NotDot) IsDir && (~strcmpi(NotDot, '.') && ~strcmpi(NotDot, '..') && ~strcmpi(NotDot, '.DS_Store')),...
    {SubjStruct.isdir}, {SubjStruct.name});
SubjStruct=SubjStruct(Index);
SubjName={SubjStruct.name}';
SubjPath=cellfun(@(Name) fullfile(InPath, Name), SubjName,...
    'UniformOutput', false);

if isempty(SubjPath)
    PathList = [PathList;{InPath}];
else
    for i=1:length(SubjPath)
        PathList = y_GetRecursivePath(SubjPath{i},PathList);
    end
end
