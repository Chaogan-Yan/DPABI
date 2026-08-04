function [Cfg, JobList] = y_MultiEchoICA_Tedana(Cfg,WorkingDir,SubjectListFile)
% function [Cfg, JobList] = y_MultiEchoICA_Tedana(Cfg,WorkingDir,SubjectListFile)
% Run tedana on fMRIPrep multi-echo outputs and organize denoised files for DPABI.
%
% This function is designed as the multi-echo counterpart of y_Organize_fmriprep:
%   1) Read a DPABI-style Cfg structure (or a MAT file containing Cfg)
%   2) Find fMRIPrep multi-echo outputs produced with --me-output-echos
%      in sub-*/func or sub-*/ses-*/func
%   3) Run tedana on the echo-wise native/boldref-space files
%      (*_echo-*_desc-preproc_bold.nii.gz)
%   4) Warp tedana denoised data to T1w space with the matching
%      from-boldref_to-T1w transform, then copy to FunVolu
%   5) Warp the same tedana denoised data to standard space with the
%      boldref-to-T1w plus T1w-to-template transforms, then copy to FunVoluW
%   6) Organize masks into Masks/AutoMasks or Masks/S*_AutoMasks
%   7) When parallel execution is requested, use GNU parallel inside the
%      DPABI Docker image instead of MATLAB parfor
%
% Input:
%   Cfg             - parameters for automatic processing
%   WorkingDir      - optional override for Cfg.WorkingDir
%   SubjectListFile - optional text file or single subject ID override
%
% Output:
%   Cfg     - updated Cfg
%   JobList - structure array describing tedana jobs and execution status
%
% Notes:
%   - fMRIPrep must have been run with --me-output-echos.
%   - fMRIPrep echo-wise outputs are normally written in the func directory
%     without a space-* entity. This function therefore runs tedana in that
%     native/boldref space and uses fMRIPrep transforms afterwards.
%   - This function organizes tedana-denoised functional volume results and,
%     when surface templates are available, regenerates denoised fsnative and
%     fsaverage5 functional surface .gii files.
%   - Safe parallel mode limits memory-heavy stages by default. After the
%     initial pass, failed/incomplete run-session jobs are verified and
%     retried once. A later call with the same Cfg resumes only incomplete
%     stages while verified outputs are skipped.
%   - Newly generated 4D warp outputs are written atomically. Legacy
%     truncated .nii.gz files are detected, moved into
%     tedana/Backup/IncompleteOutputs, and regenerated.
%   - The denoised outputs are organized so that downstream DPABISurf/DPABI volume
%     processing can continue from FunVolu/FunVoluW without selecting an echo-specific
%     file by mistake.
%___________________________________________________________________________
% Written by OpenAI Codex, 260419.
% Based on the workflow conventions in y_Organize_fmriprep.m and tedana usage.


if ischar(Cfg)  % If inputed a .mat file name. (Cfg inside)
    load(Cfg);
end

if exist('WorkingDir','var') && ~isempty(WorkingDir)
    Cfg.WorkingDir=WorkingDir;
end

if exist('SubjectListFile','var') && ~isempty(SubjectListFile)
    if exist(SubjectListFile, 'file') == 2
        fid = fopen(SubjectListFile);
        IDCell = textscan(fid,'%s\n');
        fclose(fid);
        Cfg.SubjectID=IDCell{1};
    else
        Cfg.SubjectID={SubjectListFile};
    end
end

Cfg = local_fill_defaults(Cfg);

if ~exist(Cfg.WorkingDir,'dir')
    error('Cfg.WorkingDir does not exist: %s', Cfg.WorkingDir);
end
if ~exist(Cfg.FMRIPrepDir,'dir')
    error(['Cfg.FMRIPrepDir does not exist: %s\n' ...
        'Please make sure fMRIPrep outputs are available before running tedana.'], Cfg.FMRIPrepDir);
end

Cfg.SubjectID = local_normalize_subject_ids(Cfg.SubjectID);
Cfg.SubjectNum=length(Cfg.SubjectID);

if Cfg.FunctionalSessionNumber==0
    warning('Cfg.FunctionalSessionNumber is 0. Nothing to process.');
    JobList = struct([]);
    return;
end

if ~exist(Cfg.TedanaDir,'dir')
    mkdir(Cfg.TedanaDir);
end

[FunSessionPrefixSet, fmriprepfuncSessionPrefixSet] = local_build_session_prefixes(Cfg);
[CommandInit, WorkingDirInContainer] = local_prepare_command_init(Cfg);

if strcmpi(Cfg.MultiEcho.TEUnit, 'auto')
    Cfg.MultiEcho.TEUnit = local_detect_tedana_te_unit(CommandInit);
    fprintf('Detected tedana TE unit mode: %s\n', Cfg.MultiEcho.TEUnit);
end

JobList = local_collect_jobs(Cfg, FunSessionPrefixSet, fmriprepfuncSessionPrefixSet, CommandInit, WorkingDirInContainer);

if isempty(JobList)
    error(['No valid tedana jobs were created.\n' ...
        'Please ensure fMRIPrep was run with --me-output-echos and that echo-wise\n' ...
        'files such as *_echo-1_desc-preproc_bold.nii.gz are present in %s.'], Cfg.FMRIPrepDir);
end

[Cfg, JobList] = local_prepare_tedana_memory_plan(JobList, Cfg);

fprintf('\nTotal tedana jobs found: %d\n', numel(JobList));
for iJob = 1:numel(JobList)
    fprintf('%3d) %s\n', iJob, JobList(iJob).BasePrefix);
end

if Cfg.MultiEcho.DryRun
    save(fullfile(Cfg.TedanaDir,'tedana_joblist.mat'),'JobList');
    fprintf('\nDryRun = 1, commands were generated but not executed.\n');
    return;
end

local_ensure_surface_subjects(JobList, Cfg, CommandInit, WorkingDirInContainer);

% Main execution always uses GNU parallel inside docker.
% When ParallelWorkersNumber == 1, this becomes `parallel -j 1`.
JobList = local_execute_jobs_with_parallel(JobList, Cfg, CommandInit, WorkingDirInContainer);

save(fullfile(Cfg.TedanaDir,'tedana_joblist.mat'),'JobList');
local_write_failed_jobs_report(JobList, Cfg);
fprintf('\nMulti-echo ICA with tedana finished!\n');

end


function Cfg = local_fill_defaults(Cfg)
if ~isfield(Cfg,'WorkingDir') || isempty(Cfg.WorkingDir)
    error('Cfg.WorkingDir is required.');
end
if ~isfield(Cfg,'FMRIPrepDir') || isempty(Cfg.FMRIPrepDir)
    Cfg.FMRIPrepDir = fullfile(Cfg.WorkingDir, 'fmriprep');
end
if ~isfield(Cfg,'TedanaDir') || isempty(Cfg.TedanaDir)
    if isfield(Cfg,'OutputDir') && ~isempty(Cfg.OutputDir)
        Cfg.TedanaDir = Cfg.OutputDir;
    else
        Cfg.TedanaDir = fullfile(Cfg.WorkingDir, 'tedana');
    end
end
if ~isfield(Cfg,'SurfaceSubjectsDir') || isempty(Cfg.SurfaceSubjectsDir)
    Cfg.SurfaceSubjectsDir = local_detect_surface_subjects_dir(Cfg);
end
if ~isfield(Cfg,'MultiEcho') || ~isstruct(Cfg.MultiEcho)
    Cfg.MultiEcho = struct();
end
if ~isfield(Cfg,'SubjectID') || isempty(Cfg.SubjectID)
    Cfg.SubjectID = local_get_subject_ids(Cfg.FMRIPrepDir);
end
if ~iscell(Cfg.SubjectID)
    Cfg.SubjectID = {Cfg.SubjectID};
end
if ~isfield(Cfg,'FunctionalSessionNumber') || isempty(Cfg.FunctionalSessionNumber)
    Cfg.FunctionalSessionNumber = 1;
end
if ~isfield(Cfg,'ParallelWorkersNumber') || isempty(Cfg.ParallelWorkersNumber)
    Cfg.ParallelWorkersNumber = 1;
end
if ~isfield(Cfg,'TedanaParallelWorkersNumber') || isempty(Cfg.TedanaParallelWorkersNumber)
    Cfg.TedanaParallelWorkersNumber = Cfg.ParallelWorkersNumber;
end
if ~isfield(Cfg,'T1wWarpParallelWorkersNumber') || isempty(Cfg.T1wWarpParallelWorkersNumber)
    Cfg.T1wWarpParallelWorkersNumber = Cfg.ParallelWorkersNumber;
end
if ~isfield(Cfg,'SurfaceParallelWorkersNumber') || isempty(Cfg.SurfaceParallelWorkersNumber)
    Cfg.SurfaceParallelWorkersNumber = Cfg.ParallelWorkersNumber;
end
if ~isfield(Cfg,'TargetWarpParallelWorkersNumber') || isempty(Cfg.TargetWarpParallelWorkersNumber)
    Cfg.TargetWarpParallelWorkersNumber = Cfg.ParallelWorkersNumber;
end
if ~isfield(Cfg,'DockerImage') || isempty(Cfg.DockerImage)
    Cfg.DockerImage = 'cgyan/dpabi';
end
% Multi-echo/tedana specific options live under Cfg.MultiEcho.
% Legacy top-level fields are still accepted and migrated here.
Cfg = local_fill_multiecho_default(Cfg, 'FitType', 'loglin');
Cfg = local_fill_multiecho_default(Cfg, 'Convention', 'bids');
Cfg = local_fill_multiecho_default(Cfg, 'Tree', 'tedana_orig');
Cfg = local_fill_multiecho_default(Cfg, 'TEDPCA', 'aic');
Cfg = local_fill_multiecho_default(Cfg, 'MaskType', 'dropout');
Cfg = local_fill_multiecho_default(Cfg, 'Overwrite', 0);
Cfg = local_fill_multiecho_default(Cfg, 'RunInParallel', 0);
Cfg = local_fill_multiecho_default(Cfg, 'TEUnit', 'auto');
Cfg = local_fill_multiecho_default(Cfg, 'DryRun', 0);
Cfg = local_fill_multiecho_default(Cfg, 'Verbose', 0);
Cfg = local_fill_multiecho_default(Cfg, 'NoReports', 0);
if ~isfield(Cfg,'UseDPABILicenseMount') || isempty(Cfg.UseDPABILicenseMount)
    Cfg.UseDPABILicenseMount = 1;
end
Cfg = local_fill_multiecho_default(Cfg, 'NativeSpace', 'T1w');
Cfg = local_fill_multiecho_default(Cfg, 'RequireT1wSpace', 1);
Cfg = local_fill_multiecho_default(Cfg, 'TargetSpace', 'MNI152NLin2009cAsym');
Cfg = local_fill_multiecho_default(Cfg, 'TargetInterpolation', 'Linear');
Cfg = local_fill_multiecho_default(Cfg, 'RequireTargetSpace', 0);
Cfg = local_fill_multiecho_default(Cfg, 'GenerateSurfaceResults', 1);
Cfg = local_fill_multiecho_default(Cfg, 'RequireSurfaceResults', 0);
Cfg = local_fill_multiecho_default(Cfg, 'SurfaceTargetSpace', 'fsaverage5');
Cfg = local_fill_multiecho_default(Cfg, 'SurfaceInterpolation', 'trilinear');
Cfg = local_fill_multiecho_default(Cfg, 'SurfaceProjectionFraction', 0.5);
Cfg = local_fill_multiecho_default(Cfg, 'EstimatedTedanaMemoryOverheadFactor', 2.5);
Cfg = local_fill_multiecho_default(Cfg, 'MaxTedanaMemoryGB', []);
Cfg = local_fill_multiecho_default(Cfg, 'SafeParallelMode', 1);
Cfg = local_fill_multiecho_default(Cfg, 'MaxTedanaParallelWorkers', 2);
Cfg = local_fill_multiecho_default(Cfg, 'MaxT1wWarpParallelWorkers', 2);
Cfg = local_fill_multiecho_default(Cfg, 'MaxSurfaceParallelWorkers', 2);
Cfg = local_fill_multiecho_default(Cfg, 'MaxTargetWarpParallelWorkers', 1);
Cfg = local_fill_multiecho_default(Cfg, 'RetryFailedJobsOnce', 1);
if ~isfield(Cfg.MultiEcho,'LowMem') || isempty(Cfg.MultiEcho.LowMem)
    if isfield(Cfg,'LowMem') && ~isempty(Cfg.LowMem)
        Cfg.MultiEcho.LowMem = Cfg.LowMem;
    elseif isfield(Cfg,'IsLowMem') && ~isempty(Cfg.IsLowMem)
        Cfg.MultiEcho.LowMem = Cfg.IsLowMem;
    else
        Cfg.MultiEcho.LowMem = 0;
    end
end
Cfg = local_fill_multiecho_default(Cfg, 'NThreads', 1);
Cfg = local_fill_multiecho_default(Cfg, 'MaxIt', []);
Cfg = local_fill_multiecho_default(Cfg, 'MaxRestart', []);
Cfg = local_fill_multiecho_default(Cfg, 'Debug', 0);
Cfg = local_fill_multiecho_default(Cfg, 'TEDORT', 0);
Cfg = local_fill_multiecho_default(Cfg, 'Seed', 42);
Cfg = local_fill_multiecho_default(Cfg, 'CombMode', '');
Cfg = local_fill_multiecho_default(Cfg, 'PNGCMap', '');
Cfg = local_fill_multiecho_default(Cfg, 'GSControl', {});
if ~iscell(Cfg.MultiEcho.GSControl)
    Cfg.MultiEcho.GSControl = {Cfg.MultiEcho.GSControl};
end
Cfg = local_fill_multiecho_default(Cfg, 'T2SMap', '');
Cfg = local_fill_multiecho_default(Cfg, 'MixFile', '');

Cfg.ParallelWorkersNumber = local_normalize_worker_number(Cfg.ParallelWorkersNumber);
Cfg.TedanaParallelWorkersNumber = local_normalize_worker_number(Cfg.TedanaParallelWorkersNumber);
Cfg.T1wWarpParallelWorkersNumber = local_normalize_worker_number(Cfg.T1wWarpParallelWorkersNumber);
Cfg.SurfaceParallelWorkersNumber = local_normalize_worker_number(Cfg.SurfaceParallelWorkersNumber);
Cfg.TargetWarpParallelWorkersNumber = local_normalize_worker_number(Cfg.TargetWarpParallelWorkersNumber);

if Cfg.MultiEcho.SafeParallelMode
    RequestedWorkers = [Cfg.TedanaParallelWorkersNumber, ...
        Cfg.T1wWarpParallelWorkersNumber, Cfg.SurfaceParallelWorkersNumber, ...
        Cfg.TargetWarpParallelWorkersNumber];
    Cfg.TedanaParallelWorkersNumber = local_cap_worker_number( ...
        Cfg.TedanaParallelWorkersNumber, Cfg.MultiEcho.MaxTedanaParallelWorkers);
    Cfg.T1wWarpParallelWorkersNumber = local_cap_worker_number( ...
        Cfg.T1wWarpParallelWorkersNumber, Cfg.MultiEcho.MaxT1wWarpParallelWorkers);
    Cfg.SurfaceParallelWorkersNumber = local_cap_worker_number( ...
        Cfg.SurfaceParallelWorkersNumber, Cfg.MultiEcho.MaxSurfaceParallelWorkers);
    Cfg.TargetWarpParallelWorkersNumber = local_cap_worker_number( ...
        Cfg.TargetWarpParallelWorkersNumber, Cfg.MultiEcho.MaxTargetWarpParallelWorkers);
    SafeWorkers = [Cfg.TedanaParallelWorkersNumber, ...
        Cfg.T1wWarpParallelWorkersNumber, Cfg.SurfaceParallelWorkersNumber, ...
        Cfg.TargetWarpParallelWorkersNumber];
    if any(SafeWorkers < RequestedWorkers)
        fprintf(['Safe parallel mode limits workers (tedana/T1w/surface/target): ' ...
            '%d/%d/%d/%d -> %d/%d/%d/%d.\n'], ...
            [RequestedWorkers, SafeWorkers]);
    end
