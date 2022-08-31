function [Error, Cfg]=DPABINet_GTA_run(Cfg,DataDir,OutDir,SubjectListFile)
% FORMAT [Error]=DPABIGraph_GTA_run(Cfg,WorkingDir,SubjectListFile)
%   Cfg - the parameters for graph theoretical analysis.
%   WorkingDir - Define the working directory to replace the one defined in Cfg
%   SubjectListFile - Define the subject list to replace the one defined in Cfg. Should be a text file
% Output:
%   The processed data that you want.
%___________________________________________________________________________
% Written by YAN Chao-Gan 201205.
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
if ~isfield(Cfg,'ParallelWorkersNumber')
    Cfg.ParallelWorkersNumber=1;
end
if ~isfield(Cfg,'IsCalGTA')
    Cfg.IsCalGTA=0;
end
if ~isfield(Cfg,'FilePrefix')
    Cfg.FilePrefix='';
end
if ~isfield(Cfg,'FileSuffix')
    Cfg.FileSuffix='.mat';
end
if ~isfield(Cfg,'SparsityRange')
    Cfg.SparsityRange=[0.01:0.01:0.5]';
end
if ~isfield(Cfg,'SparsityRange_ForAUC')
    Cfg.SparsityRange_ForAUC=[0.01:0.01:0.5]';
end
if ~isfield(Cfg,'NetworkWeighting')
    Cfg.NetworkWeighting='Weighted'; % Or 'Binarized'
end
if ~isfield(Cfg,'RandomTimes')
    Cfg.RandomTimes=100;
end



% The parpool might be shut down, restart it.
PCTVer = ver('distcomp');
if ~isempty(PCTVer)
    FullMatlabVersion = sscanf(version,'%d.%d.%d.%d%s');
    if FullMatlabVersion(1)*1000+FullMatlabVersion(2)<8*1000+3    %YAN Chao-Gan, 151117. If it's lower than MATLAB 2014a.  %FullMatlabVersion(1)*1000+FullMatlabVersion(2)>=7*1000+8    %YAN Chao-Gan, 120903. If it's higher than MATLAB 2008.
        CurrentSize_MatlabPool = matlabpool('size');
        if (CurrentSize_MatlabPool==0) && (Cfg.ParallelWorkersNumber~=0)
            matlabpool(Cfg.ParallelWorkersNumber)
        end
    else
        if isempty(gcp('nocreate')) && Cfg.ParallelWorkersNumber~=0
            parpool(Cfg.ParallelWorkersNumber);
        end
    end
end


