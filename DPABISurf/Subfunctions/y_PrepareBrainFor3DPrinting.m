function [Cfg, STLFiles] = y_PrepareBrainFor3DPrinting(Cfg, WorkingDir)
% y_PrepareBrainFor3DPrinting - Export individual bilateral pial surfaces.
% Usage:
%   y_PrepareBrainFor3DPrinting(Cfg);
%   y_PrepareBrainFor3DPrinting('/path/to/DPABISurf_Cfg.mat');
%   [Cfg, STLFiles] = y_PrepareBrainFor3DPrinting(Cfg, WorkingDir);
%
% Cfg may be a structure or a MAT file containing Cfg.
% WorkingDir optionally overrides Cfg.WorkingDir.
% Cfg.ParallelWorkersNumber controls GNU parallel (default: 1).
% All subject directories under WorkingDir/freesurfer are scanned,
% independently of Cfg.SubjectID. Standard templates are excluded.
% Directories missing either pial surface are skipped with a warning.
%
% Output: WorkingDir/Results/BrainFor3DPrinting/<FreeSurferID>_pial.stl
% STLFiles contains the output paths. Existing STL files are overwritten.
% Uses cgyan/dpabi, as in y_Organize_SegmentSubregions. A deployed Linux
% build already running inside Docker uses its existing FreeSurfer tools.
% --combinesurfs combines meshes; it does not fuse the hemispheres, repair
% meshes, or add a cerebellum/brainstem. Inspect STL files before printing.

if ~exist('Cfg','var') 
    [file,path] = uigetfile('*.mat','Please select the previous Cfg .mat for DPABISurf...');
    Cfg=fullfile(path,file);
end

if ischar(Cfg) || isa(Cfg, 'string')
    Loaded = load(char(Cfg), 'Cfg');
    if ~isfield(Loaded, 'Cfg')
        error('y_PrepareBrainFor3DPrinting:InvalidCfg', ...
            'The MAT file must contain a variable named Cfg.');
    end
    Cfg = Loaded.Cfg;
end
if ~isstruct(Cfg) || ~isscalar(Cfg)
    error('y_PrepareBrainFor3DPrinting:InvalidCfg', 'Cfg must be a scalar structure.');
end
if nargin >= 2 && ~isempty(WorkingDir)
    Cfg.WorkingDir = WorkingDir;
end
if ~isfield(Cfg, 'WorkingDir') || isempty(Cfg.WorkingDir)
    error('y_PrepareBrainFor3DPrinting:MissingWorkingDir', 'Cfg.WorkingDir is required.');
end
if ~isfield(Cfg, 'ParallelWorkersNumber') || isempty(Cfg.ParallelWorkersNumber)
    Cfg.ParallelWorkersNumber = 1;
end
validateattributes(Cfg.ParallelWorkersNumber, {'numeric'}, ...
    {'scalar', 'real', 'finite', 'integer', 'positive'});

% Resolve relative paths before using a Docker bind mount.
[Success, Attributes] = fileattrib(char(Cfg.WorkingDir));
if ~Success || ~Attributes.directory
    error('y_PrepareBrainFor3DPrinting:MissingWorkingDir', ...
        'Working directory does not exist: %s', char(Cfg.WorkingDir));
end
Cfg.WorkingDir = Attributes.Name;
FreeSurferDir = fullfile(Cfg.WorkingDir, 'freesurfer');
if ~exist(FreeSurferDir, 'dir')
    error('y_PrepareBrainFor3DPrinting:MissingFreeSurferDir', ...
        'FreeSurfer directory does not exist: %s', FreeSurferDir);
end

DirList = dir(FreeSurferDir);
DirList = DirList([DirList.isdir]);
Names = sort({DirList.name});
FreeSurferSubjectID = {};
for i = 1:numel(Names)
    SubjectID = Names{i};
    if SubjectID(1) == '.' || ...
            ~isempty(regexp(SubjectID, '^(fsaverage|fsLR|cvs_avg35)', 'once'))
        continue;
    end
    SurfDir = fullfile(FreeSurferDir, SubjectID, 'surf');
    if exist(fullfile(SurfDir, 'lh.pial'), 'file') ~= 2 || ...
            exist(fullfile(SurfDir, 'rh.pial'), 'file') ~= 2
        warning('y_PrepareBrainFor3DPrinting:MissingSurface', ...
            'Skipping %s: lh.pial and/or rh.pial is missing.', SubjectID);
        continue;
    end
    FreeSurferSubjectID{end+1, 1} = SubjectID;
