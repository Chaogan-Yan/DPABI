function [Error, Cfg]=y_NetworkConstruction(Cfg,DataDir,OutDir,SubjectListFile)
% FORMAT [Error, Cfg]=y_NetworkConstruction(Cfg,DataDir,OutDir,SubjectListFile)
%   Cfg - the parameters for Network Construction.
%   DataDir - Define the Data directory to replace the one defined in Cfg
%   OutDir - Define the Output directory to replace the one defined in Cfg
%   SubjectListFile - Define the subject list to replace the one defined in Cfg. Should be a text file
% Output:
%   The processed data that you want.
%___________________________________________________________________________
% Written by YAN Chao-Gan 201220.
% CAS Key Laboratory of Behavioral Science, Institute of Psychology, Beijing, China;
% International Big-Data Research Center for Depression (IBRCD), Institute of Psychology, Chinese Academy of Sciences, Beijing, China;
% Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China.
% ycg.yan@gmail.com


if ischar(Cfg)  %If inputed a .mat file name. (Cfg inside)
    load(Cfg);
end

if exist('DataDir','var') && ~isempty(DataDir)
    Cfg.DataDir=DataDir;
end

if exist('OutDir','var') && ~isempty(OutDir)
    Cfg.OutDir=OutDir;
end

if exist('SubjectListFile','var') && ~isempty(SubjectListFile)
    fid = fopen(SubjectListFile);
    IDCell = textscan(fid,'%s\n'); %YAN Chao-Gan. For compatiblity of MALLAB 2014b. IDCell = textscan(fid,'%s','\n');
    fclose(fid);
    Cfg.SubjectID=IDCell{1};
end


Cfg.SubjectNum=length(Cfg.SubjectID);
Error=[];

[DPABIPath, fileN, extn] = fileparts(which('DPABI.m'));


%Make compatible with missing parameters.

if ~isfield(Cfg,'IsNetworkConstruction')
    Cfg.IsNetworkConstruction=0;
end
if ~isfield(Cfg,'FilePrefix')
    Cfg.FilePrefix='';
end
if ~isfield(Cfg,'FileSuffix')
    Cfg.FileSuffix='.mat';
end
if ~isfield(Cfg,'ROIIndices')
    Cfg.ROIIndices=[];
end

if ~isfield(Cfg.NetworkConstruction,'Method')
    Cfg.NetworkConstruction.Method='corr'; % Can be:
    % 'cov' - covariance (non-normalised "correlation")
    % 'amp' - only use nodes' amplitudes - the individual original "netmats" are then (Nnodes X 1) and not a aquare matrix
    % 'corr' - full correlation (diagonal is set to zero)
    % 'rcorr' - full correlation after regressing out global mean timecourse
    % 'icov' - partial correlation, optionally "ICOV" L1-regularised (if a lambda parameter is given as the next option)
    %     e.g.:  if Cfg.NetworkConstruction.MethodParameter=''; -- (unregularised) partial correlation
    %     e.g.:  if Cfg.NetworkConstruction.MethodParameter=10; --  "ICOV" L1-norm regularised partial correlation with lambda=10
    %     L1-regularisation requires the L1precision toolbox from http://www.di.ens.fr/~mschmidt/Software/L1precision.html
    % 'ridgep' - partial correlation using L2-norm Ridge Regression (aka Tikhonov)
    %     e.g.:  if Cfg.NetworkConstruction.MethodParameter=''; --  default regularisation rho=0.1
    %     e.g.:  if Cfg.NetworkConstruction.MethodParameter=1;  % rho=1
    % 'pwling'
    % 'multiggm'
end
if ~isfield(Cfg.NetworkConstruction,'MethodParameter')
    Cfg.NetworkConstruction.MethodParameter='';
end
if ~isfield(Cfg.NetworkConstruction,'IsRtoZ')
    Cfg.NetworkConstruction.IsRtoZ=0;
end
if ~isfield(Cfg.NetworkConstruction,'IsApplyRtoZScalingFactor')
    Cfg.NetworkConstruction.IsApplyRtoZScalingFactor=0;
end

if ~isfield(Cfg,'IsHigherOrderAveraging')
    Cfg.IsHigherOrderAveraging=0;
end
if ~isfield(Cfg,'HigherOrderAveraginMergeLabel')
    Cfg.HigherOrderAveraginMergeLabel='';