end
end


function Cfg = local_fill_multiecho_default(Cfg, FieldName, DefaultValue)
if ~isfield(Cfg,'MultiEcho') || ~isstruct(Cfg.MultiEcho)
    Cfg.MultiEcho = struct();
end

if ~isfield(Cfg.MultiEcho, FieldName) || isempty(Cfg.MultiEcho.(FieldName))
    if isfield(Cfg, FieldName) && ~isempty(Cfg.(FieldName))
        Cfg.MultiEcho.(FieldName) = Cfg.(FieldName);
    else
        Cfg.MultiEcho.(FieldName) = DefaultValue;
    end
end
end


function SubjectIDs = local_get_subject_ids(FMRIPrepDir)
DirList = dir(fullfile(FMRIPrepDir, 'sub-*'));
DirList = DirList([DirList.isdir]);
SubjectIDs = {DirList.name};
end


function SurfaceSubjectsDir = local_detect_surface_subjects_dir(Cfg)
CandidateDirSet = { ...
    fullfile(Cfg.FMRIPrepDir, 'sourcedata', 'freesurfer'), ...
    fullfile(Cfg.WorkingDir, 'freesurfer')};

for iDir = 1:numel(CandidateDirSet)
    if local_has_subject_dirs(CandidateDirSet{iDir})
        SurfaceSubjectsDir = CandidateDirSet{iDir};
        return;
    end
end

for iDir = 1:numel(CandidateDirSet)
    if exist(CandidateDirSet{iDir}, 'dir')
        SurfaceSubjectsDir = CandidateDirSet{iDir};
        return;
    end
end

SurfaceSubjectsDir = CandidateDirSet{1};
end


function tf = local_has_subject_dirs(DirPath)
tf = false;
if isempty(DirPath) || ~exist(DirPath, 'dir')
    return;
end

DirList = dir(fullfile(DirPath, 'sub-*'));
DirList = DirList([DirList.isdir]);
tf = ~isempty(DirList);
end


function SurfaceSourceSubjectID = local_resolve_surface_source_subject_id(Cfg, SubjectID, SessionIndex)
SurfaceSourceSubjectID = '';
if isempty(Cfg.SurfaceSubjectsDir) || ~exist(Cfg.SurfaceSubjectsDir, 'dir')
    return;
end

DirList = dir(fullfile(Cfg.SurfaceSubjectsDir, [SubjectID '*']));
DirList = DirList([DirList.isdir]);
if isempty(DirList)
    return;
end

CandidateNameSet = sort({DirList.name});

if any(strcmp(CandidateNameSet, SubjectID))
    SurfaceSourceSubjectID = SubjectID;
    return;
end

CurrentSessionCandidate = sprintf('%s_ses-%d', SubjectID, SessionIndex);
if any(strcmp(CandidateNameSet, CurrentSessionCandidate))
    SurfaceSourceSubjectID = CurrentSessionCandidate;
    return;
end

Session1Candidate = [SubjectID '_ses-1'];
if any(strcmp(CandidateNameSet, Session1Candidate))
    SurfaceSourceSubjectID = Session1Candidate;
    return;
end

SessionCandidateSet = CandidateNameSet(cellfun(@(x) local_starts_with(x, [SubjectID '_ses-']), CandidateNameSet));
if numel(SessionCandidateSet) == 1
    SurfaceSourceSubjectID = SessionCandidateSet{1};
    return;
end

SurfaceSourceSubjectID = CandidateNameSet{1};
end


function SubjectIDs = local_normalize_subject_ids(SubjectIDs)
for i = 1:numel(SubjectIDs)
    if ~local_starts_with(SubjectIDs{i}, 'sub-')
        SubjectIDs{i} = ['sub-' SubjectIDs{i}];
    end
end
end


function [FunSessionPrefixSet, fmriprepfuncSessionPrefixSet] = local_build_session_prefixes(Cfg)
FunSessionPrefixSet={''};
for iFunSession=2:Cfg.FunctionalSessionNumber
    FunSessionPrefixSet=[FunSessionPrefixSet;{['S',num2str(iFunSession),'_']}]; %#ok<AGROW>
end

if Cfg.FunctionalSessionNumber==1
    fmriprepfuncSessionPrefixSet={'func'};
else
    fmriprepfuncSessionPrefixSet=cell(Cfg.FunctionalSessionNumber,1);
    for iFunSession=1:Cfg.FunctionalSessionNumber
        fmriprepfuncSessionPrefixSet{iFunSession}=['ses-',num2str(iFunSession),filesep,'func'];
    end
end
end


function [CommandInit, WorkingDirInContainer] = local_prepare_command_init(Cfg)
WorkingDirInContainer = '/data';

if isdeployed && (isunix && (~ismac))
    CommandInit = sprintf('export SUBJECTS_DIR=%s &&', local_shellquote(fullfile(Cfg.WorkingDir, 'freesurfer')));
    WorkingDirInContainer = Cfg.WorkingDir;
    return;
end

LicenseMount = '';
if Cfg.UseDPABILicenseMount
    [DPABIPath, ~, ~] = fileparts(which('DPABI.m'));
    LicensePath = fullfile(DPABIPath, 'DPABISurf', 'FreeSurferLicense', 'license.txt');
    if exist(LicensePath, 'file')
        LicenseMount = sprintf('-v %s:/opt/freesurfer/license.txt', local_shellquote(LicensePath));
    end
end

if ispc
    UserFlag = '';
else
    UserFlag = '-u $(id -u):$(id -g)';
end

DockerArgs = strtrim(sprintf('-i --rm %s %s -v %s:/data -e SUBJECTS_DIR=/data/freesurfer %s', ...
    UserFlag, ...
    LicenseMount, ...
    local_shellquote(Cfg.WorkingDir), ...
    Cfg.DockerImage));

CommandInit = ['docker run ' DockerArgs];
end


function JobList = local_collect_jobs(Cfg, FunSessionPrefixSet, fmriprepfuncSessionPrefixSet, CommandInit, WorkingDirInContainer)
JobList = struct('SubjectID', {}, 'SessionIndex', {}, 'SessionPrefix', {}, ...
    'FuncDir', {}, 'BasePrefix', {}, 'EchoFiles', {}, ...
    'EchoTimesSeconds', {}, 'EchoTimesForCommand', {}, 'TEUnitUsed', {}, ...
    'EstimatedTedanaEchoNumber', {}, 'EstimatedTedanaVoxelCount', {}, ...
    'EstimatedTedanaTimePointNumber', {}, ...
    'EstimatedTedanaInputMemoryGB', {}, 'EstimatedTedanaPeakMemoryGB', {}, ...
    'SurfaceSourceSubjectID', {}, ...
    'MaskFile', {}, ...
    'T1wReferenceFile', {}, 'T1wMaskFile', {}, 'T1wWarpReferenceFile', {}, ...
    'BoldrefToT1wTransformFile', {}, ...
    'TargetReferenceFile', {}, 'TargetMaskFile', {}, 'TargetWarpReferenceFile', {}, ...
    'SurfaceNativeLeftTemplateFile', {}, 'SurfaceNativeRightTemplateFile', {}, ...
    'SurfaceStandardLeftTemplateFile', {}, 'SurfaceStandardRightTemplateFile', {}, ...
    'TransformFile', {}, 'TedanaOutDir', {}, 'TedanaDenoisedFile', {}, ...
    'WarpedT1wFile', {}, 'WarpedTargetFile', {}, ...
    'SurfaceNativeLeftFile', {}, 'SurfaceNativeRightFile', {}, ...
    'SurfaceStandardLeftFile', {}, 'SurfaceStandardRightFile', {}, ...
    'TargetT1wDir', {}, 'TargetT1wFile', {}, ...
    'TargetSpaceDir', {}, 'TargetSpaceFile', {}, 'TargetMaskDir', {}, ...
    'TargetFunSurfDir', {}, 'TargetFunSurfWDir', {}, ...
    'TargetFunSurfLeftFile', {}, 'TargetFunSurfRightFile', {}, ...
    'TargetFunSurfWLeftFile', {}, 'TargetFunSurfWRightFile', {}, ...
    'TargetNativeMaskFile', {}, 'TargetSpaceMaskFile', {}, ...
    'TedanaCommandBody', {}, 'TedanaCommand', {}, ...
    'T1wWarpCommandBody', {}, 'T1wWarpCommand', {}, ...
    'SurfaceCommandBody', {}, 'SurfaceCommand', {}, ...
    'WarpCommandBody', {}, 'WarpCommand', {}, ...
    'TedanaLogFile', {}, 'T1wWarpLogFile', {}, 'SurfaceLogFile', {}, 'WarpLogFile', {}, ...
    'TedanaStatus', {}, ...
    'TedanaOutput', {}, ...
    'SurfaceStatus', {}, 'SurfaceOutput', {}, ...
    'T1wWarpStatus', {}, 'T1wWarpOutput', {}, ...
    'WarpStatus', {}, 'WarpOutput', {}, ...
    'Success', {}, 'ErrorMessage', {});