%Calculate graph theoretical analysis properties
if (Cfg.IsCalGTA==1)


        for i=1:Cfg.SubjectNum
            
            NetworkMatrixFile=[Cfg.DataDir,filesep,Cfg.FilePrefix,Cfg.SubjectID{i},Cfg.FileSuffix];
            NetworkMatrix=load(NetworkMatrixFile);
            Matrix=NetworkMatrix.NetworkMatrix;
         
            if ~isempty(find(isnan(Matrix)))
                error('\nThere is NaN in the matrix for Subject %s.\n',Cfg.SubjectID{i});
            end
            
            NodeNumber = size(Matrix,1);
            MaxSparsity = length(find(Matrix>0)) / (NodeNumber*(NodeNumber-1));
            
            SparsityRange=Cfg.SparsityRange;
            
            nSparsity = length(SparsityRange);
            
            CpSet = zeros(1,nSparsity);
            LpSet = zeros(1,nSparsity);
            GammaSet = zeros(1,nSparsity);
            LambdaSet = zeros(1,nSparsity);
            SigmaSet = zeros(1,nSparsity);
            ElocSet = zeros(1,nSparsity);
            EglobSet = zeros(1,nSparsity);
            AssortativitySet = zeros(1,nSparsity);
            ModularitySet = zeros(1,nSparsity);
            
            DegreeSet = zeros(1,nSparsity,NodeNumber);
            NodalEfficiencySet = zeros(1,nSparsity,NodeNumber);
            BetweennessSet = zeros(1,nSparsity,NodeNumber);
            ClusteringCoefficientSet = zeros(1,nSparsity,NodeNumber);
            ParticipantCoefficientSet = zeros(1,nSparsity,NodeNumber);
            SubgraphCentralitySet = zeros(1,nSparsity,NodeNumber);
            EigenvectorCentralitySet = zeros(1,nSparsity,NodeNumber);
            PageRankCentralitySet = zeros(1,nSparsity,NodeNumber);

            fprintf('\nGraph theoretical analysis for Subject %s.\n',Cfg.SubjectID{i});
            parfor iSparsity=1:length(SparsityRange)
                fprintf('Sparsity: %d ',SparsityRange(iSparsity));
                if (SparsityRange(iSparsity)<=MaxSparsity) % If not reached the maximum sparsity
                    EdgeNumber=round(SparsityRange(iSparsity)*NodeNumber*(NodeNumber-1));
                    MatrixValue=Matrix(:);
                    MatrixValueSorted=sort(MatrixValue,'descend');
                    MatrixValueThreshold=max(MatrixValueSorted(EdgeNumber+1),0); % Keep all values in the connection matrix to be positive, in case of negative distance and mistakes in graph theoratical matrics. Bin
                    MatrixThresholded_bu=Matrix>MatrixValueThreshold;
                    MatrixThresholded_wu=Matrix.*(Matrix>MatrixValueThreshold);
                    
                    if strcmpi(Cfg.NetworkWeighting,'Weighted')
                        [GTA] = y_GraphTheoreticalAnalysis_wu(MatrixThresholded_wu,Cfg.RandomTimes);
                    elseif strcmpi(Cfg.NetworkWeighting,'Binarized')
                        [GTA] = y_GraphTheoreticalAnalysis_bu(MatrixThresholded_bu,Cfg.RandomTimes);
                    end

                    CpSet(1,iSparsity) = GTA.Cp;
                    LpSet(1,iSparsity) = GTA.Lp;
                    GammaSet(1,iSparsity) = GTA.Gamma;
                    LambdaSet(1,iSparsity) = GTA.Lambda;
                    SigmaSet(1,iSparsity) = GTA.Sigma;
                    ElocSet(1,iSparsity) = GTA.Eloc;
                    EglobSet(1,iSparsity) = GTA.Eglob;
                    AssortativitySet(1,iSparsity) = GTA.Assortativity;
                    ModularitySet(1,iSparsity) = GTA.Modularity;
                    
                    DegreeSet(1,iSparsity,:) = GTA.Degree;
                    NodalEfficiencySet(1,iSparsity,:) = GTA.NodalEfficiency;
                    BetweennessSet(1,iSparsity,:) = GTA.Betweenness;
                    ClusteringCoefficientSet(1,iSparsity,:) = GTA.ClusteringCoefficient;
                    ParticipantCoefficientSet(1,iSparsity,:) = GTA.ParticipantCoefficient;
                    SubgraphCentralitySet(1,iSparsity,:) = GTA.SubgraphCentrality;
                    EigenvectorCentralitySet(1,iSparsity,:) = GTA.EigenvectorCentrality;
                    PageRankCentralitySet(1,iSparsity,:) = GTA.PageRankCentrality;

                end
            end

            %Calculate AUC
            %'Cp_AUC','Lp_AUC','Gamma_AUC','Lambda_AUC','Sigma_AUC','Eloc_AUC','Eglob_AUC','Assortativity_AUC','Modularity_AUC','Degree_AUC','NodalEfficiency_AUC','Betweenness_AUC','ClusteringCoefficient_AUC','ParticipantCoefficient_AUC','SubgraphCentrality_AUC','EigenvectorCentrality_AUC','PageRankCentrality_AUC'
            
            SparsityRange_ForAUC100000=round(100000*Cfg.SparsityRange_ForAUC);
            SparsityRange100000=round(100000*SparsityRange);
            [~, AUCRange] = ismember(SparsityRange_ForAUC100000, SparsityRange100000);
            %[~, AUCRange] = ismember(Cfg.SparsityRange_ForAUC, SparsityRange);
            DeltaSparsity=mean(diff(SparsityRange));
            
            Cp_AUC=(sum(CpSet(1,AUCRange),2) - sum(CpSet(1,AUCRange([1 end])),2)/2)*DeltaSparsity;
            Lp_AUC=(sum(LpSet(1,AUCRange),2) - sum(LpSet(1,AUCRange([1 end])),2)/2)*DeltaSparsity;
            Gamma_AUC=(sum(GammaSet(1,AUCRange),2) - sum(GammaSet(1,AUCRange([1 end])),2)/2)*DeltaSparsity;
            Lambda_AUC=(sum(LambdaSet(1,AUCRange),2) - sum(LambdaSet(1,AUCRange([1 end])),2)/2)*DeltaSparsity;
            Sigma_AUC=(sum(SigmaSet(1,AUCRange),2) - sum(SigmaSet(1,AUCRange([1 end])),2)/2)*DeltaSparsity;
            Eloc_AUC=(sum(ElocSet(1,AUCRange),2) - sum(ElocSet(1,AUCRange([1 end])),2)/2)*DeltaSparsity;
            Eglob_AUC=(sum(EglobSet(1,AUCRange),2) - sum(EglobSet(1,AUCRange([1 end])),2)/2)*DeltaSparsity;
            Assortativity_AUC=(sum(AssortativitySet(1,AUCRange),2) - sum(AssortativitySet(1,AUCRange([1 end])),2)/2)*DeltaSparsity;
            Modularity_AUC=(sum(ModularitySet(1,AUCRange),2) - sum(ModularitySet(1,AUCRange([1 end])),2)/2)*DeltaSparsity;

            Degree_AUC = zeros(1,NodeNumber);
            NodalEfficiency_AUC = zeros(1,NodeNumber);
            Betweenness_AUC = zeros(1,NodeNumber);
            ClusteringCoefficient_AUC = zeros(1,NodeNumber);
            ParticipantCoefficient_AUC = zeros(1,NodeNumber);
            SubgraphCentrality_AUC = zeros(1,NodeNumber);
            EigenvectorCentrality_AUC = zeros(1,NodeNumber);
            PageRankCentrality_AUC = zeros(1,NodeNumber);
            for iNode = 1:size(DegreeSet,3)
                Degree_AUC(:,iNode)=(sum(DegreeSet(1,AUCRange,iNode),2) - sum(DegreeSet(1,AUCRange([1 end]),iNode),2)/2)*DeltaSparsity;
                NodalEfficiency_AUC(:,iNode)=(sum(NodalEfficiencySet(1,AUCRange,iNode),2) - sum(NodalEfficiencySet(1,AUCRange([1 end]),iNode),2)/2)*DeltaSparsity;
                Betweenness_AUC(:,iNode)=(sum(BetweennessSet(1,AUCRange,iNode),2) - sum(BetweennessSet(1,AUCRange([1 end]),iNode),2)/2)*DeltaSparsity;
                ClusteringCoefficient_AUC=(sum(ClusteringCoefficientSet(1,AUCRange,iNode),2) - sum(ClusteringCoefficientSet(1,AUCRange([1 end]),iNode),2)/2)*DeltaSparsity;
                ParticipantCoefficient_AUC(:,iNode)=(sum(ParticipantCoefficientSet(1,AUCRange,iNode),2) - sum(ParticipantCoefficientSet(1,AUCRange([1 end]),iNode),2)/2)*DeltaSparsity;
                SubgraphCentrality_AUC(:,iNode)=(sum(SubgraphCentralitySet(1,AUCRange,iNode),2) - sum(SubgraphCentralitySet(1,AUCRange([1 end]),iNode),2)/2)*DeltaSparsity;
                EigenvectorCentrality_AUC(:,iNode)=(sum(EigenvectorCentralitySet(1,AUCRange,iNode),2) - sum(EigenvectorCentralitySet(1,AUCRange([1 end]),iNode),2)/2)*DeltaSparsity;
                PageRankCentrality_AUC(:,iNode)=(sum(PageRankCentralitySet(1,AUCRange,iNode),2) - sum(PageRankCentralitySet(1,AUCRange([1 end]),iNode),2)/2)*DeltaSparsity;
            end
            
            OutFile=[Cfg.OutDir,filesep,'GTA_',Cfg.SubjectID{i},'.mat'];
            save(OutFile,'CpSet','LpSet','GammaSet','LambdaSet','SigmaSet','ElocSet','EglobSet','AssortativitySet','ModularitySet','DegreeSet','NodalEfficiencySet','BetweennessSet','ClusteringCoefficientSet','ParticipantCoefficientSet','SubgraphCentralitySet','EigenvectorCentralitySet','PageRankCentralitySet','MaxSparsity','SparsityRange','Cp_AUC','Lp_AUC','Gamma_AUC','Lambda_AUC','Sigma_AUC','Eloc_AUC','Eglob_AUC','Assortativity_AUC','Modularity_AUC','Degree_AUC','NodalEfficiency_AUC','Betweenness_AUC','ClusteringCoefficient_AUC','ParticipantCoefficient_AUC','SubgraphCentrality_AUC','EigenvectorCentrality_AUC','PageRankCentrality_AUC','DeltaSparsity');
        end
    end

        
        
fprintf(['\nCongratulations, the running of DPABINet_GTA (graph theoretical analysis) is done!!! :)\n\n']);
        
