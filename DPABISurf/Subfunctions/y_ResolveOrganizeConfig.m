function [Cfg, UseTedana] = y_ResolveOrganizeConfig(Cfg)
% Resolve copied BIDS/fmriprep/freesurfer/tedana results in WorkingDir.
% OrganizeSource: auto (default), tedana, or fmriprep. Auto prefers existing
% tedana results, even when a newly loaded GUI configuration lost that choice.
% OrganizeMode: reuse (default; validate/copy only) or resume (allow computing).
% Paths are deliberately local to WorkingDir; saved absolute paths are not used.
if ischar(Cfg)
    Loaded = load(Cfg, 'Cfg');
    Cfg = Loaded.Cfg;
end
if ~isfield(Cfg, 'MultiEcho') || ~isstruct(Cfg.MultiEcho)
    Cfg.MultiEcho = struct();
end
Cfg.FMRIPrepDir = fullfile(Cfg.WorkingDir, 'fmriprep');
Cfg.TedanaDir = fullfile(Cfg.WorkingDir, 'tedana');
Cfg.SurfaceSubjectsDir = fullfile(Cfg.WorkingDir, 'freesurfer');
if ~exist(Cfg.SurfaceSubjectsDir, 'dir')
    Cfg.SurfaceSubjectsDir = fullfile(Cfg.FMRIPrepDir, 'sourcedata', 'freesurfer');
end
if ~isfield(Cfg.MultiEcho, 'OrganizeSource') || isempty(Cfg.MultiEcho.OrganizeSource)
    Cfg.MultiEcho.OrganizeSource = 'auto';
end
if ~isfield(Cfg.MultiEcho, 'OrganizeMode') || isempty(Cfg.MultiEcho.OrganizeMode)
    Cfg.MultiEcho.OrganizeMode = 'reuse';
end
if ~any(strcmpi(Cfg.MultiEcho.OrganizeMode, {'reuse', 'resume'}))
    error('DPABISurf:OrganizeMode', 'OrganizeMode must be reuse or resume.');
end
SelectedTedana = isfield(Cfg.MultiEcho, 'MultiEchoMethod') && ...
    strcmpi(Cfg.MultiEcho.MultiEchoMethod, 'MultiEchoICA_Tedana');
Subjects = dir(fullfile(Cfg.TedanaDir, 'sub-*'));
HasTedanaResults = any([Subjects.isdir]) || ...
    exist(fullfile(Cfg.TedanaDir, 'tedana_joblist.mat'), 'file') == 2;
switch lower(Cfg.MultiEcho.OrganizeSource)
    case 'auto'
        UseTedana = SelectedTedana || HasTedanaResults;
    case 'tedana'
        UseTedana = true;
    case 'fmriprep'
        UseTedana = false;
    otherwise
        error('DPABISurf:OrganizeSource', 'OrganizeSource must be auto, tedana, or fmriprep.');
end
if UseTedana
    Cfg.MultiEcho.MultiEchoMethod = 'MultiEchoICA_Tedana';
    fprintf('Organize functional data from tedana (%s): %s\n', ...
        Cfg.MultiEcho.OrganizeMode, Cfg.TedanaDir);
elseif SelectedTedana
    % The explicit fmriprep source override must also select its copy branch.
    Cfg.MultiEcho.MultiEchoMethod = 'fMRIPrep';
end
end