for iSubject = 1:Cfg.SubjectNum
    SubjectID = Cfg.SubjectID{iSubject};
    SubjectTransformFile = local_find_t1w_to_target_transform(Cfg.FMRIPrepDir, SubjectID, Cfg.MultiEcho.TargetSpace);

    for iFunSession = 1:Cfg.FunctionalSessionNumber
        FuncDir = fullfile(Cfg.FMRIPrepDir, SubjectID, fmriprepfuncSessionPrefixSet{iFunSession});
        if ~exist(FuncDir, 'dir')
            warning('Functional directory not found, skipping: %s', FuncDir);
            continue;
        end

        EchoFiles = dir(fullfile(FuncDir, '*_echo-*_desc-preproc_bold.nii.gz'));
        if isempty(EchoFiles)
            warning(['No multi-echo fMRIPrep outputs were found in %s.\n' ...
                'tedana is only created from echo-wise files, so this session will be skipped.'], ...
                FuncDir);
            continue;
        end

        GroupKeys = cell(numel(EchoFiles),1);
        for iFile = 1:numel(EchoFiles)
            GroupKeys{iFile} = regexprep(EchoFiles(iFile).name, '_echo-\d+_desc-preproc_bold\.nii\.gz$', '');
        end
        UniqueKeys = unique(GroupKeys);

        for iKey = 1:numel(UniqueKeys)
            BasePrefix = UniqueKeys{iKey};
            IsThisGroup = strcmp(GroupKeys, BasePrefix);
            ThisFiles = EchoFiles(IsThisGroup);

            ThisPaths = cell(numel(ThisFiles),1);
            ThisEchoTimesSec = nan(numel(ThisFiles),1);
            ThisEchoNumbers = nan(numel(ThisFiles),1);

            for iEcho = 1:numel(ThisFiles)
                ThisPaths{iEcho} = fullfile(ThisFiles(iEcho).folder, ThisFiles(iEcho).name);

                EchoToken = regexp(ThisFiles(iEcho).name, '_echo-(\d+)_', 'tokens', 'once');
                if ~isempty(EchoToken)
                    ThisEchoNumbers(iEcho) = str2double(EchoToken{1});
                end

                JsonFile = strrep(ThisPaths{iEcho}, '.nii.gz', '.json');
                if ~exist(JsonFile, 'file')
                    error('JSON sidecar not found for %s', ThisPaths{iEcho});
                end
                ThisEchoTimesSec(iEcho) = local_read_echo_time_seconds(JsonFile);
            end

            if all(~isnan(ThisEchoTimesSec))
                [~, SortIndex] = sort(ThisEchoTimesSec, 'ascend');
            else
                [~, SortIndex] = sort(ThisEchoNumbers, 'ascend');
            end
            ThisPaths = ThisPaths(SortIndex);
            ThisEchoTimesSec = ThisEchoTimesSec(SortIndex);

            if numel(ThisPaths) < 2
                warning('Skipping %s because fewer than two echoes were found.', BasePrefix);
                continue;
            end

            if strcmpi(Cfg.MultiEcho.TEUnit, 'seconds')
                TEForCommand = ThisEchoTimesSec(:)';
            elseif strcmpi(Cfg.MultiEcho.TEUnit, 'milliseconds')
                TEForCommand = ThisEchoTimesSec(:)' * 1000;
            else
                error('Unknown Cfg.MultiEcho.TEUnit: %s', Cfg.MultiEcho.TEUnit);
            end

            MaskFile = fullfile(FuncDir, [BasePrefix '_desc-brain_mask.nii.gz']);
            if ~exist(MaskFile, 'file')
                MaskFile = '';
            end

            T1wReferenceFile = local_find_preferred_file(FuncDir, { ...
                [BasePrefix '_space-T1w*_desc-preproc_bold.nii.gz'], ...
                [BasePrefix '_space-T1w*_desc-preproc_bold.nii']});
            T1wMaskFile = local_find_preferred_file(FuncDir, { ...
                [BasePrefix '_space-T1w*_desc-brain_mask.nii.gz'], ...
                [BasePrefix '_space-T1w*_desc-brain_mask.nii']});
            T1wWarpReferenceFile = local_find_preferred_file(FuncDir, { ...
                [BasePrefix '_space-T1w*_boldref.nii.gz'], ...
                [BasePrefix '_space-T1w*_boldref.nii'], ...
                [BasePrefix '_space-T1w*_desc-brain_mask.nii.gz'], ...
                [BasePrefix '_space-T1w*_desc-brain_mask.nii'], ...
                [BasePrefix '_space-T1w*_desc-preproc_bold.nii.gz'], ...
                [BasePrefix '_space-T1w*_desc-preproc_bold.nii']});

            TargetReferenceFile = local_find_preferred_file(FuncDir, { ...
                [BasePrefix '_space-' Cfg.MultiEcho.TargetSpace '*_desc-preproc_bold.nii.gz'], ...
                [BasePrefix '_space-' Cfg.MultiEcho.TargetSpace '*_desc-preproc_bold.nii']});
            TargetMaskFile = local_find_preferred_file(FuncDir, { ...
                [BasePrefix '_space-' Cfg.MultiEcho.TargetSpace '*_desc-brain_mask.nii.gz'], ...
                [BasePrefix '_space-' Cfg.MultiEcho.TargetSpace '*_desc-brain_mask.nii']});
            TargetWarpReferenceFile = local_find_preferred_file(FuncDir, { ...
                [BasePrefix '_space-' Cfg.MultiEcho.TargetSpace '*_boldref.nii.gz'], ...
                [BasePrefix '_space-' Cfg.MultiEcho.TargetSpace '*_boldref.nii'], ...
                [BasePrefix '_space-' Cfg.MultiEcho.TargetSpace '*_desc-brain_mask.nii.gz'], ...
                [BasePrefix '_space-' Cfg.MultiEcho.TargetSpace '*_desc-brain_mask.nii'], ...
                [BasePrefix '_space-' Cfg.MultiEcho.TargetSpace '*_desc-preproc_bold.nii.gz'], ...
                [BasePrefix '_space-' Cfg.MultiEcho.TargetSpace '*_desc-preproc_bold.nii']});
            SurfaceNativeLeftTemplateFile = local_find_preferred_file(FuncDir, { ...
                [BasePrefix '_hemi-L_space-fsnative*_bold.func.gii']});
            SurfaceNativeRightTemplateFile = local_find_preferred_file(FuncDir, { ...
                [BasePrefix '_hemi-R_space-fsnative*_bold.func.gii']});
            SurfaceStandardLeftTemplateFile = local_find_preferred_file(FuncDir, { ...
                [BasePrefix '_hemi-L_space-' Cfg.MultiEcho.SurfaceTargetSpace '*_bold.func.gii']});
            SurfaceStandardRightTemplateFile = local_find_preferred_file(FuncDir, { ...
                [BasePrefix '_hemi-R_space-' Cfg.MultiEcho.SurfaceTargetSpace '*_bold.func.gii']});

            BoldrefToT1wTransformFile = local_find_preferred_file(FuncDir, { ...
                [BasePrefix '_from-boldref_to-T1w_mode-image*xfm.h5'], ...
                [BasePrefix '_from-boldref_to-T1w_mode-image*xfm.txt']});
            TargetTransformFile = SubjectTransformFile;

            MissingT1wReason = '';
            if isempty(T1wReferenceFile)
                MissingT1wReason = sprintf('T1w-space desc-preproc_bold file not found for %s in %s.', BasePrefix, FuncDir);
            elseif isempty(T1wWarpReferenceFile)
                MissingT1wReason = sprintf('T1w-space warp reference (prefer boldref or mask) not found for %s in %s.', BasePrefix, FuncDir);
            elseif isempty(BoldrefToT1wTransformFile)
                MissingT1wReason = sprintf('boldref-to-T1w transform not found for %s in %s.', BasePrefix, FuncDir);
            end
            if ~isempty(MissingT1wReason)
                if Cfg.MultiEcho.RequireT1wSpace
                    warning('Skipping %s because %s', BasePrefix, MissingT1wReason);
                else
                    warning('Skipping %s because %s', BasePrefix, MissingT1wReason);
                end
                continue;
            end

            NeedTargetWarp = ~isempty(TargetReferenceFile) && ~isempty(TargetWarpReferenceFile) ...
                && ~isempty(BoldrefToT1wTransformFile) && ~isempty(TargetTransformFile);
            if ~NeedTargetWarp
                if Cfg.MultiEcho.RequireTargetSpace
                    warning(['Skipping %s because target-space organization is incomplete.\n' ...
                        'Target reference: %d, target warp reference: %d, boldref-to-T1w transform: %d, T1w-to-%s transform: %d'], ...
                        BasePrefix, ~isempty(TargetReferenceFile), ~isempty(TargetWarpReferenceFile), ...
                        ~isempty(BoldrefToT1wTransformFile), Cfg.MultiEcho.TargetSpace, ~isempty(TargetTransformFile));
                    continue;
                end
                TargetReferenceFile = '';
                TargetMaskFile = '';
                TargetWarpReferenceFile = '';
                TargetTransformFile = '';
            end

            NeedSurfaceNative = Cfg.MultiEcho.GenerateSurfaceResults ...
                && ~isempty(SurfaceNativeLeftTemplateFile) && ~isempty(SurfaceNativeRightTemplateFile);
            NeedSurfaceStandard = Cfg.MultiEcho.GenerateSurfaceResults && NeedSurfaceNative ...
                && ~isempty(SurfaceStandardLeftTemplateFile) && ~isempty(SurfaceStandardRightTemplateFile);
            SurfaceSourceSubjectID = '';
            if NeedSurfaceNative || NeedSurfaceStandard
                SurfaceSourceSubjectID = local_resolve_surface_source_subject_id(Cfg, SubjectID, iFunSession);
                if isempty(SurfaceSourceSubjectID)
                    SurfaceWarningMessage = sprintf(['No matching FreeSurfer subject was found for %s under %s. ' ...
                        'Expected %s or %s_ses-*.'], SubjectID, Cfg.SurfaceSubjectsDir, SubjectID, SubjectID);
                    if Cfg.MultiEcho.RequireSurfaceResults
                        warning('Skipping %s because %s', BasePrefix, SurfaceWarningMessage);
                        continue;
                    end
                    warning('Some surface outputs may be skipped for %s because %s', BasePrefix, SurfaceWarningMessage);
                    NeedSurfaceNative = false;
                    NeedSurfaceStandard = false;
                end
            end

            SurfaceWarningMessage = '';
            if Cfg.MultiEcho.GenerateSurfaceResults && xor(isempty(SurfaceNativeLeftTemplateFile), isempty(SurfaceNativeRightTemplateFile))
                SurfaceWarningMessage = sprintf('fsnative surface templates are incomplete for %s in %s.', BasePrefix, FuncDir);
            elseif Cfg.MultiEcho.GenerateSurfaceResults && NeedSurfaceNative ...
                    && xor(isempty(SurfaceStandardLeftTemplateFile), isempty(SurfaceStandardRightTemplateFile))
                SurfaceWarningMessage = sprintf('%s surface templates are incomplete for %s in %s.', Cfg.MultiEcho.SurfaceTargetSpace, BasePrefix, FuncDir);
            end
            if ~isempty(SurfaceWarningMessage)
                if Cfg.MultiEcho.RequireSurfaceResults
                    warning('Skipping %s because %s', BasePrefix, SurfaceWarningMessage);
                    continue;
                end
                warning('Some surface outputs may be skipped for %s because %s', BasePrefix, SurfaceWarningMessage);
            end

            RelFuncDir = local_relative_path(FuncDir, Cfg.FMRIPrepDir);
            TedanaOutDir = fullfile(Cfg.TedanaDir, RelFuncDir, BasePrefix);
            if ~exist(TedanaOutDir, 'dir')
                mkdir(TedanaOutDir);
            end

            TedanaDenoisedFile = fullfile(TedanaOutDir, [BasePrefix '_desc-denoised_bold.nii.gz']);
            WarpedT1wFile = local_build_output_from_reference(T1wReferenceFile, TedanaOutDir, [BasePrefix '_space-T1w_desc-denoised_bold.nii.gz']);
            if NeedTargetWarp
                WarpedTargetFile = local_build_output_from_reference(TargetReferenceFile, TedanaOutDir, [BasePrefix '_space-' Cfg.MultiEcho.TargetSpace '_desc-denoised_bold.nii.gz']);
            else
                WarpedTargetFile = '';
            end
            if NeedSurfaceNative
                SurfaceNativeLeftFile = local_build_surface_output_from_reference(SurfaceNativeLeftTemplateFile, TedanaOutDir, [BasePrefix '_hemi-L_space-fsnative_desc-denoised_bold.func.gii']);
                SurfaceNativeRightFile = local_build_surface_output_from_reference(SurfaceNativeRightTemplateFile, TedanaOutDir, [BasePrefix '_hemi-R_space-fsnative_desc-denoised_bold.func.gii']);
            else
                SurfaceNativeLeftFile = '';
                SurfaceNativeRightFile = '';
            end
            if NeedSurfaceStandard
                SurfaceStandardLeftFile = local_build_surface_output_from_reference(SurfaceStandardLeftTemplateFile, TedanaOutDir, [BasePrefix '_hemi-L_space-fsaverage5_desc-denoised_bold.func.gii']);
                SurfaceStandardRightFile = local_build_surface_output_from_reference(SurfaceStandardRightTemplateFile, TedanaOutDir, [BasePrefix '_hemi-R_space-fsaverage5_desc-denoised_bold.func.gii']);
            else
                SurfaceStandardLeftFile = '';
                SurfaceStandardRightFile = '';
            end

            TargetT1wDir = fullfile(Cfg.WorkingDir, [FunSessionPrefixSet{iFunSession},'FunVolu'], SubjectID);
            TargetSpaceDir = fullfile(Cfg.WorkingDir, [FunSessionPrefixSet{iFunSession},'FunVoluW'], SubjectID);
            TargetFunSurfDir = fullfile(Cfg.WorkingDir, [FunSessionPrefixSet{iFunSession},'FunSurf'], SubjectID);
            TargetFunSurfWDir = fullfile(Cfg.WorkingDir, [FunSessionPrefixSet{iFunSession},'FunSurfW'], SubjectID);
            TargetMaskDir = fullfile(Cfg.WorkingDir, 'Masks', [FunSessionPrefixSet{iFunSession},'AutoMasks']);
            if Cfg.FunctionalSessionNumber==1
                TargetMaskDir = fullfile(Cfg.WorkingDir, 'Masks', 'AutoMasks');
            end

            TargetT1wFile = local_build_output_from_reference(T1wReferenceFile, TargetT1wDir, [BasePrefix '_space-T1w_desc-denoised_bold.nii.gz']);
            if NeedSurfaceNative
                TargetFunSurfLeftFile = local_build_surface_output_from_reference(SurfaceNativeLeftTemplateFile, TargetFunSurfDir, [BasePrefix '_hemi-L_space-fsnative_desc-denoised_bold.func.gii']);
                TargetFunSurfRightFile = local_build_surface_output_from_reference(SurfaceNativeRightTemplateFile, TargetFunSurfDir, [BasePrefix '_hemi-R_space-fsnative_desc-denoised_bold.func.gii']);
            else
                TargetFunSurfLeftFile = '';
                TargetFunSurfRightFile = '';
            end
            if NeedSurfaceStandard
                TargetFunSurfWLeftFile = local_build_surface_output_from_reference(SurfaceStandardLeftTemplateFile, TargetFunSurfWDir, [BasePrefix '_hemi-L_space-fsaverage5_desc-denoised_bold.func.gii']);
                TargetFunSurfWRightFile = local_build_surface_output_from_reference(SurfaceStandardRightTemplateFile, TargetFunSurfWDir, [BasePrefix '_hemi-R_space-fsaverage5_desc-denoised_bold.func.gii']);
            else
                TargetFunSurfWLeftFile = '';
                TargetFunSurfWRightFile = '';
            end
            TargetNativeMaskFile = local_build_target_copy_file(T1wMaskFile, TargetMaskDir, [BasePrefix '_space-T1w_desc-brain_mask.nii.gz']);
            if NeedTargetWarp
                TargetSpaceFile = local_build_output_from_reference(TargetReferenceFile, TargetSpaceDir, [BasePrefix '_space-' Cfg.MultiEcho.TargetSpace '_desc-denoised_bold.nii.gz']);
                TargetSpaceMaskFile = local_build_target_copy_file(TargetMaskFile, TargetMaskDir, [BasePrefix '_space-' Cfg.MultiEcho.TargetSpace '_desc-brain_mask.nii.gz']);
            else
                TargetSpaceFile = '';
                TargetSpaceMaskFile = '';
            end

            TedanaCommandBody = local_build_tedana_command_body(Cfg, WorkingDirInContainer, ThisPaths, TEForCommand, MaskFile, TedanaOutDir, BasePrefix);
            TedanaCommand = local_prefix_command(CommandInit, TedanaCommandBody);
            T1wWarpCommand = '';
            T1wWarpCommandBody = '';
            SurfaceCommand = '';
            SurfaceCommandBody = '';
            WarpCommand = '';
            WarpCommandBody = '';

            ThisJob = struct();
            ThisJob.SubjectID = SubjectID;
            ThisJob.SessionIndex = iFunSession;
            ThisJob.SessionPrefix = FunSessionPrefixSet{iFunSession};
            ThisJob.FuncDir = FuncDir;
            ThisJob.BasePrefix = BasePrefix;
            ThisJob.EchoFiles = ThisPaths;
            ThisJob.EchoTimesSeconds = ThisEchoTimesSec(:)';
            ThisJob.EchoTimesForCommand = TEForCommand;
            ThisJob.TEUnitUsed = Cfg.MultiEcho.TEUnit;
            ThisJob.EstimatedTedanaEchoNumber = numel(ThisPaths);
            ThisJob.EstimatedTedanaVoxelCount = nan;
            ThisJob.EstimatedTedanaTimePointNumber = nan;
            ThisJob.EstimatedTedanaInputMemoryGB = nan;
            ThisJob.EstimatedTedanaPeakMemoryGB = nan;
            ThisJob.SurfaceSourceSubjectID = SurfaceSourceSubjectID;
            ThisJob.MaskFile = MaskFile;
            ThisJob.T1wReferenceFile = T1wReferenceFile;
            ThisJob.T1wMaskFile = T1wMaskFile;
            ThisJob.T1wWarpReferenceFile = T1wWarpReferenceFile;
            ThisJob.BoldrefToT1wTransformFile = BoldrefToT1wTransformFile;
            ThisJob.TargetReferenceFile = TargetReferenceFile;
            ThisJob.TargetMaskFile = TargetMaskFile;
            ThisJob.TargetWarpReferenceFile = TargetWarpReferenceFile;
            ThisJob.SurfaceNativeLeftTemplateFile = SurfaceNativeLeftTemplateFile;
            ThisJob.SurfaceNativeRightTemplateFile = SurfaceNativeRightTemplateFile;
            ThisJob.SurfaceStandardLeftTemplateFile = SurfaceStandardLeftTemplateFile;
            ThisJob.SurfaceStandardRightTemplateFile = SurfaceStandardRightTemplateFile;
            ThisJob.TransformFile = TargetTransformFile;
            ThisJob.TedanaOutDir = TedanaOutDir;
            ThisJob.TedanaDenoisedFile = TedanaDenoisedFile;
            ThisJob.WarpedT1wFile = WarpedT1wFile;
            ThisJob.WarpedTargetFile = WarpedTargetFile;
            ThisJob.SurfaceNativeLeftFile = SurfaceNativeLeftFile;
            ThisJob.SurfaceNativeRightFile = SurfaceNativeRightFile;
            ThisJob.SurfaceStandardLeftFile = SurfaceStandardLeftFile;
            ThisJob.SurfaceStandardRightFile = SurfaceStandardRightFile;
            ThisJob.TargetT1wDir = TargetT1wDir;
            ThisJob.TargetT1wFile = TargetT1wFile;
            ThisJob.TargetSpaceDir = TargetSpaceDir;
            ThisJob.TargetSpaceFile = TargetSpaceFile;
            ThisJob.TargetFunSurfDir = TargetFunSurfDir;
            ThisJob.TargetFunSurfWDir = TargetFunSurfWDir;
            ThisJob.TargetFunSurfLeftFile = TargetFunSurfLeftFile;
            ThisJob.TargetFunSurfRightFile = TargetFunSurfRightFile;
            ThisJob.TargetFunSurfWLeftFile = TargetFunSurfWLeftFile;
            ThisJob.TargetFunSurfWRightFile = TargetFunSurfWRightFile;
            ThisJob.TargetMaskDir = TargetMaskDir;
            ThisJob.TargetNativeMaskFile = TargetNativeMaskFile;
            ThisJob.TargetSpaceMaskFile = TargetSpaceMaskFile;
            ThisJob.TedanaCommandBody = TedanaCommandBody;
            ThisJob.TedanaCommand = TedanaCommand;
            ThisJob.T1wWarpCommandBody = T1wWarpCommandBody;
            ThisJob.T1wWarpCommand = T1wWarpCommand;
            ThisJob.SurfaceCommandBody = SurfaceCommandBody;
            ThisJob.SurfaceCommand = SurfaceCommand;
            ThisJob.WarpCommandBody = WarpCommandBody;
            ThisJob.WarpCommand = WarpCommand;
            ThisJob.TedanaLogFile = fullfile(TedanaOutDir, 'tedana.log');
            ThisJob.T1wWarpLogFile = fullfile(TedanaOutDir, 'warp_to_T1w.log');
            ThisJob.SurfaceLogFile = fullfile(TedanaOutDir, 'surf.log');
            ThisJob.WarpLogFile = fullfile(TedanaOutDir, 'warp_to_target.log');
            ThisJob.TedanaStatus = nan;
            ThisJob.TedanaOutput = '';
            ThisJob.SurfaceStatus = nan;
            ThisJob.SurfaceOutput = '';
            ThisJob.T1wWarpStatus = nan;
            ThisJob.T1wWarpOutput = '';
            ThisJob.WarpStatus = nan;
            ThisJob.WarpOutput = '';
            ThisJob.Success = 0;
            ThisJob.ErrorMessage = '';

            JobList(end+1) = ThisJob; %#ok<AGROW>
        end
    end
end
end


function CommandBody = local_build_tedana_command_body(Cfg, WorkingDirInContainer, EchoPaths, TEForCommand, MaskFile, OutDir, Prefix)
EchoArg = strjoin(cellfun(@local_shellquote, local_map_to_container_paths(EchoPaths, Cfg.WorkingDir, WorkingDirInContainer), 'UniformOutput', false), ' ');
TEArg = strjoin(arrayfun(@(x)sprintf('%.6f', x), TEForCommand, 'UniformOutput', false), ' ');