end



if (Cfg.IsHigherOrderAveraging==1)
    if ischar(Cfg.HigherOrderAveraginMergeLabel)
        HigherOrderAveraginMergeLabel = load(Cfg.HigherOrderAveraginMergeLabel);
        if isstruct(HigherOrderAveraginMergeLabel)
            MatrixNames = fieldnames(HigherOrderAveraginMergeLabel);
            eval(['HigherOrderAveraginMergeLabel=HigherOrderAveraginMergeLabel.',MatrixNames{1},';']);
        end
    else
        HigherOrderAveraginMergeLabel = Cfg.HigherOrderAveraginMergeLabel;
    end
    HigherOrderAveraginMergeLabel=HigherOrderAveraginMergeLabel(:);
end

if (Cfg.NetworkConstruction.IsRtoZ==1) && (Cfg.NetworkConstruction.IsApplyRtoZScalingFactor==1)
    FSLNetMatsRtoZ = 1;
    FisherRtoZ = 0;
elseif (Cfg.NetworkConstruction.IsRtoZ==1) && (Cfg.NetworkConstruction.IsApplyRtoZScalingFactor==0)
    FSLNetMatsRtoZ = 0;
    FisherRtoZ = 1;
else
    FSLNetMatsRtoZ = 0;
    FisherRtoZ = 0;
end

%Calculate graph theoretical analysis properties
if (Cfg.IsNetworkConstruction==1)
    
    for i=1:Cfg.SubjectNum
        
        ROISignalsFile=[Cfg.DataDir,filesep,Cfg.FilePrefix,Cfg.SubjectID{i},Cfg.FileSuffix];
        
        ROISignals=load(ROISignalsFile);
        
        if isfield(ROISignals,'ROISignals')
            if ~isempty(Cfg.ROIIndices)
                Sig=ROISignals.ROISignals(:,Cfg.ROIIndices);
            else
                Sig=ROISignals.ROISignals;
            end
        else
            if ~isempty(Cfg.ROIIndices)
                Sig=ROISignals.Data(:,Cfg.ROIIndices);
            else
                Sig=ROISignals.Data;
            end
        end
        
        %netmats = nets_netmats(ts,z,method,method_parameter);
        if isfield(Cfg.NetworkConstruction,'MethodParameter') && ~isempty(Cfg.NetworkConstruction.MethodParameter)
            NetworkMatrix = nets_netmats(Sig,FSLNetMatsRtoZ,Cfg.NetworkConstruction.Method,Cfg.NetworkConstruction.MethodParameter);
        else
            NetworkMatrix = nets_netmats(Sig,FSLNetMatsRtoZ,Cfg.NetworkConstruction.Method);
        end
        
        if FisherRtoZ==1
            NetworkMatrix = 0.5 * log((1 + NetworkMatrix)./(1 - NetworkMatrix));
        end
        
        
        if (Cfg.IsHigherOrderAveraging==1)
            
            MergeLabel = HigherOrderAveraginMergeLabel;
            LabelIndex = unique(MergeLabel);
            NetworkMatrixHigherOrder = zeros(length(LabelIndex),length(LabelIndex));
            
            FullMatrix=ones(size(NetworkMatrix,1),size(NetworkMatrix,2))-eye(size(NetworkMatrix,1),size(NetworkMatrix,2));
            
            CountSet_Full = zeros(length(LabelIndex),length(LabelIndex));
            for j=1:length(LabelIndex)
                for k=1:length(LabelIndex)
                    A=double(MergeLabel==LabelIndex(j));
                    B=double(MergeLabel==LabelIndex(k));
                    Matrix = A*B';
                    MatrixIndex = find(Matrix);
                    NetworkMatrixHigherOrder(j,k) = sum(NetworkMatrix(MatrixIndex));
                    CountSet_Full(j,k) = sum(FullMatrix(MatrixIndex));
                end
            end
            NetworkMatrixHigherOrder=NetworkMatrixHigherOrder./CountSet_Full;
            NetworkMatrix=NetworkMatrixHigherOrder;
        end
        
        
        OutFile=[Cfg.OutDir,filesep,'NetworkMatrix_',Cfg.SubjectID{i},'.mat'];
        save(OutFile,'NetworkMatrix');
        
    end
end


fprintf(['\nCongratulations, the running of Network Construction is done!!! :)\n\n']);

