function [Cfg, Jobs] = y_OrganizeTedanaResults(Cfg, WorkingDir)
% Validate/copy existing denoised results after moving a processing directory.
% This entry point never executes tedana, ANTs, or surface projection commands.
% Missing/incomplete results are recorded in tedana_organize_report.tsv.
if ischar(Cfg)
    Loaded = load(Cfg, 'Cfg');
    Cfg = Loaded.Cfg;
end
if nargin > 1 && ~isempty(WorkingDir), Cfg.WorkingDir = WorkingDir; end
if ~isfield(Cfg,'MultiEcho') || ~isstruct(Cfg.MultiEcho), Cfg.MultiEcho = struct(); end
Cfg.MultiEcho.OrganizeSource = 'tedana';
[Cfg, ~] = y_ResolveOrganizeConfig(Cfg);
ReportFile = fullfile(Cfg.WorkingDir, 'fmriprep_missing_outputs.tsv');
[Ready, Missing] = y_CheckFMRIPrepOutputs(Cfg, ReportFile);
if ~Ready
    error('DPABISurf:IncompleteFMRIPrep', ...
        '%d required fMRIPrep output(s) missing. See %s', numel(Missing), ReportFile);
end
OrganizeCfg = Cfg;
OrganizeCfg.MultiEcho.OrganizeOnly = 1;
OrganizeCfg.MultiEcho.DryRun = 0;
OrganizeCfg.MultiEcho.Overwrite = 0;
OrganizeCfg.MultiEcho.RequireSurfaceResults = 1;
OrganizeCfg.MultiEcho.RequireTargetSpace = 1;
OrganizeCfg.MultiEcho.GenerateSurfaceResults = 1;
[~, Jobs] = y_MultiEchoICA_Tedana(OrganizeCfg);
end