CommandBody = sprintf('tedana -d %s -e %s --out-dir %s --prefix %s --convention %s --fittype %s --tedpca %s --tree %s --n-threads %d', ...
    EchoArg, ...
    TEArg, ...
    local_shellquote(local_map_to_container_path(OutDir, Cfg.WorkingDir, WorkingDirInContainer)), ...
    local_shellquote(Prefix), ...
    Cfg.MultiEcho.Convention, ...
    Cfg.MultiEcho.FitType, ...
    local_to_char(Cfg.MultiEcho.TEDPCA), ...
    local_to_char(Cfg.MultiEcho.Tree), ...
    Cfg.MultiEcho.NThreads);

if ~isempty(MaskFile)
    CommandBody = sprintf('%s --mask %s', CommandBody, ...
        local_shellquote(local_map_to_container_path(MaskFile, Cfg.WorkingDir, WorkingDirInContainer)));
end
if ~isempty(Cfg.MultiEcho.CombMode)
    CommandBody = sprintf('%s --combmode %s', CommandBody, local_to_char(Cfg.MultiEcho.CombMode));
end

if ~isempty(Cfg.MultiEcho.MaskType)
    MaskTypeArgs = local_build_multi_value_arg('--masktype', Cfg.MultiEcho.MaskType);
    if ~isempty(MaskTypeArgs)
        CommandBody = sprintf('%s %s', CommandBody, MaskTypeArgs);
    end
end

if ~isempty(Cfg.MultiEcho.Seed)
    CommandBody = sprintf('%s --seed %d', CommandBody, Cfg.MultiEcho.Seed);
end
if ~isempty(Cfg.MultiEcho.MaxIt)
    CommandBody = sprintf('%s --maxit %d', CommandBody, Cfg.MultiEcho.MaxIt);
end
if ~isempty(Cfg.MultiEcho.MaxRestart)
    CommandBody = sprintf('%s --maxrestart %d', CommandBody, Cfg.MultiEcho.MaxRestart);
end
if ~isempty(Cfg.MultiEcho.GSControl)
    GSArgs = local_build_multi_value_arg('--gscontrol', Cfg.MultiEcho.GSControl);
    if ~isempty(GSArgs)
        CommandBody = sprintf('%s %s', CommandBody, GSArgs);
    end
end
if ~isempty(Cfg.MultiEcho.PNGCMap)
    CommandBody = sprintf('%s --png-cmap %s', CommandBody, local_to_char(Cfg.MultiEcho.PNGCMap));
end
if ~isempty(Cfg.MultiEcho.T2SMap)
    CommandBody = sprintf('%s --t2smap %s', CommandBody, ...
        local_shellquote(local_map_to_container_path(Cfg.MultiEcho.T2SMap, Cfg.WorkingDir, WorkingDirInContainer)));
end
if ~isempty(Cfg.MultiEcho.MixFile)
    CommandBody = sprintf('%s --mix %s', CommandBody, ...
        local_shellquote(local_map_to_container_path(Cfg.MultiEcho.MixFile, Cfg.WorkingDir, WorkingDirInContainer)));
end
if Cfg.MultiEcho.Overwrite
    CommandBody = sprintf('%s --overwrite', CommandBody);
end
if Cfg.MultiEcho.Verbose
    CommandBody = sprintf('%s --verbose', CommandBody);
end
if Cfg.MultiEcho.NoReports
    CommandBody = sprintf('%s --no-reports', CommandBody);
end
if Cfg.MultiEcho.LowMem
    CommandBody = sprintf('%s --lowmem', CommandBody);
end
if Cfg.MultiEcho.TEDORT
    CommandBody = sprintf('%s --tedort', CommandBody);
end
if Cfg.MultiEcho.Debug
    CommandBody = sprintf('%s --debug', CommandBody);
end
end


function CommandBody = local_build_warp_command_body(WorkingDirInContainer, Cfg, InFile, RefFile, TransformFiles, OutFile)
if ischar(TransformFiles) || isa(TransformFiles, 'string')
    TransformFiles = {char(TransformFiles)};
end
TransformFiles = TransformFiles(~cellfun('isempty', TransformFiles));
if isempty(TransformFiles)
    error('At least one transform is required for antsApplyTransforms.');
end

TransformArg = '';
for iTransform = 1:numel(TransformFiles)
    TransformArg = sprintf('%s -t %s', TransformArg, ...
        local_shellquote(local_map_to_container_path(TransformFiles{iTransform}, Cfg.WorkingDir, WorkingDirInContainer)));
end
TransformArg = strtrim(TransformArg);

% Write to a temporary file first. antsApplyTransforms may leave a truncated
% output when it is killed by the OOM killer. A final-path rename only after
% exit status 0 makes existence of OutFile an atomic completion signal for
% all newly generated outputs.
PartialOutFile = local_build_partial_output_file(OutFile);
PartialOutContainer = local_map_to_container_path(PartialOutFile, Cfg.WorkingDir, WorkingDirInContainer);
OutContainer = local_map_to_container_path(OutFile, Cfg.WorkingDir, WorkingDirInContainer);

CommandBody = sprintf(['rm -f %s\n' ...
    'antsApplyTransforms -d 3 -e 3 -i %s -r %s %s -n %s -o %s\n' ...
    'mv -f %s %s'], ...
    local_shellquote(PartialOutContainer), ...
    local_shellquote(local_map_to_container_path(InFile, Cfg.WorkingDir, WorkingDirInContainer)), ...
    local_shellquote(local_map_to_container_path(RefFile, Cfg.WorkingDir, WorkingDirInContainer)), ...
    TransformArg, ...
    Cfg.MultiEcho.TargetInterpolation, ...
    local_shellquote(PartialOutContainer), ...
    local_shellquote(PartialOutContainer), ...
    local_shellquote(OutContainer));
end


function CommandBody = local_build_surface_command_body(WorkingDirInContainer, Cfg, Job)
CommandList = {};

if local_has_surface_native(Job)
    CommandList{end+1} = local_build_vol2surf_command_body(WorkingDirInContainer, Cfg, Job.WarpedT1wFile, Job.SurfaceSourceSubjectID, 'lh', '', Job.SurfaceNativeLeftFile); %#ok<AGROW>
    CommandList{end+1} = local_build_vol2surf_command_body(WorkingDirInContainer, Cfg, Job.WarpedT1wFile, Job.SurfaceSourceSubjectID, 'rh', '', Job.SurfaceNativeRightFile); %#ok<AGROW>
end

if local_has_surface_standard(Job)
    CommandList{end+1} = local_build_vol2surf_command_body(WorkingDirInContainer, Cfg, Job.WarpedT1wFile, Job.SurfaceSourceSubjectID, 'lh', Cfg.MultiEcho.SurfaceTargetSpace, Job.SurfaceStandardLeftFile); %#ok<AGROW>
    CommandList{end+1} = local_build_vol2surf_command_body(WorkingDirInContainer, Cfg, Job.WarpedT1wFile, Job.SurfaceSourceSubjectID, 'rh', Cfg.MultiEcho.SurfaceTargetSpace, Job.SurfaceStandardRightFile); %#ok<AGROW>
end

CommandBody = strjoin(CommandList, sprintf('\n'));
end


function [Cfg, JobList] = local_prepare_tedana_memory_plan(JobList, Cfg)
if isempty(JobList)
    return;
end

EstimatedInputGB = nan(numel(JobList),1);
EstimatedPeakGB = nan(numel(JobList),1);

for iJob = 1:numel(JobList)
    [EstimatedInputGB(iJob), EstimatedPeakGB(iJob), EstimatedVoxelCount, EstimatedTimePointNumber] = ...
        local_estimate_tedana_memory_gb(JobList(iJob), Cfg);
    JobList(iJob).EstimatedTedanaVoxelCount = EstimatedVoxelCount;
    JobList(iJob).EstimatedTedanaTimePointNumber = EstimatedTimePointNumber;
    JobList(iJob).EstimatedTedanaInputMemoryGB = EstimatedInputGB(iJob);
    JobList(iJob).EstimatedTedanaPeakMemoryGB = EstimatedPeakGB(iJob);
end

ValidIndex = isfinite(EstimatedInputGB) & isfinite(EstimatedPeakGB) ...
    & EstimatedInputGB > 0 & EstimatedPeakGB > 0;
if ~any(ValidIndex)
    fprintf('Tedana memory estimate is unavailable for the current jobs. Continue with tedana parallel -j %d.\n', ...
        Cfg.TedanaParallelWorkersNumber);
    return;
end

MedianInputGB = median(EstimatedInputGB(ValidIndex));
MedianPeakGB = median(EstimatedPeakGB(ValidIndex));
MaxInputGB = max(EstimatedInputGB(ValidIndex));
MaxPeakGB = max(EstimatedPeakGB(ValidIndex));

fprintf(['Estimated tedana memory per job:\n' ...
    '  raw float64 stack median/max = %.2f / %.2f GB\n' ...
    '  peak working estimate median/max = %.2f / %.2f GB (factor %.2f)\n'], ...
    MedianInputGB, MaxInputGB, MedianPeakGB, MaxPeakGB, Cfg.MultiEcho.EstimatedTedanaMemoryOverheadFactor);

if ~isempty(Cfg.MultiEcho.MaxTedanaMemoryGB) && isfinite(Cfg.MultiEcho.MaxTedanaMemoryGB) && Cfg.MultiEcho.MaxTedanaMemoryGB > 0
    SafeWorkers = max(1, floor(Cfg.MultiEcho.MaxTedanaMemoryGB / MaxPeakGB));
    if SafeWorkers < Cfg.TedanaParallelWorkersNumber
        fprintf(['Reduce tedana parallel workers from %d to %d to respect ' ...
            'Cfg.MultiEcho.MaxTedanaMemoryGB = %.2f GB.\n'], ...
            Cfg.TedanaParallelWorkersNumber, SafeWorkers, Cfg.MultiEcho.MaxTedanaMemoryGB);
        Cfg.TedanaParallelWorkersNumber = SafeWorkers;
    end
end

ProjectedPeakGB = MaxPeakGB * Cfg.TedanaParallelWorkersNumber;
fprintf('Current tedana parallel plan after memory check: %d worker(s), projected combined peak ~= %.2f GB.\n', ...
    Cfg.TedanaParallelWorkersNumber, ProjectedPeakGB);
end


function [EstimatedInputGB, EstimatedPeakGB, EstimatedVoxelCount, EstimatedTimePointNumber] = local_estimate_tedana_memory_gb(Job, Cfg)
EstimatedInputGB = nan;
EstimatedPeakGB = nan;
EstimatedVoxelCount = nan;
EstimatedTimePointNumber = nan;

if isempty(Job.EchoFiles)
    return;
end

if ~isempty(Job.MaskFile)
    MaskVoxelCount = local_count_mask_voxels(Job.MaskFile);
    if isfinite(MaskVoxelCount) && MaskVoxelCount > 0
        EstimatedVoxelCount = double(MaskVoxelCount);
    end
end

ConfoundsFile = fullfile(Job.FuncDir, [Job.BasePrefix '_desc-confounds_timeseries.tsv']);
if exist(ConfoundsFile, 'file')
    EstimatedTimePointNumber = local_count_tsv_data_rows(ConfoundsFile);
end

NeedImageHeader = (~isfinite(EstimatedVoxelCount) || EstimatedVoxelCount < 1) ...
    || (~isfinite(EstimatedTimePointNumber) || EstimatedTimePointNumber < 1);
if NeedImageHeader
    [VolumeSize, TimePointNumberFromHeader] = local_read_nifti_size(Job.EchoFiles{1});
    if ~isfinite(EstimatedVoxelCount) || EstimatedVoxelCount < 1
        if isempty(VolumeSize)
            return;
        end
        EstimatedVoxelCount = prod(double(VolumeSize));
    end
    if ~isfinite(EstimatedTimePointNumber) || EstimatedTimePointNumber < 1
        EstimatedTimePointNumber = TimePointNumberFromHeader;
    end
end

if ~isfinite(EstimatedVoxelCount) || EstimatedVoxelCount < 1 ...
        || ~isfinite(EstimatedTimePointNumber) || EstimatedTimePointNumber < 1
    return;
end

EstimatedInputBytes = double(EstimatedVoxelCount) ...
    * double(numel(Job.EchoFiles)) ...
    * double(EstimatedTimePointNumber) ...
    * 8;
EstimatedInputGB = EstimatedInputBytes / (1024^3);
EstimatedPeakGB = EstimatedInputGB * double(Cfg.MultiEcho.EstimatedTedanaMemoryOverheadFactor);
end


function [VolumeSize, TimePointNumber] = local_read_nifti_size(FileName)
VolumeSize = [];
TimePointNumber = nan;

try
    if exist('niftiinfo', 'file') == 2
        Info = niftiinfo(FileName);
        if isfield(Info, 'ImageSize') && numel(Info.ImageSize) >= 3
            ImageSize = double(Info.ImageSize);
            VolumeSize = ImageSize(1:3);
            if numel(ImageSize) >= 4
                TimePointNumber = ImageSize(4);
            else
                TimePointNumber = 1;
            end
            return;
        end
    end
catch
end

[ReadableFile, CleanupDir] = local_prepare_nifti_for_read(FileName);
CleanupObj = onCleanup(@() local_cleanup_temp_dir(CleanupDir)); %#ok<NASGU>

try
    Header = spm_vol(ReadableFile);
    if ~isempty(Header)
        VolumeSize = double(Header(1).dim(1:3));
        TimePointNumber = numel(Header);
    end
catch
end
end


function MaskVoxelCount = local_count_mask_voxels(FileName)
MaskVoxelCount = nan;
if isempty(FileName) || ~exist(FileName, 'file')
    return;
end

try
    if exist('niftiread', 'file') == 2
        Data = niftiread(FileName);
        MaskVoxelCount = nnz(Data > 0 & ~isnan(Data));
        return;
    end
catch
end

[ReadableFile, CleanupDir] = local_prepare_nifti_for_read(FileName);
CleanupObj = onCleanup(@() local_cleanup_temp_dir(CleanupDir)); %#ok<NASGU>

try
    Header = spm_vol(ReadableFile);
    Data = spm_read_vols(Header);
    MaskVoxelCount = nnz(Data > 0 & ~isnan(Data));
catch
end
end


function [ReadableFile, CleanupDir] = local_prepare_nifti_for_read(FileName)
ReadableFile = FileName;
CleanupDir = '';

if local_ends_with(FileName, '.nii.gz')
    CleanupDir = tempname;
    mkdir(CleanupDir);
    GunzipOutput = gunzip(FileName, CleanupDir);
    if isempty(GunzipOutput)
        error('Unable to gunzip file for header read: %s', FileName);
    end
    ReadableFile = GunzipOutput{1};
end
end


function local_cleanup_temp_dir(CleanupDir)
if ~isempty(CleanupDir) && exist(CleanupDir, 'dir')
    try
        rmdir(CleanupDir, 's');
    catch
    end
end
end


function IntermediateMGHFile = local_build_surface_intermediate_mgh_file(OutFile)
[OutDir, OutName, OutExt] = fileparts(OutFile);
if strcmpi(OutExt, '.gii') && local_ends_with(OutName, '.func')
    OutName = OutName(1:end-length('.func'));
end
IntermediateMGHFile = fullfile(OutDir, [OutName '.func.mgh']);
end


function RowCount = local_count_tsv_data_rows(FileName)
RowCount = nan;
fid = fopen(FileName, 'r');
if fid < 0
    return;
end

CleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>
HeaderLine = fgetl(fid);
if ~ischar(HeaderLine)
    RowCount = 0;
    return;
end

RowCount = 0;
while true
    ThisLine = fgetl(fid);
    if ~ischar(ThisLine)
        break;
    end
    if ~isempty(strtrim(ThisLine))
        RowCount = RowCount + 1;
    end
end
end


function CommandBody = local_build_vol2surf_command_body(WorkingDirInContainer, Cfg, InFile, SubjectID, Hemi, TargetSubject, OutFile)
IntermediateMGHFile = local_build_surface_intermediate_mgh_file(OutFile);
SubjectsDirInContainer = local_map_to_container_path(Cfg.SurfaceSubjectsDir, Cfg.WorkingDir, WorkingDirInContainer);

