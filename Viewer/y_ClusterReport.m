function y_ClusterReport(data,head,ClusterConnectivityCriterion)
% Generate the report of the thresholded clusters.
% Based on CUI Xu's xjview. (http://www.alivelearn.net/xjview/)
% Revised by YAN Chao-Gan and ZHU Wei-Xuan 20091108: suitable for different Cluster Connectivity Criterion: surface connected, edge connected, corner connected.

if ~(exist('TDdatabase.mat'))
    uiwait(msgbox('This function is based on CUI Xu''s xjview, please install xjview8 or later version at first (http://www.alivelearn.net/xjview/).','REST Slice Viewer'));
    return
end

disp('This report is based on CUI Xu''s xjview. (http://www.alivelearn.net/xjview/)'); 
disp('Revised by YAN Chao-Gan and ZHU Wei-Xuan 20091108: suitable for different Cluster Connectivity Criterion: surface connected, edge connected, corner connected.');
nozeropos=find(data~=0);
[i j k]=ind2sub(size(data),nozeropos);
cor=[i j k];
mni=cor2mni(cor,head.mat);

if isempty(mni)
    %errordlg('No cluster is picked up.','oops');
    disp( 'No cluster is found. So no report will be generated.'); 
    return;
end

intensity=data(nozeropos);


L=cor';
dim = [max(L(1,:)) max(L(2,:)) max(L(3,:))];
vol = zeros(dim(1),dim(2),dim(3));
indx = sub2ind(dim,L(1,:)',L(2,:)',L(3,:)');
vol(indx) = 1;
[cci,num] = bwlabeln(vol,ClusterConnectivityCriterion);
A = cci(indx');

clusterID = unique(A);
numClusters = length(clusterID);
disp(['Number of clusters found: ' num2str(numClusters)]);

for mm = clusterID
    pos = find(A == clusterID(mm));
    numVoxels = length(pos);
    tmpmni = mni(pos,:);
    tmpintensity = intensity(pos);
    
    peakpos = find(abs(tmpintensity) == max(abs(tmpintensity)));
    peakcoord = tmpmni(peakpos,:);
    peakintensity = tmpintensity(peakpos);
    
        % list structure of voxels in this cluster
    x = load('TDdatabase.mat');
    [a, b] = cuixuFindStructure(tmpmni, x.DB);
    names = unique(b(:));
    index = NaN*zeros(length(b(:)),1);
    for ii=1:length(names)
        pos = find(strcmp(b(:),names{ii}));
        index(pos) = ii;
    end

    report = {};
    
    for ii=1:max(index)
        report{ii,1} = names{ii};
        report{ii,2} = length(find(index==ii));
    end
    for ii=1:size(report,1)
        for jj=ii+1:size(report,1)
            if report{ii,2} < report{jj,2}
                tmp = report(ii,:);
                report(ii,:) = report(jj,:);
                report(jj,:) = tmp;
            end
        end
    end
    report = [{'structure','# voxels'}; {'--TOTAL # VOXELS--', length(a)}; report];

    report2 = {sprintf('%s\t%s',report{1,2}, report{1,1}),''};
    for ii=2:size(report,1)
        if strcmp('undefined', report{ii,1}); continue; end
        report2 = [report2, {sprintf('%5d\t%s',report{ii,2}, report{ii,1})}];
    end

    disp(['----------------------'])
    disp(['Cluster ' num2str(mm)])
    disp(['Number of voxels: ' num2str(numVoxels)])
    
    if size(peakcoord,1)<=1; %YAN Chao-Gan, 100814. If multi-voxels have the same peak value, then skip display the peak information.
        disp(['Peak MNI coordinate: ' num2str(peakcoord)])
        [a,b] = cuixuFindStructure(peakcoord, x.DB);
        disp(['Peak MNI coordinate region: ' a{1}]);
        disp(['Peak intensity: ' num2str(peakintensity)])
    end
    
    for kk=1:length(report2)
        disp(report2{kk});
    end
end
return

function mni = cor2mni(cor, T)
% function mni = cor2mni(cor, T)
% convert matrix coordinate to mni coordinate
%
% cor: an Nx3 matrix
% T: (optional) rotation matrix
% mni is the returned coordinate in mni space
%
% caution: if T is not given, the default T is
% T = ...
%     [-4     0     0    84;...
%      0     4     0  -116;...
%      0     0     4   -56;...
%      0     0     0     1];
%
% xu cui
% 2004-8-18
% last revised: 2005-04-30

if nargin == 1
    T = ...
        [-4     0     0    84;...
         0     4     0  -116;...
         0     0     4   -56;...
         0     0     0     1];
end

cor = round(cor);
mni = T*[cor(:,1) cor(:,2) cor(:,3) ones(size(cor,1),1)]';
mni = mni';
mni(:,4) = [];
return;

function coordinate = mni2cor(mni, T)
% function coordinate = mni2cor(mni, T)
% convert mni coordinate to matrix coordinate
%
% mni: a Nx3 matrix of mni coordinate
% T: (optional) transform matrix
% coordinate is the returned coordinate in matrix
%
% caution: if T is not specified, we use:
% T = ...
%     [-4     0     0    84;...
%      0     4     0  -116;...
%      0     0     4   -56;...
%      0     0     0     1];
%
% xu cui
% 2004-8-18
%

if isempty(mni)
    coordinate = [];
    return;
end

if nargin == 1
	T = ...
        [-4     0     0    84;...
         0     4     0  -116;...
         0     0     4   -56;...
         0     0     0     1];
end

coordinate = [mni(:,1) mni(:,2) mni(:,3) ones(size(mni,1),1)]*(inv(T))';
coordinate(:,4) = [];
coordinate = round(coordinate);
return;

function [onelinestructure, cellarraystructure] = cuixuFindStructure(mni, DB)
% function [onelinestructure, cellarraystructure] = cuixuFindStructure(mni, DB)
%
% this function converts MNI coordinate to a description of brain structure
% in aal
%
%   mni: the coordinates (MNI) of some points, in mm.  It is Nx3 matrix
%   where each row is the coordinate for one point
%   LDB: the database.  This variable is available if you load
%   TDdatabase.mat
%
%   onelinestructure: description of the position, one line for each point
%   cellarraystructure: description of the position, a cell array for each point
%
%   Example:
%   cuixuFindStructure([72 -34 -2; 50 22 0], DB)
%
% Xu Cui
% 2007-11-20
%

N = size(mni, 1);

% round the coordinates
mni = round(mni/2) * 2;

T = [...
     2     0     0   -92
     0     2     0  -128
     0     0     2   -74
     0     0     0     1];

index = mni2cor(mni, T);

cellarraystructure = cell(N, length(DB));
onelinestructure = cell(N, 1);

for ii=1:N
    for jj=1:length(DB)
        graylevel = DB{jj}.mnilist(index(ii, 1), index(ii, 2),index(ii, 3));
        if graylevel == 0
            thelabel = 'undefined';
        else
            if jj==length(DB); tmp = ' (aal)'; else tmp = ''; end
            thelabel = [DB{jj}.anatomy{graylevel} tmp];
        end
        cellarraystructure{ii, jj} = thelabel;
        onelinestructure{ii} = [ onelinestructure{ii} ' // ' thelabel ];
    end
end