end
STLFiles = {};
if isempty(FreeSurferSubjectID)
    warning('y_PrepareBrainFor3DPrinting:NoSubjects', ...
        'No subjects with both pial surfaces were found in %s.', FreeSurferDir);
    return;
end

OutputDir = fullfile(Cfg.WorkingDir, 'Results', 'BrainFor3DPrinting');
if ~exist(OutputDir, 'dir')
    [Success, Message] = mkdir(OutputDir);
    if ~Success
        error('y_PrepareBrainFor3DPrinting:CreateOutputFailed', '%s', Message);
    end
end

if isdeployed && isunix && ~ismac
    WorkingDir = Cfg.WorkingDir;
    CommandInit = sprintf('export SUBJECTS_DIR=%s &&', ...
        local_shell_quote(fullfile(WorkingDir, 'freesurfer')));
else
    DPABIPath = fileparts(which('DPABI.m'));
    if isempty(DPABIPath)
        error('y_PrepareBrainFor3DPrinting:MissingDPABI', ...
            'Please add DPABI to the MATLAB path.');
    end
    LicenseFile = fullfile(DPABIPath, 'DPABISurf', 'FreeSurferLicense', 'license.txt');
    if exist(LicenseFile, 'file') ~= 2
        error('y_PrepareBrainFor3DPrinting:MissingLicense', ...
            'FreeSurfer license file does not exist: %s', LicenseFile);
    end
    % No -t: works from both interactive MATLAB and noninteractive jobs.
    CommandInit = sprintf(['docker run -i --rm -v %s -v %s ' ...
        '-e SUBJECTS_DIR=/data/freesurfer cgyan/dpabi'], ...
        local_shell_quote([LicenseFile ':/opt/freesurfer/license.txt:ro']), ...
        local_shell_quote([Cfg.WorkingDir ':/data']));
    WorkingDir = '/data';
end

SubjectIDString = '';
STLFiles = cell(numel(FreeSurferSubjectID), 1);
for i = 1:numel(FreeSurferSubjectID)
    SubjectIDString = sprintf('%s %s', SubjectIDString, ...
        local_shell_quote(FreeSurferSubjectID{i}));
    STLFiles{i} = fullfile(OutputDir, [FreeSurferSubjectID{i} '_pial.stl']);
end
% --quote preserves spaces/metacharacters when parallel invokes its shell.
Command = sprintf(['%s parallel --quote -j %g mris_convert --combinesurfs ' ...
    '%s %s %s ::: %s'], CommandInit, Cfg.ParallelWorkersNumber, ...
    local_shell_quote([WorkingDir '/freesurfer/{1}/surf/lh.pial']), ...
    local_shell_quote([WorkingDir '/freesurfer/{1}/surf/rh.pial']), ...
    local_shell_quote([WorkingDir '/Results/BrainFor3DPrinting/{1}_pial.stl']), ...
    SubjectIDString);

fprintf('Exporting bilateral pial STL files for %d subjects...\n', numel(STLFiles));
Status = system(Command);
if Status ~= 0
    error('y_PrepareBrainFor3DPrinting:ConversionFailed', ...
        'STL export failed (exit status %d). Check the Docker/FreeSurfer output above.', Status);
end
for i = 1:numel(STLFiles)
    FileInfo = dir(STLFiles{i});
    if isempty(FileInfo) || FileInfo.bytes == 0
        error('y_PrepareBrainFor3DPrinting:MissingOutput', ...
            'Expected STL output is missing or empty: %s', STLFiles{i});
    end
end
fprintf('Brain STL export finished! Results: %s\n', OutputDir);
end


function Quoted = local_shell_quote(Value)
% Quote one argument for the host shell; GNU parallel quotes the inner shell.
if ispc
    % cmd.exe expands percent variables even inside double quotes.
    if any(ismember(Value, ['"' '%' '!' char(10) char(13)]))
        error('y_PrepareBrainFor3DPrinting:UnsupportedPath', ...
            'Windows paths/IDs must not contain quotes, %%, !, or newlines.');
    end
    Quoted = ['"' Value '"'];
else
    Quote = char(39);
    Quoted = [Quote strrep(Value, Quote, [Quote '"' Quote '"' Quote]) Quote];
end
end