CommandBody = sprintf(['mri_vol2surf --src %s --out %s --regheader %s --hemi %s ' ...
    '--surf white --projfrac %.6f --sd %s --noreshape'], ...
    local_shellquote(local_map_to_container_path(InFile, Cfg.WorkingDir, WorkingDirInContainer)), ...
    local_shellquote(local_map_to_container_path(IntermediateMGHFile, Cfg.WorkingDir, WorkingDirInContainer)), ...
    local_shellquote(SubjectID), ...
    Hemi, ...
    Cfg.MultiEcho.SurfaceProjectionFraction, ...
    local_shellquote(SubjectsDirInContainer));

if ~isempty(TargetSubject)
    CommandBody = sprintf('%s --trgsubject %s', CommandBody, local_shellquote(TargetSubject));
end

CommandBody = sprintf('%s\nmri_convert %s %s', CommandBody, ...
    local_shellquote(local_map_to_container_path(IntermediateMGHFile, Cfg.WorkingDir, WorkingDirInContainer)), ...
    local_shellquote(local_map_to_container_path(OutFile, Cfg.WorkingDir, WorkingDirInContainer)));
end


function JobList = local_execute_jobs_with_parallel(JobList, Cfg, CommandInit, WorkingDirInContainer)
JobList = local_execute_jobs_with_parallel_pass(JobList, Cfg, CommandInit, WorkingDirInContainer, 'initial');

FailedIndex = local_failed_job_indices(JobList);
if Cfg.MultiEcho.RetryFailedJobsOnce && ~isempty(FailedIndex)
    fprintf('\nInitial tedana pipeline pass left %d failed run/session job(s).\n', numel(FailedIndex));
    local_print_failed_jobs(JobList, FailedIndex);
    fprintf('\nAutomatically retry failed or incomplete jobs once. Completed stages will be skipped.\n');
    JobList = local_execute_jobs_with_parallel_pass(JobList, Cfg, CommandInit, WorkingDirInContainer, 'retry');
end

FailedIndex = local_failed_job_indices(JobList);
if isempty(FailedIndex)
    fprintf('\nVerified completion: all %d tedana run/session job(s) completed successfully.\n', numel(JobList));
else
    fprintf('\nVerified completion: %d of %d tedana run/session job(s) remain incomplete.\n', ...
        numel(FailedIndex), numel(JobList));
    local_print_failed_jobs(JobList, FailedIndex);
end
end


function JobList = local_execute_jobs_with_parallel_pass(JobList, Cfg, CommandInit, WorkingDirInContainer, PassLabel)
fprintf('\n========== Tedana pipeline %s pass ==========\n', PassLabel);
fprintf('Run tedana with docker parallel -j %d...\n', Cfg.TedanaParallelWorkersNumber);
[JobList, TedanaBatchStatus, TedanaBatchOutput] = local_run_tedana_jobs_with_parallel(JobList, Cfg, CommandInit, WorkingDirInContainer);
if TedanaBatchStatus ~= 0
    warning('y_MultiEchoICA_Tedana:TedanaParallelNonZero', ...
        'GNU parallel returned non-zero status during tedana execution.\n%s', TedanaBatchOutput);
end

fprintf('Run T1w transforms with docker parallel -j %d...\n', Cfg.T1wWarpParallelWorkersNumber);
[JobList, T1wWarpBatchStatus, T1wWarpBatchOutput] = local_run_t1w_warp_jobs_with_parallel(JobList, Cfg, CommandInit, WorkingDirInContainer);
if T1wWarpBatchStatus ~= 0
    warning('y_MultiEchoICA_Tedana:T1wWarpParallelNonZero', ...
        'GNU parallel returned non-zero status during T1w warp execution.\n%s', T1wWarpBatchOutput);
end

fprintf('Run surface projections with docker parallel -j %d...\n', Cfg.SurfaceParallelWorkersNumber);
[JobList, SurfaceBatchStatus, SurfaceBatchOutput] = local_run_surface_jobs_with_parallel(JobList, Cfg, CommandInit, WorkingDirInContainer);
if SurfaceBatchStatus ~= 0
    warning('y_MultiEchoICA_Tedana:SurfaceParallelNonZero', ...
        'GNU parallel returned non-zero status during surface execution.\n%s', SurfaceBatchOutput);
end

fprintf('Run target-space transforms with docker parallel -j %d...\n', Cfg.TargetWarpParallelWorkersNumber);
[JobList, WarpBatchStatus, WarpBatchOutput] = local_run_target_warp_jobs_with_parallel(JobList, Cfg, CommandInit, WorkingDirInContainer);
if WarpBatchStatus ~= 0
    warning('y_MultiEchoICA_Tedana:WarpParallelNonZero', ...
        'GNU parallel returned non-zero status during warp execution.\n%s', WarpBatchOutput);
end

for iJob = 1:numel(JobList)
    NeedTargetWarp = local_has_target_warp(JobList(iJob));
    NeedSurface = local_has_surface_any(JobList(iJob));
    CoreOutputsReady = JobList(iJob).TedanaStatus == 0 ...
        && JobList(iJob).T1wWarpStatus == 0 ...
        && (~NeedSurface || JobList(iJob).SurfaceStatus == 0);
    AllOutputsReady = CoreOutputsReady ...
        && (~NeedTargetWarp || JobList(iJob).WarpStatus == 0);

    FinalizeError = '';
    if CoreOutputsReady
        try
            % Copy every successfully completed stage even if an optional
            % target-space warp failed. This keeps valid T1w/surface outputs
            % visible while the failed target warp is retried.
            JobList(iJob) = local_finalize_job(JobList(iJob), Cfg);
        catch ME
            FinalizeError = sprintf('Final output organization failed: %s', ME.message);
        end
    end

    if AllOutputsReady && isempty(FinalizeError)
        JobList(iJob).Success = 1;
        JobList(iJob).ErrorMessage = '';
    else
        JobList(iJob).Success = 0;
        if ~isempty(FinalizeError)
            JobList(iJob).ErrorMessage = FinalizeError;
        elseif isempty(JobList(iJob).ErrorMessage)
            if JobList(iJob).TedanaStatus ~= 0
                JobList(iJob).ErrorMessage = sprintf('tedana failed. See log: %s', JobList(iJob).TedanaLogFile);
            elseif JobList(iJob).T1wWarpStatus ~= 0
                JobList(iJob).ErrorMessage = sprintf('T1w warp failed. See log: %s', JobList(iJob).T1wWarpLogFile);
            elseif NeedSurface && JobList(iJob).SurfaceStatus ~= 0
                JobList(iJob).ErrorMessage = sprintf('Surface generation failed. See log: %s', JobList(iJob).SurfaceLogFile);
            elseif NeedTargetWarp && JobList(iJob).WarpStatus ~= 0
                JobList(iJob).ErrorMessage = sprintf('Warp failed. See log: %s', JobList(iJob).WarpLogFile);
            else
                JobList(iJob).ErrorMessage = 'Unknown job failure.';
            end
        end
    end
end
end


function [JobList, BatchStatus, BatchOutput] = local_run_tedana_jobs_with_parallel(JobList, Cfg, CommandInit, WorkingDirInContainer)
ScriptContainerFiles = {};
JobIndices = [];

ScriptDir = fullfile(Cfg.TedanaDir, 'parallel_jobs', 'tedana');
local_mkdir(ScriptDir);

for iJob = 1:numel(JobList)
    ExistingTedanaDenoised = local_resolve_tedana_denoised_file(JobList(iJob).TedanaOutDir, JobList(iJob).BasePrefix, Cfg.MultiEcho.Convention);
    if ~Cfg.MultiEcho.Overwrite && ~isempty(ExistingTedanaDenoised)
        [ExistingIsValid, ValidationMessage] = local_job_nifti_output_is_valid( ...
            JobList(iJob), 'tedana', ExistingTedanaDenoised, '');
        if ExistingIsValid
            JobList(iJob).TedanaStatus = 0;
            JobList(iJob).TedanaOutput = 'tedana skipped because a verified denoised output already exists.';
            JobList(iJob).TedanaDenoisedFile = ExistingTedanaDenoised;
            JobList(iJob).ErrorMessage = '';
            local_write_stage_marker(JobList(iJob), 'tedana', {ExistingTedanaDenoised});
            continue;
        end
        fprintf('Incomplete tedana output detected for %s: %s\n', JobList(iJob).BasePrefix, ValidationMessage);
        local_backup_incomplete_file(ExistingTedanaDenoised, JobList(iJob), Cfg, 'tedana');
    end

    % A job reaches this point only when no verified final denoised file is
    % available (or full overwrite was explicitly requested). tedana may
    % still have intermediate files from an OOM-killed attempt, so allow
    % this selected job to overwrite those residual files.
    TedanaCommandBody = local_ensure_command_flag(JobList(iJob).TedanaCommandBody, '--overwrite');
    JobList(iJob).TedanaCommandBody = TedanaCommandBody;
    JobList(iJob).TedanaCommand = local_prefix_command(CommandInit, TedanaCommandBody);
    local_remove_stage_marker(JobList(iJob), 'tedana');

    ScriptHostFile = fullfile(ScriptDir, sprintf('tedana_%04d.sh', iJob));
    ScriptContainerFile = local_map_to_container_path(ScriptHostFile, Cfg.WorkingDir, WorkingDirInContainer);
    LogContainerFile = local_map_to_container_path(JobList(iJob).TedanaLogFile, Cfg.WorkingDir, WorkingDirInContainer);
    local_write_parallel_script(ScriptHostFile, TedanaCommandBody, LogContainerFile);

    ScriptContainerFiles{end+1} = ScriptContainerFile; %#ok<AGROW>
    JobIndices(end+1) = iJob; %#ok<AGROW>
end

if isempty(JobIndices)
    BatchStatus = 0;
    BatchOutput = 'No tedana jobs required execution.';
    return;
end

JobLogHostFile = fullfile(ScriptDir, 'parallel_joblog.tsv');
JobLogContainerFile = local_map_to_container_path(JobLogHostFile, Cfg.WorkingDir, WorkingDirInContainer);
ScriptListHostFile = fullfile(ScriptDir, 'script_list.txt');
ScriptListContainerFile = local_map_to_container_path(ScriptListHostFile, Cfg.WorkingDir, WorkingDirInContainer);
local_write_lines(ScriptListHostFile, ScriptContainerFiles);

[BatchStatus, BatchOutput] = local_run_parallel_scripts(CommandInit, Cfg.TedanaParallelWorkersNumber, JobLogContainerFile, ScriptListContainerFile);
ExitStatus = local_read_parallel_joblog(JobLogHostFile, numel(JobIndices));

for i = 1:numel(JobIndices)
    iJob = JobIndices(i);
    JobList(iJob).TedanaStatus = ExitStatus(i);
    JobList(iJob).TedanaOutput = JobList(iJob).TedanaLogFile;
    if JobList(iJob).TedanaStatus == 0
        JobList(iJob).TedanaDenoisedFile = local_resolve_tedana_denoised_file(JobList(iJob).TedanaOutDir, JobList(iJob).BasePrefix, Cfg.MultiEcho.Convention);
        if isempty(JobList(iJob).TedanaDenoisedFile)
            JobList(iJob).TedanaStatus = 1;
            JobList(iJob).ErrorMessage = sprintf('tedana finished but no denoised output was found in %s.', JobList(iJob).TedanaOutDir);
        else
            [OutputIsValid, ValidationMessage] = local_job_nifti_output_is_valid( ...
                JobList(iJob), 'tedana', JobList(iJob).TedanaDenoisedFile, '');
            if OutputIsValid
                local_write_stage_marker(JobList(iJob), 'tedana', {JobList(iJob).TedanaDenoisedFile});
                JobList(iJob).ErrorMessage = '';
            else
                JobList(iJob).TedanaStatus = 1;
                JobList(iJob).ErrorMessage = sprintf('tedana output validation failed: %s', ValidationMessage);
            end
        end
    else
        JobList(iJob).ErrorMessage = sprintf('tedana failed. See log: %s', JobList(iJob).TedanaLogFile);
    end
end
end


function [JobList, BatchStatus, BatchOutput] = local_run_t1w_warp_jobs_with_parallel(JobList, Cfg, CommandInit, WorkingDirInContainer)
ScriptContainerFiles = {};
JobIndices = [];

ScriptDir = fullfile(Cfg.TedanaDir, 'parallel_jobs', 'warp_t1w');
local_mkdir(ScriptDir);

for iJob = 1:numel(JobList)
    if JobList(iJob).TedanaStatus ~= 0
        JobList(iJob).T1wWarpStatus = nan;
        JobList(iJob).T1wWarpOutput = 'T1w warp skipped because tedana failed.';
        continue;
    end

    if ~local_has_t1w_warp(JobList(iJob))
        JobList(iJob).T1wWarpStatus = 1;
        JobList(iJob).T1wWarpOutput = 'T1w warp inputs are incomplete.';
        if isempty(JobList(iJob).ErrorMessage)
            JobList(iJob).ErrorMessage = 'T1w warp inputs are incomplete.';
        end
        continue;
    end

    if isempty(JobList(iJob).TedanaDenoisedFile) || ~exist(JobList(iJob).TedanaDenoisedFile, 'file')
        JobList(iJob).T1wWarpStatus = 1;
        JobList(iJob).T1wWarpOutput = 'T1w warp skipped because the tedana denoised file was not found.';
        if isempty(JobList(iJob).ErrorMessage)
            JobList(iJob).ErrorMessage = 'T1w warp skipped because the tedana denoised file was not found.';
        end
        continue;
    end

    JobList(iJob).T1wWarpCommandBody = local_build_warp_command_body(WorkingDirInContainer, Cfg, ...
        JobList(iJob).TedanaDenoisedFile, JobList(iJob).T1wWarpReferenceFile, ...
        {JobList(iJob).BoldrefToT1wTransformFile}, JobList(iJob).WarpedT1wFile);
    JobList(iJob).T1wWarpCommand = local_prefix_command(CommandInit, JobList(iJob).T1wWarpCommandBody);

    if ~Cfg.MultiEcho.Overwrite && exist(JobList(iJob).WarpedT1wFile, 'file')
        [ExistingIsValid, ValidationMessage] = local_job_nifti_output_is_valid( ...
            JobList(iJob), 'warp_t1w', JobList(iJob).WarpedT1wFile, JobList(iJob).T1wWarpReferenceFile);
        if ExistingIsValid
            JobList(iJob).T1wWarpStatus = 0;
            JobList(iJob).T1wWarpOutput = 'T1w warp skipped because a verified T1w-space denoised output already exists.';
            local_write_stage_marker(JobList(iJob), 'warp_t1w', {JobList(iJob).WarpedT1wFile});
            continue;
        end
        fprintf('Incomplete T1w warp output detected for %s: %s\n', JobList(iJob).BasePrefix, ValidationMessage);
        local_backup_incomplete_file(JobList(iJob).WarpedT1wFile, JobList(iJob), Cfg, 'warp_t1w');
    end

    local_remove_stage_marker(JobList(iJob), 'warp_t1w');

    ScriptHostFile = fullfile(ScriptDir, sprintf('warp_t1w_%04d.sh', iJob));
    ScriptContainerFile = local_map_to_container_path(ScriptHostFile, Cfg.WorkingDir, WorkingDirInContainer);
    LogContainerFile = local_map_to_container_path(JobList(iJob).T1wWarpLogFile, Cfg.WorkingDir, WorkingDirInContainer);
    local_write_parallel_script(ScriptHostFile, JobList(iJob).T1wWarpCommandBody, LogContainerFile);

    ScriptContainerFiles{end+1} = ScriptContainerFile; %#ok<AGROW>
    JobIndices(end+1) = iJob; %#ok<AGROW>
end

if isempty(JobIndices)
    BatchStatus = 0;
    BatchOutput = 'No T1w warp jobs required execution.';
    return;
end

JobLogHostFile = fullfile(ScriptDir, 'parallel_joblog.tsv');
JobLogContainerFile = local_map_to_container_path(JobLogHostFile, Cfg.WorkingDir, WorkingDirInContainer);
ScriptListHostFile = fullfile(ScriptDir, 'script_list.txt');
ScriptListContainerFile = local_map_to_container_path(ScriptListHostFile, Cfg.WorkingDir, WorkingDirInContainer);
local_write_lines(ScriptListHostFile, ScriptContainerFiles);

[BatchStatus, BatchOutput] = local_run_parallel_scripts(CommandInit, Cfg.T1wWarpParallelWorkersNumber, JobLogContainerFile, ScriptListContainerFile);
ExitStatus = local_read_parallel_joblog(JobLogHostFile, numel(JobIndices));

for i = 1:numel(JobIndices)
    iJob = JobIndices(i);
    JobList(iJob).T1wWarpStatus = ExitStatus(i);
    JobList(iJob).T1wWarpOutput = JobList(iJob).T1wWarpLogFile;
    if JobList(iJob).T1wWarpStatus == 0
        [OutputIsValid, ValidationMessage] = local_job_nifti_output_is_valid( ...
            JobList(iJob), 'warp_t1w', JobList(iJob).WarpedT1wFile, JobList(iJob).T1wWarpReferenceFile);
        if ~OutputIsValid
            JobList(iJob).T1wWarpStatus = 1;
            JobList(iJob).ErrorMessage = sprintf('T1w warp output validation failed: %s', ValidationMessage);
        else
            local_write_stage_marker(JobList(iJob), 'warp_t1w', {JobList(iJob).WarpedT1wFile});
            JobList(iJob).ErrorMessage = '';
        end
    else
        JobList(iJob).ErrorMessage = sprintf('T1w warp failed. See log: %s', JobList(iJob).T1wWarpLogFile);
    end
end
end


function [JobList, BatchStatus, BatchOutput] = local_run_surface_jobs_with_parallel(JobList, Cfg, CommandInit, WorkingDirInContainer)
ScriptContainerFiles = {};
JobIndices = [];

ScriptDir = fullfile(Cfg.TedanaDir, 'parallel_jobs', 'surf');
local_mkdir(ScriptDir);

for iJob = 1:numel(JobList)
    if JobList(iJob).TedanaStatus ~= 0
        JobList(iJob).SurfaceStatus = nan;
        JobList(iJob).SurfaceOutput = 'Surface generation skipped because tedana failed.';
        continue;
    end

    if JobList(iJob).T1wWarpStatus ~= 0
        JobList(iJob).SurfaceStatus = nan;
        JobList(iJob).SurfaceOutput = 'Surface generation skipped because T1w warp failed.';
        continue;
    end

    if ~local_has_surface_any(JobList(iJob))
        JobList(iJob).SurfaceStatus = 0;
        JobList(iJob).SurfaceOutput = 'No surface outputs were requested for this job.';
        continue;
    end

    if isempty(JobList(iJob).WarpedT1wFile) || ~exist(JobList(iJob).WarpedT1wFile, 'file')
        JobList(iJob).SurfaceStatus = 1;
        JobList(iJob).SurfaceOutput = 'Surface generation skipped because the T1w-space denoised file was not found.';
        if isempty(JobList(iJob).ErrorMessage)
            JobList(iJob).ErrorMessage = 'Surface generation skipped because the T1w-space denoised file was not found.';
        end
        continue;
    end

    JobList(iJob).SurfaceCommandBody = local_build_surface_command_body(WorkingDirInContainer, Cfg, JobList(iJob));
    JobList(iJob).SurfaceCommand = local_prefix_command(CommandInit, JobList(iJob).SurfaceCommandBody);

    if ~Cfg.MultiEcho.Overwrite
        ExistingSurfaceFiles = local_surface_output_files(JobList(iJob));
        ExistingSurfaceFlags = cellfun(@(x)exist(x, 'file') == 2, ExistingSurfaceFiles);
        if all(ExistingSurfaceFlags)
            [ExistingIsValid, ValidationMessage] = local_surface_outputs_are_valid(JobList(iJob));
            if ExistingIsValid
                JobList(iJob).SurfaceStatus = 0;
                JobList(iJob).SurfaceOutput = 'Surface generation skipped because verified denoised surface outputs already exist.';
                local_write_stage_marker(JobList(iJob), 'surface', ExistingSurfaceFiles);
                continue;
            end
            fprintf('Incomplete surface output detected for %s: %s\n', JobList(iJob).BasePrefix, ValidationMessage);
            local_backup_incomplete_surface_outputs(JobList(iJob), Cfg);
        elseif any(ExistingSurfaceFlags)
            fprintf('Partial surface output set detected for %s. Back up existing files before retry.\n', JobList(iJob).BasePrefix);
            local_backup_incomplete_surface_outputs(JobList(iJob), Cfg);
        end
    end

    local_remove_stage_marker(JobList(iJob), 'surface');

    ScriptHostFile = fullfile(ScriptDir, sprintf('surf_%04d.sh', iJob));
    ScriptContainerFile = local_map_to_container_path(ScriptHostFile, Cfg.WorkingDir, WorkingDirInContainer);
    LogContainerFile = local_map_to_container_path(JobList(iJob).SurfaceLogFile, Cfg.WorkingDir, WorkingDirInContainer);
    local_write_parallel_script(ScriptHostFile, JobList(iJob).SurfaceCommandBody, LogContainerFile);

    ScriptContainerFiles{end+1} = ScriptContainerFile; %#ok<AGROW>
    JobIndices(end+1) = iJob; %#ok<AGROW>
end

if isempty(JobIndices)
    BatchStatus = 0;
    BatchOutput = 'No surface jobs required execution.';
    return;
end

JobLogHostFile = fullfile(ScriptDir, 'parallel_joblog.tsv');
JobLogContainerFile = local_map_to_container_path(JobLogHostFile, Cfg.WorkingDir, WorkingDirInContainer);
ScriptListHostFile = fullfile(ScriptDir, 'script_list.txt');
ScriptListContainerFile = local_map_to_container_path(ScriptListHostFile, Cfg.WorkingDir, WorkingDirInContainer);
local_write_lines(ScriptListHostFile, ScriptContainerFiles);

[BatchStatus, BatchOutput] = local_run_parallel_scripts(CommandInit, Cfg.SurfaceParallelWorkersNumber, JobLogContainerFile, ScriptListContainerFile);
ExitStatus = local_read_parallel_joblog(JobLogHostFile, numel(JobIndices));

for i = 1:numel(JobIndices)
    iJob = JobIndices(i);
    JobList(iJob).SurfaceStatus = ExitStatus(i);
    JobList(iJob).SurfaceOutput = JobList(iJob).SurfaceLogFile;
    if JobList(iJob).SurfaceStatus == 0
        [OutputIsValid, ValidationMessage] = local_surface_outputs_are_valid(JobList(iJob));
        if ~OutputIsValid
            JobList(iJob).SurfaceStatus = 1;
            JobList(iJob).ErrorMessage = sprintf('Surface output validation failed for %s: %s', ...
                JobList(iJob).BasePrefix, ValidationMessage);
        else
            local_write_stage_marker(JobList(iJob), 'surface', local_surface_output_files(JobList(iJob)));
            JobList(iJob).ErrorMessage = '';
        end
    else
        JobList(iJob).ErrorMessage = sprintf('Surface generation failed. See log: %s', JobList(iJob).SurfaceLogFile);
    end
end
end


function [JobList, BatchStatus, BatchOutput] = local_run_target_warp_jobs_with_parallel(JobList, Cfg, CommandInit, WorkingDirInContainer)
ScriptContainerFiles = {};
JobIndices = [];

ScriptDir = fullfile(Cfg.TedanaDir, 'parallel_jobs', 'warp_target');
local_mkdir(ScriptDir);

for iJob = 1:numel(JobList)
    if JobList(iJob).TedanaStatus ~= 0
        JobList(iJob).WarpStatus = nan;
        JobList(iJob).WarpOutput = 'Warp skipped because tedana failed.';
        continue;
    end

    if JobList(iJob).T1wWarpStatus ~= 0
        JobList(iJob).WarpStatus = nan;
        JobList(iJob).WarpOutput = 'Target-space warp skipped because T1w warp failed.';
        continue;
    end

    if ~local_has_target_warp(JobList(iJob))
        JobList(iJob).WarpStatus = 0;
        JobList(iJob).WarpOutput = 'No target-space warp was requested for this job.';
        continue;
    end

    if isempty(JobList(iJob).TedanaDenoisedFile) || ~exist(JobList(iJob).TedanaDenoisedFile, 'file')
        JobList(iJob).WarpStatus = 1;
        JobList(iJob).WarpOutput = 'Warp skipped because the tedana denoised file was not found.';
        if isempty(JobList(iJob).ErrorMessage)
            JobList(iJob).ErrorMessage = 'Warp skipped because the tedana denoised file was not found.';
        end
        continue;
    end

    JobList(iJob).WarpCommandBody = local_build_warp_command_body(WorkingDirInContainer, Cfg, ...
        JobList(iJob).TedanaDenoisedFile, JobList(iJob).TargetWarpReferenceFile, ...
        {JobList(iJob).TransformFile, JobList(iJob).BoldrefToT1wTransformFile}, JobList(iJob).WarpedTargetFile);
    JobList(iJob).WarpCommand = local_prefix_command(CommandInit, JobList(iJob).WarpCommandBody);

    if ~Cfg.MultiEcho.Overwrite && exist(JobList(iJob).WarpedTargetFile, 'file')
        [ExistingIsValid, ValidationMessage] = local_job_nifti_output_is_valid( ...
            JobList(iJob), 'warp_target', JobList(iJob).WarpedTargetFile, JobList(iJob).TargetWarpReferenceFile);
        if ExistingIsValid
            JobList(iJob).WarpStatus = 0;
            JobList(iJob).WarpOutput = 'Warp skipped because a verified target-space denoised output already exists.';
            local_write_stage_marker(JobList(iJob), 'warp_target', {JobList(iJob).WarpedTargetFile});
            continue;
        end
        fprintf('Incomplete target-space warp output detected for %s: %s\n', JobList(iJob).BasePrefix, ValidationMessage);
        local_backup_incomplete_file(JobList(iJob).WarpedTargetFile, JobList(iJob), Cfg, 'warp_target');
    end

    local_remove_stage_marker(JobList(iJob), 'warp_target');

    ScriptHostFile = fullfile(ScriptDir, sprintf('warp_%04d.sh', iJob));
    ScriptContainerFile = local_map_to_container_path(ScriptHostFile, Cfg.WorkingDir, WorkingDirInContainer);
    LogContainerFile = local_map_to_container_path(JobList(iJob).WarpLogFile, Cfg.WorkingDir, WorkingDirInContainer);
    local_write_parallel_script(ScriptHostFile, JobList(iJob).WarpCommandBody, LogContainerFile);

    ScriptContainerFiles{end+1} = ScriptContainerFile; %#ok<AGROW>
    JobIndices(end+1) = iJob; %#ok<AGROW>
end

if isempty(JobIndices)
    BatchStatus = 0;
    BatchOutput = 'No warp jobs required execution.';
    return;
end

JobLogHostFile = fullfile(ScriptDir, 'parallel_joblog.tsv');
JobLogContainerFile = local_map_to_container_path(JobLogHostFile, Cfg.WorkingDir, WorkingDirInContainer);
ScriptListHostFile = fullfile(ScriptDir, 'script_list.txt');
ScriptListContainerFile = local_map_to_container_path(ScriptListHostFile, Cfg.WorkingDir, WorkingDirInContainer);
local_write_lines(ScriptListHostFile, ScriptContainerFiles);

[BatchStatus, BatchOutput] = local_run_parallel_scripts(CommandInit, Cfg.TargetWarpParallelWorkersNumber, JobLogContainerFile, ScriptListContainerFile);
ExitStatus = local_read_parallel_joblog(JobLogHostFile, numel(JobIndices));

for i = 1:numel(JobIndices)
    iJob = JobIndices(i);
    JobList(iJob).WarpStatus = ExitStatus(i);
    JobList(iJob).WarpOutput = JobList(iJob).WarpLogFile;
    if JobList(iJob).WarpStatus == 0
        [OutputIsValid, ValidationMessage] = local_job_nifti_output_is_valid( ...
            JobList(iJob), 'warp_target', JobList(iJob).WarpedTargetFile, JobList(iJob).TargetWarpReferenceFile);
        if ~OutputIsValid
            JobList(iJob).WarpStatus = 1;
            JobList(iJob).ErrorMessage = sprintf('Target-space warp output validation failed: %s', ValidationMessage);
        else
            local_write_stage_marker(JobList(iJob), 'warp_target', {JobList(iJob).WarpedTargetFile});
            JobList(iJob).ErrorMessage = '';
        end
    else
        JobList(iJob).ErrorMessage = sprintf('Warp failed. See log: %s', JobList(iJob).WarpLogFile);
    end
end
end


function [BatchStatus, BatchOutput] = local_run_parallel_scripts(CommandInit, ParallelWorkersNumber, JobLogContainerFile, ScriptListContainerFile)
Command = sprintf('%s parallel -j %g --joblog %s bash {1} :::: %s', ...
    CommandInit, ParallelWorkersNumber, local_shellquote(JobLogContainerFile), local_shellquote(ScriptListContainerFile));
[BatchStatus, BatchOutput] = system(Command);
end


function local_write_parallel_script(ScriptHostFile, CommandBody, LogContainerFile)
[ScriptDir, ~, ~] = fileparts(ScriptHostFile);
local_mkdir(ScriptDir);

fid = fopen(ScriptHostFile, 'w');
if fid < 0
    error('Unable to create parallel job script: %s', ScriptHostFile);
end
fprintf(fid, '#!/bin/bash\n');
fprintf(fid, 'set -e\n');
fprintf(fid, 'exec > %s 2>&1\n', local_shellquote(LogContainerFile));
fprintf(fid, '%s\n', CommandBody);
fclose(fid);
end


function local_write_lines(FileName, Lines)
fid = fopen(FileName, 'w');
if fid < 0
    error('Unable to create file: %s', FileName);
end
for i = 1:numel(Lines)
    fprintf(fid, '%s\n', Lines{i});
end
fclose(fid);
end


function ExitStatus = local_read_parallel_joblog(JobLogHostFile, ExpectedRows)
ExitStatus = ones(ExpectedRows,1);

if ~exist(JobLogHostFile, 'file')
    return;
end

fid = fopen(JobLogHostFile);
if fid < 0
    return;
end

fgetl(fid); % header
Data = textscan(fid,'%f%s%s%f%f%f%f%f%[^\n]','Delimiter','\t');
fclose(fid);

if isempty(Data) || isempty(Data{1})
    return;
end

Seq = Data{1};
ExitVal = Data{7};
for i = 1:min(numel(Seq), numel(ExitVal))
    Index = Seq(i);
    if Index >= 1 && Index <= ExpectedRows
        ExitStatus(Index) = ExitVal(i);
    end
end
end


function FailedIndex = local_failed_job_indices(JobList)
FailedIndex = [];
for iJob = 1:numel(JobList)
    if ~isfield(JobList(iJob), 'Success') || isempty(JobList(iJob).Success) ...
            || ~isequal(JobList(iJob).Success, 1)
        FailedIndex(end+1) = iJob; %#ok<AGROW>
    end
end
end


function local_print_failed_jobs(JobList, FailedIndex)
for i = 1:numel(FailedIndex)
    iJob = FailedIndex(i);
    fprintf('  %3d) %s | session %d | %s\n', iJob, ...
        JobList(iJob).SubjectID, JobList(iJob).SessionIndex, JobList(iJob).ErrorMessage);
end
end


function local_write_failed_jobs_report(JobList, Cfg)
ReportFile = fullfile(Cfg.TedanaDir, 'tedana_failed_jobs.tsv');
fid = fopen(ReportFile, 'w');
if fid < 0
    warning('Unable to write failed-job report: %s', ReportFile);
    return;
end
CleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid, 'JobIndex\tSubjectID\tSessionIndex\tBasePrefix\tTedanaStatus\tT1wWarpStatus\tSurfaceStatus\tTargetWarpStatus\tSuccess\tErrorMessage\n');
for iJob = 1:numel(JobList)
    if JobList(iJob).Success == 1
        continue;
    end
    ErrorMessage = regexprep(JobList(iJob).ErrorMessage, '[\t\r\n]+', ' ');
    fprintf(fid, '%d\t%s\t%d\t%s\t%s\t%s\t%s\t%s\t%d\t%s\n', ...
        iJob, JobList(iJob).SubjectID, JobList(iJob).SessionIndex, JobList(iJob).BasePrefix, ...
        local_status_to_text(JobList(iJob).TedanaStatus), ...
        local_status_to_text(JobList(iJob).T1wWarpStatus), ...
        local_status_to_text(JobList(iJob).SurfaceStatus), ...
        local_status_to_text(JobList(iJob).WarpStatus), ...
        JobList(iJob).Success, ErrorMessage);
end
end


function Txt = local_status_to_text(Status)
if isempty(Status) || ~isscalar(Status) || isnan(Status)
    Txt = 'NaN';
else
    Txt = num2str(Status);
end
end


function Job = local_execute_job(Job, Cfg)
% Keep a single-job wrapper for compatibility, but route execution through
% the same GNU parallel pipeline used by the main multi-job path.
[CommandInit, WorkingDirInContainer] = local_prepare_command_init(Cfg);
JobList = local_execute_jobs_with_parallel(Job, Cfg, CommandInit, WorkingDirInContainer);
Job = JobList(1);
end


function Job = local_finalize_job(Job, Cfg)
local_mkdir(Job.TargetT1wDir);
local_mkdir(Job.TargetMaskDir);
if local_has_target_warp(Job)
    local_mkdir(Job.TargetSpaceDir);
end
if local_has_surface_native(Job)
    local_mkdir(Job.TargetFunSurfDir);
end
if local_has_surface_standard(Job)
    local_mkdir(Job.TargetFunSurfWDir);
end

local_stage_existing_prefix_files(Job.TargetT1wDir, Job.BasePrefix, Job.TargetT1wFile, fullfile(Cfg.TedanaDir,'Backup',Job.SessionPrefix,'FunVolu',Job.SubjectID));
local_copy_with_overwrite(Job.WarpedT1wFile, Job.TargetT1wFile, Cfg.MultiEcho.Overwrite);

if local_has_target_warp(Job) && Job.WarpStatus == 0 && exist(Job.WarpedTargetFile, 'file')
    local_stage_existing_prefix_files(Job.TargetSpaceDir, Job.BasePrefix, Job.TargetSpaceFile, fullfile(Cfg.TedanaDir,'Backup',Job.SessionPrefix,'FunVoluW',Job.SubjectID));
    local_copy_with_overwrite(Job.WarpedTargetFile, Job.TargetSpaceFile, Cfg.MultiEcho.Overwrite);
end

if ~isempty(Job.T1wMaskFile) && exist(Job.T1wMaskFile, 'file')
    local_copy_with_overwrite(Job.T1wMaskFile, Job.TargetNativeMaskFile, Cfg.MultiEcho.Overwrite);
end
if local_has_target_warp(Job) && Job.WarpStatus == 0 && ~isempty(Job.TargetMaskFile) && exist(Job.TargetMaskFile, 'file')
    local_copy_with_overwrite(Job.TargetMaskFile, Job.TargetSpaceMaskFile, Cfg.MultiEcho.Overwrite);
end
if local_has_surface_native(Job)
    local_stage_existing_prefix_files_multi(Job.TargetFunSurfDir, Job.BasePrefix, ...
        {Job.TargetFunSurfLeftFile, Job.TargetFunSurfRightFile}, ...
        fullfile(Cfg.TedanaDir,'Backup',Job.SessionPrefix,'FunSurf',Job.SubjectID));
    local_copy_with_overwrite(Job.SurfaceNativeLeftFile, Job.TargetFunSurfLeftFile, Cfg.MultiEcho.Overwrite);
    local_copy_with_overwrite(Job.SurfaceNativeRightFile, Job.TargetFunSurfRightFile, Cfg.MultiEcho.Overwrite);
end
if local_has_surface_standard(Job)
    local_stage_existing_prefix_files_multi(Job.TargetFunSurfWDir, Job.BasePrefix, ...
        {Job.TargetFunSurfWLeftFile, Job.TargetFunSurfWRightFile}, ...
        fullfile(Cfg.TedanaDir,'Backup',Job.SessionPrefix,'FunSurfW',Job.SubjectID));
    local_copy_with_overwrite(Job.SurfaceStandardLeftFile, Job.TargetFunSurfWLeftFile, Cfg.MultiEcho.Overwrite);
    local_copy_with_overwrite(Job.SurfaceStandardRightFile, Job.TargetFunSurfWRightFile, Cfg.MultiEcho.Overwrite);
end

end


function tf = local_has_t1w_warp(Job)
tf = ~isempty(Job.T1wReferenceFile) ...
    && ~isempty(Job.T1wWarpReferenceFile) ...
    && ~isempty(Job.BoldrefToT1wTransformFile);
end


function tf = local_has_target_warp(Job)
tf = ~isempty(Job.TargetReferenceFile) ...
    && ~isempty(Job.TargetWarpReferenceFile) ...
    && ~isempty(Job.TransformFile) ...
    && ~isempty(Job.BoldrefToT1wTransformFile);
end


function tf = local_has_surface_native(Job)
tf = ~isempty(Job.SurfaceNativeLeftTemplateFile) ...
    && ~isempty(Job.SurfaceNativeRightTemplateFile) ...
    && ~isempty(Job.SurfaceNativeLeftFile) ...
    && ~isempty(Job.SurfaceNativeRightFile);
end


function tf = local_has_surface_standard(Job)
tf = local_has_surface_native(Job) ...
    && ~isempty(Job.SurfaceStandardLeftTemplateFile) ...
    && ~isempty(Job.SurfaceStandardRightTemplateFile) ...
    && ~isempty(Job.SurfaceStandardLeftFile) ...
    && ~isempty(Job.SurfaceStandardRightFile);
end


function tf = local_has_surface_any(Job)
tf = local_has_surface_native(Job) || local_has_surface_standard(Job);
end


function Files = local_surface_output_files(Job)
Files = {};
if local_has_surface_native(Job)
    Files = [Files, {Job.SurfaceNativeLeftFile, Job.SurfaceNativeRightFile}]; %#ok<AGROW>
end
if local_has_surface_standard(Job)
    Files = [Files, {Job.SurfaceStandardLeftFile, Job.SurfaceStandardRightFile}]; %#ok<AGROW>
end
Files = Files(~cellfun('isempty', Files));
end


function [tf, Message] = local_surface_outputs_are_valid(Job)
Files = local_surface_output_files(Job);
if isempty(Files)
    tf = true;
    Message = '';
    return;
end

if local_stage_marker_is_current(Job, 'surface', Files)
    tf = true;
    Message = '';
    return;
end

tf = true;
Message = '';
for iFile = 1:numel(Files)
    [ThisValid, ThisMessage] = local_surface_file_is_complete(Files{iFile});
    if ~ThisValid
        tf = false;
        Message = ThisMessage;
        return;
    end
end
end


function [tf, Message] = local_surface_file_is_complete(FileName)
tf = false;
Message = '';
if isempty(FileName) || exist(FileName, 'file') ~= 2
    Message = sprintf('surface file is missing: %s', FileName);
    return;
end

Info = dir(FileName);
if isempty(Info) || Info(1).bytes <= 0
    Message = sprintf('surface file is empty: %s', FileName);
    return;
end

if local_ends_with(lower(FileName), '.gii')
    fid = fopen(FileName, 'r');
    if fid < 0
        Message = sprintf('surface file cannot be opened: %s', FileName);
        return;
    end
    CleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>
    TailBytes = min(double(Info(1).bytes), 8192);
    fseek(fid, -TailBytes, 'eof');
    TailText = char(fread(fid, TailBytes, '*char')');
    if isempty(strfind(TailText, '</GIFTI>')) %#ok<STREMP>
        Message = sprintf('surface GIFTI file appears truncated: %s', FileName);
        return;
    end
end

tf = true;
end


function local_backup_incomplete_surface_outputs(Job, Cfg)
Files = local_surface_output_files(Job);
for iFile = 1:numel(Files)
    if exist(Files{iFile}, 'file') == 2
        local_backup_incomplete_file(Files{iFile}, Job, Cfg, 'surface');
    end
end
end


function local_ensure_surface_subjects(JobList, Cfg, CommandInit, WorkingDirInContainer)
if isempty(JobList) || ~Cfg.MultiEcho.GenerateSurfaceResults
    return;
end

NeedSurfaceTarget = false;
for iJob = 1:numel(JobList)
    if local_has_surface_standard(JobList(iJob))
        NeedSurfaceTarget = true;
        break;
    end
end

if ~NeedSurfaceTarget
    return;
end

FsaverageDir = fullfile(Cfg.SurfaceSubjectsDir, Cfg.MultiEcho.SurfaceTargetSpace);
if exist(FsaverageDir, 'dir')
    return;
end

local_mkdir(Cfg.SurfaceSubjectsDir);
fprintf('Copy %s into %s for surface mapping...\n', Cfg.MultiEcho.SurfaceTargetSpace, Cfg.SurfaceSubjectsDir);
if isempty(CommandInit)
    Command = sprintf('cp -rf /opt/freesurfer/subjects/%s %s', ...
        Cfg.MultiEcho.SurfaceTargetSpace, local_shellquote(Cfg.SurfaceSubjectsDir));
else
    Command = sprintf('%s cp -rf /opt/freesurfer/subjects/%s %s', ...
        CommandInit, Cfg.MultiEcho.SurfaceTargetSpace, ...
        local_shellquote(local_map_to_container_path(Cfg.SurfaceSubjectsDir, Cfg.WorkingDir, WorkingDirInContainer)));
end
Status = system(Command);
if Status ~= 0
    warning('Unable to copy %s into %s. Surface mapping may fail.', Cfg.MultiEcho.SurfaceTargetSpace, Cfg.SurfaceSubjectsDir);
end
end


function WorkerNumber = local_normalize_worker_number(WorkerNumber)
if ischar(WorkerNumber) || isa(WorkerNumber, 'string')
    WorkerNumber = str2double(WorkerNumber);
end

if isempty(WorkerNumber) || ~isfinite(WorkerNumber) || WorkerNumber < 1
    WorkerNumber = 1;
else
    WorkerNumber = max(1, round(double(WorkerNumber)));
end
end


function WorkerNumber = local_cap_worker_number(WorkerNumber, MaximumWorkerNumber)
if ischar(MaximumWorkerNumber) || isa(MaximumWorkerNumber, 'string')
    MaximumWorkerNumber = str2double(MaximumWorkerNumber);
end
if isempty(MaximumWorkerNumber) || ~isfinite(MaximumWorkerNumber) || MaximumWorkerNumber < 1
    return;
end
WorkerNumber = min(WorkerNumber, max(1, round(double(MaximumWorkerNumber))));
end


function FileName = local_find_preferred_file(SearchDir, Patterns)
FileName = '';
if isempty(SearchDir) || ~exist(SearchDir, 'dir')
    return;
end
if ischar(Patterns) || isa(Patterns, 'string')
    Patterns = {char(Patterns)};
end

for iPattern = 1:numel(Patterns)
    DirList = dir(fullfile(SearchDir, Patterns{iPattern}));
    DirList = DirList(~[DirList.isdir]);
    if ~isempty(DirList)
        [~, SortIndex] = sort({DirList.name});
        DirList = DirList(SortIndex);
        FileName = fullfile(DirList(1).folder, DirList(1).name);
        return;
    end
end
end


function OutputFile = local_build_output_from_reference(ReferenceFile, OutputDir, FallbackName)
if isempty(ReferenceFile)
    OutputFile = fullfile(OutputDir, FallbackName);
    return;
end

[~, Name, Ext] = fileparts(ReferenceFile);
ReferenceName = [Name, Ext];

if local_ends_with(ReferenceName, '_desc-preproc_bold.nii.gz')
    OutputName = [ReferenceName(1:end-length('_desc-preproc_bold.nii.gz')), '_desc-denoised_bold.nii.gz'];
elseif local_ends_with(ReferenceName, '_desc-preproc_bold.nii')
    OutputName = [ReferenceName(1:end-length('_desc-preproc_bold.nii')), '_desc-denoised_bold.nii'];
else
    OutputName = FallbackName;
end

OutputFile = fullfile(OutputDir, OutputName);
end


function OutputFile = local_build_surface_output_from_reference(ReferenceFile, OutputDir, FallbackName)
if isempty(ReferenceFile)
    OutputFile = fullfile(OutputDir, FallbackName);
    return;
end

[~, Name, Ext] = fileparts(ReferenceFile);
ReferenceName = [Name, Ext];

if local_ends_with(ReferenceName, '_bold.func.gii')
    OutputName = [ReferenceName(1:end-length('_bold.func.gii')), '_desc-denoised_bold.func.gii'];
else
    OutputName = FallbackName;
end

OutputFile = fullfile(OutputDir, OutputName);
end


function TargetFile = local_build_target_copy_file(SourceReferenceFile, TargetDir, FallbackName)
if isempty(SourceReferenceFile)
    TargetFile = fullfile(TargetDir, FallbackName);
    return;
end

[~, Name, Ext] = fileparts(SourceReferenceFile);
TargetFile = fullfile(TargetDir, [Name, Ext]);
end


function local_copy_with_overwrite(SourceFile, DestinationFile, Overwrite)
if isempty(SourceFile) || ~exist(SourceFile, 'file')
    return;
end

[DestParent, ~, ~] = fileparts(DestinationFile);
local_mkdir(DestParent);

if exist(DestinationFile, 'file')
    if Overwrite
        delete(DestinationFile);
    else
        SourceInfo = dir(SourceFile);
        DestinationInfo = dir(DestinationFile);
        if ~isempty(SourceInfo) && ~isempty(DestinationInfo) ...
                && SourceInfo(1).bytes == DestinationInfo(1).bytes
            return;
        end

        % The expected destination exists but does not match the verified
        % source. Preserve it as an incomplete/older file, then repair the
        % canonical destination even when global overwrite is disabled.
        [DestinationDir, DestinationName, DestinationExt] = fileparts(DestinationFile);
        Stamp = datestr(now, 'yyyymmdd_HHMMSS');
        StagedFile = fullfile(DestinationDir, ...
            sprintf('%s.incomplete_%s%s', DestinationName, Stamp, DestinationExt));
        Counter = 1;
        while exist(StagedFile, 'file') == 2
            StagedFile = fullfile(DestinationDir, ...
                sprintf('%s.incomplete_%s_%02d%s', DestinationName, Stamp, Counter, DestinationExt));
            Counter = Counter + 1;
        end
        [IsMoved, MoveMessage] = movefile(DestinationFile, StagedFile);
        if ~IsMoved
            error('Failed to stage mismatched destination %s: %s', DestinationFile, MoveMessage);
        end
        fprintf('Staged mismatched destination before repair: %s -> %s\n', DestinationFile, StagedFile);
    end
end

[IsSuccess, Msg, ~] = copyfile(SourceFile, DestinationFile);
if ~IsSuccess
    error('Failed to copy %s to %s\n%s', SourceFile, DestinationFile, Msg);
end
end


function local_stage_existing_prefix_files(TargetDir, Prefix, KeepFile, BackupDir)
if ~exist(TargetDir, 'dir')
    return;
end

DirList = dir(fullfile(TargetDir, [Prefix '*']));
DirList = DirList(~[DirList.isdir]);
if isempty(DirList)
    return;
end

local_mkdir(BackupDir);
KeepName = '';
if ~isempty(KeepFile)
    [~, KeepName, KeepExt] = fileparts(KeepFile);
    KeepName = [KeepName, KeepExt];
end

for iFile = 1:numel(DirList)
    if strcmp(DirList(iFile).name, KeepName)
        continue;
    end

    SourceFile = fullfile(DirList(iFile).folder, DirList(iFile).name);
    BackupFile = fullfile(BackupDir, DirList(iFile).name);
    if exist(BackupFile, 'file')
        delete(BackupFile);
    end
    movefile(SourceFile, BackupFile);
end
end


function local_stage_existing_prefix_files_multi(TargetDir, Prefix, KeepFiles, BackupDir)
if ~exist(TargetDir, 'dir')
    return;
end

DirList = dir(fullfile(TargetDir, [Prefix '*']));
DirList = DirList(~[DirList.isdir]);
if isempty(DirList)
    return;
end

KeepNames = {};
for iKeep = 1:numel(KeepFiles)
    if isempty(KeepFiles{iKeep})
        continue;
    end
    [~, KeepName, KeepExt] = fileparts(KeepFiles{iKeep});
    KeepNames{end+1} = [KeepName, KeepExt]; %#ok<AGROW>
end

local_mkdir(BackupDir);
for iFile = 1:numel(DirList)
    if any(strcmp(DirList(iFile).name, KeepNames))
        continue;
    end

    SourceFile = fullfile(DirList(iFile).folder, DirList(iFile).name);
    BackupFile = fullfile(BackupDir, DirList(iFile).name);
    if exist(BackupFile, 'file')
        delete(BackupFile);
    end
    movefile(SourceFile, BackupFile);
end
end


function local_mkdir(DirName)
if ~exist(DirName, 'dir')
    mkdir(DirName);
end
end


function [tf, Message] = local_job_nifti_output_is_valid(Job, StageName, FileName, ReferenceFile)
Message = '';
if local_stage_marker_is_current(Job, StageName, {FileName})
    tf = true;
    return;
end

ExpectedTimePointNumber = nan;
if isfield(Job, 'EstimatedTedanaTimePointNumber') ...
        && isfinite(Job.EstimatedTedanaTimePointNumber) ...
        && Job.EstimatedTedanaTimePointNumber > 0
    ExpectedTimePointNumber = double(Job.EstimatedTedanaTimePointNumber);
end

[tf, Message] = local_nifti_file_is_complete(FileName, ReferenceFile, ExpectedTimePointNumber);
end


function [tf, Message] = local_nifti_file_is_complete(FileName, ReferenceFile, ExpectedTimePointNumber)
tf = false;
Message = '';
if isempty(FileName) || exist(FileName, 'file') ~= 2
    Message = sprintf('NIfTI output is missing: %s', FileName);
    return;
end

Info = dir(FileName);
if isempty(Info) || Info(1).bytes < 348
    Message = sprintf('NIfTI output is empty or too small: %s', FileName);
    return;
end

if local_ends_with(lower(FileName), '.gz')
    [GzipStatus, GzipOutput] = system(sprintf('gzip -t %s 2>&1', local_shellquote(FileName)));
    if GzipStatus ~= 0
        Message = sprintf('gzip integrity check failed for %s: %s', FileName, strtrim(GzipOutput));
        return;
    end
end

[VolumeSize, TimePointNumber] = local_read_nifti_size(FileName);
if isempty(VolumeSize)
    Message = sprintf('NIfTI header cannot be read: %s', FileName);
    return;
end

if ~isempty(ReferenceFile)
    [ReferenceVolumeSize, ~] = local_read_nifti_size(ReferenceFile);
    if isempty(ReferenceVolumeSize)
        Message = sprintf('reference NIfTI header cannot be read: %s', ReferenceFile);
        return;
    end
    if ~isequal(double(VolumeSize(:)'), double(ReferenceVolumeSize(:)'))
        Message = sprintf('spatial dimensions do not match reference for %s', FileName);
        return;
    end
end

if isfinite(ExpectedTimePointNumber) && ExpectedTimePointNumber > 0 ...
        && (~isfinite(TimePointNumber) || TimePointNumber ~= ExpectedTimePointNumber)
    Message = sprintf('time point count is %g, expected %g: %s', ...
        TimePointNumber, ExpectedTimePointNumber, FileName);
    return;
end

tf = true;
end


function MarkerFile = local_stage_marker_file(Job, StageName)
MarkerFile = fullfile(Job.TedanaOutDir, sprintf('.dpabi_%s_complete', StageName));
end


function tf = local_stage_marker_is_current(Job, StageName, OutputFiles)
tf = false;
MarkerFile = local_stage_marker_file(Job, StageName);
if exist(MarkerFile, 'file') ~= 2 || isempty(OutputFiles)
    return;
end

MarkerInfo = dir(MarkerFile);
if isempty(MarkerInfo)
    return;
end
MarkerDate = MarkerInfo(1).datenum;

for iFile = 1:numel(OutputFiles)
    if isempty(OutputFiles{iFile}) || exist(OutputFiles{iFile}, 'file') ~= 2
        return;
    end
    OutputInfo = dir(OutputFiles{iFile});
    if isempty(OutputInfo) || OutputInfo(1).bytes <= 0
        return;
    end
    % Allow one second for filesystems with coarse timestamp resolution.
    if OutputInfo(1).datenum > MarkerDate + 1/86400
        return;
    end
end
tf = true;
end


function local_write_stage_marker(Job, StageName, OutputFiles)
if isempty(OutputFiles)
    return;
end
MarkerFile = local_stage_marker_file(Job, StageName);
fid = fopen(MarkerFile, 'w');
if fid < 0
    warning('Unable to write completion marker: %s', MarkerFile);
    return;
end
CleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid, 'stage\t%s\n', StageName);
fprintf(fid, 'verified\t%s\n', datestr(now, 31));
for iFile = 1:numel(OutputFiles)
    if exist(OutputFiles{iFile}, 'file') == 2
        Info = dir(OutputFiles{iFile});
        fprintf(fid, 'output\t%s\t%d\n', OutputFiles{iFile}, Info(1).bytes);
    end
end
end


function local_remove_stage_marker(Job, StageName)
MarkerFile = local_stage_marker_file(Job, StageName);
if exist(MarkerFile, 'file') == 2
    delete(MarkerFile);
end
end


function local_backup_incomplete_file(FileName, Job, Cfg, StageName)
if isempty(FileName) || exist(FileName, 'file') ~= 2
    return;
end

BackupDir = fullfile(Cfg.TedanaDir, 'Backup', 'IncompleteOutputs', ...
    sprintf('session_%02d', Job.SessionIndex), StageName, Job.SubjectID);
local_mkdir(BackupDir);
[~, Name, Ext] = fileparts(FileName);
if strcmpi(Ext, '.gz')
    [~, Name2, Ext2] = fileparts(Name);
    Name = Name2;
    Ext = [Ext2 Ext];
end
Stamp = datestr(now, 'yyyymmdd_HHMMSS');
BackupFile = fullfile(BackupDir, sprintf('%s.incomplete_%s%s', Name, Stamp, Ext));
Counter = 1;
while exist(BackupFile, 'file') == 2
    BackupFile = fullfile(BackupDir, sprintf('%s.incomplete_%s_%02d%s', Name, Stamp, Counter, Ext));
    Counter = Counter + 1;
end

[IsSuccess, Message] = movefile(FileName, BackupFile);
if ~IsSuccess
    error('Unable to back up incomplete output %s to %s: %s', FileName, BackupFile, Message);
end
fprintf('Backed up incomplete output: %s -> %s\n', FileName, BackupFile);
end


function CommandBody = local_ensure_command_flag(CommandBody, FlagName)
FlagPattern = ['(^|\s)' regexptranslate('escape', FlagName) '(\s|$)'];
if isempty(regexp(CommandBody, FlagPattern, 'once'))
    CommandBody = sprintf('%s %s', CommandBody, FlagName);
end
end


function PartialFile = local_build_partial_output_file(OutputFile)
if local_ends_with(lower(OutputFile), '.nii.gz')
    PartialFile = [OutputFile(1:end-length('.nii.gz')) '.dpabi_partial.nii.gz'];
elseif local_ends_with(lower(OutputFile), '.nii')
    PartialFile = [OutputFile(1:end-length('.nii')) '.dpabi_partial.nii'];
else
    PartialFile = [OutputFile '.dpabi_partial'];
end
end


function DenoisedFile = local_resolve_tedana_denoised_file(OutDir, Prefix, Convention)
Candidates = { ...
    fullfile(OutDir, [Prefix '_desc-denoised_bold.nii.gz']), ...
    fullfile(OutDir, [Prefix '_desc-denoised_bold.nii']), ...
    fullfile(OutDir, [Prefix '_desc-optcomDenoised_bold.nii.gz']), ...
    fullfile(OutDir, [Prefix '_desc-optcomDenoised_bold.nii'])};

if strcmpi(Convention, 'orig')
    Candidates = [Candidates, ...
        {fullfile(OutDir, 'dn_ts_OC.nii.gz'), ...
        fullfile(OutDir, 'dn_ts_OC.nii')}]; %#ok<AGROW>
end

for i = 1:numel(Candidates)
    if exist(Candidates{i}, 'file')
        DenoisedFile = Candidates{i};
        return;
    end
end

DirList = dir(fullfile(OutDir, [Prefix '*desc-denoised_bold.nii*']));
if ~isempty(DirList)
    IsNativeTedanaOutput = cellfun(@(x)isempty(strfind(x, '_space-')) ...
        && isempty(strfind(x, '.dpabi_partial')), {DirList.name}); %#ok<STREMP>
    DirList = DirList(IsNativeTedanaOutput);
end
if isempty(DirList)
    DirList = dir(fullfile(OutDir, [Prefix '*optcomDenoised*.nii*']));
end
if isempty(DirList)
    DirList = dir(fullfile(OutDir, [Prefix '*dn_ts*.nii*']));
end
if ~isempty(DirList)
    IsCompleteName = cellfun(@(x)isempty(strfind(x, '.dpabi_partial')), {DirList.name}); %#ok<STREMP>
    DirList = DirList(IsCompleteName);
end

if isempty(DirList)
    DenoisedFile = '';
else
    DenoisedFile = fullfile(DirList(1).folder, DirList(1).name);
end
end


function TransformFile = local_find_t1w_to_target_transform(FMRIPrepDir, SubjectID, TargetSpace)
TransformFile = '';

SearchDirs = {fullfile(FMRIPrepDir, SubjectID, 'anat')};
SesDirs = dir(fullfile(FMRIPrepDir, SubjectID, 'ses-*'));
SesDirs = SesDirs([SesDirs.isdir]);
for iSes = 1:numel(SesDirs)
    SearchDirs{end+1} = fullfile(SesDirs(iSes).folder, SesDirs(iSes).name, 'anat'); %#ok<AGROW>
end

Patterns = { ...
    [SubjectID '*_from-T1w_to-' TargetSpace '_mode-image_xfm.h5'], ...
    [SubjectID '*_from-T1w_to-' TargetSpace '_mode-image_xfm.txt']};

for iDir = 1:numel(SearchDirs)
    if ~exist(SearchDirs{iDir}, 'dir')
        continue;
    end
    for iPattern = 1:numel(Patterns)
        DirList = dir(fullfile(SearchDirs{iDir}, Patterns{iPattern}));
        if ~isempty(DirList)
            TransformFile = fullfile(DirList(1).folder, DirList(1).name);
            return;
        end
    end
end
end


function EchoTimeSec = local_read_echo_time_seconds(JsonFile)
Txt = fileread(JsonFile);
S = jsondecode(Txt);

if isfield(S, 'EchoTime') && ~isempty(S.EchoTime)
    EchoTimeSec = double(S.EchoTime);
elseif isfield(S, 'echo_time') && ~isempty(S.echo_time)
    EchoTimeSec = double(S.echo_time);
else
    error('EchoTime was not found in %s', JsonFile);
end

if EchoTimeSec > 1
    EchoTimeSec = EchoTimeSec / 1000;
end
end


function RelativePath = local_relative_path(TargetPath, RootPath)
TargetPath = local_normalize_path(TargetPath);
RootPath = local_normalize_path(RootPath);

if strcmp(TargetPath, RootPath)
    RelativePath = '';
    return;
end

Prefix = [RootPath filesep];
if local_starts_with(TargetPath, Prefix)
    RelativePath = TargetPath((numel(Prefix)+1):end);
else
    error('Path "%s" is not inside root "%s".', TargetPath, RootPath);
end
end


function ContainerPath = local_map_to_container_path(TargetPath, RootPath, WorkingDirInContainer)
RelativePath = local_relative_path(TargetPath, RootPath);
RelativePath = strrep(RelativePath, '\', '/');
RelativePath = strrep(RelativePath, filesep, '/');

if isempty(RelativePath)
    ContainerPath = WorkingDirInContainer;
else
    if local_ends_with(WorkingDirInContainer, '/')
        ContainerPath = [WorkingDirInContainer RelativePath];
    else
        ContainerPath = [WorkingDirInContainer '/' RelativePath];
    end
end
end


function ContainerPaths = local_map_to_container_paths(TargetPaths, RootPath, WorkingDirInContainer)
ContainerPaths = cell(size(TargetPaths));
for i = 1:numel(TargetPaths)
    ContainerPaths{i} = local_map_to_container_path(TargetPaths{i}, RootPath, WorkingDirInContainer);
end
end


function PathOut = local_normalize_path(PathIn)
PathOut = char(java.io.File(PathIn).getCanonicalPath());
end


function Command = local_prefix_command(CommandInit, CommandBody)
if isempty(CommandInit)
    Command = CommandBody;
else
    Command = sprintf('%s %s', CommandInit, CommandBody);
end
end


function ArgString = local_build_multi_value_arg(FlagName, Value)
if isempty(Value)
    ArgString = '';
    return;
end

if ischar(Value)
    Value = {Value};
elseif isnumeric(Value)
    Value = {num2str(Value)};
end

ValueCell = cell(size(Value));
for i = 1:numel(Value)
    ValueCell{i} = local_to_char(Value{i});
end

ArgString = sprintf('%s %s', FlagName, strjoin(ValueCell, ' '));
end


function Txt = local_to_char(Value)
if ischar(Value)
    Txt = Value;
elseif isnumeric(Value)
    if isscalar(Value)
        if abs(Value-round(Value)) < eps
            Txt = num2str(round(Value));
        else
            Txt = num2str(Value);
        end
    else
        Txt = num2str(Value);
    end
elseif isa(Value,'string')
    Txt = char(Value);
else
    error('Unable to convert value to char.');
end
end


function Q = local_shellquote(Str)
Str = char(Str);
Str = strrep(Str, '"', '\"');
Q = ['"' Str '"'];
end


function TEUnit = local_detect_tedana_te_unit(CommandInit)
HelpCommand = local_prefix_command(CommandInit, 'tedana -h');

[Status, Txt] = system(HelpCommand);
if Status ~= 0
    warning('Unable to query tedana -h. Falling back to milliseconds for compatibility.');
    TEUnit = 'milliseconds';
    return;
end

TxtLower = lower(Txt);
if local_contains(TxtLower, 'echo times in seconds') || local_contains(TxtLower, 'seconds (per bids convention)')
    TEUnit = 'seconds';
elseif local_contains(TxtLower, 'echo times (in ms)') || local_contains(TxtLower, 'echo times in milliseconds')
    TEUnit = 'milliseconds';
else
    warning('Unable to determine tedana TE unit from help text. Falling back to milliseconds.');
    TEUnit = 'milliseconds';
end
end


function tf = local_starts_with(Str, Pattern)
tf = length(Str) >= length(Pattern) && strcmp(Str(1:length(Pattern)), Pattern);
end


function tf = local_ends_with(Str, Pattern)
tf = length(Str) >= length(Pattern) && strcmp(Str((end-length(Pattern)+1):end), Pattern);
end


function tf = local_contains(Str, Pattern)
tf = ~isempty(strfind(Str, Pattern)); %#ok<STREMP>
end
