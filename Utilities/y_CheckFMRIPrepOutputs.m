function [IsComplete, Missing] = y_CheckFMRIPrepOutputs(Cfg, ReportFile)
% Check functional derivatives required by DPABISurf, for every subject/session/run.
% [IsComplete, Missing] = y_CheckFMRIPrepOutputs(Cfg, ReportFile)
% BIDS inputs identify expected runs/echoes, including runs with no derivatives.
% Without BIDS inputs, use derivative run names and require at least one run
% per configured session. This checks presence/nonempty files, not numerical
% correctness or full NIfTI/GIFTI integrity. No data are changed or rerun.
% An optional TSV report lists each missing output; an empty report means all
% checked requirements passed. Anatomical-only configurations have no checks.

if ischar(Cfg)
    Loaded = load(Cfg, 'Cfg');
    Cfg = Loaded.Cfg;
end
Missing = struct('SubjectID', {}, 'SessionIndex', {}, 'BasePrefix', {}, ...
    'MissingOutput', {}, 'ExpectedPath', {});
Root = fullfile(Cfg.WorkingDir, 'fmriprep');
if isfield(Cfg, 'FMRIPrepDir') && ~isempty(Cfg.FMRIPrepDir)
    Root = Cfg.FMRIPrepDir;
end
SessionNumber = 1;
if isfield(Cfg, 'FunctionalSessionNumber')
    SessionNumber = Cfg.FunctionalSessionNumber;
end
Subjects = Cfg.SubjectID;
if ischar(Subjects), Subjects = {Subjects}; end
ME = struct();
if isfield(Cfg, 'MultiEcho'), ME = Cfg.MultiEcho; end
IsTedana = isfield(ME, 'MultiEchoMethod') ...
    && strcmpi(ME.MultiEchoMethod, 'MultiEchoICA_Tedana');
IsMultiEcho = IsTedana || (isfield(Cfg, 'IsMultiEcho') && Cfg.IsMultiEcho);
TargetSpace = local_option(ME, 'TargetSpace', 'MNI152NLin2009cAsym');
SurfaceSpace = local_option(ME, 'SurfaceTargetSpace', 'fsaverage5');

for iSubject = 1:numel(Subjects)
    Subject = Subjects{iSubject};
    if ~strncmp(Subject, 'sub-', 4), Subject = ['sub-' Subject]; end
    for iSession = 1:SessionNumber
        RelativeDir = 'func';
        if SessionNumber > 1
            RelativeDir = fullfile(sprintf('ses-%d', iSession), 'func');
        end
        FuncDir = fullfile(Root, Subject, RelativeDir);
        BIDSDir = fullfile(Cfg.WorkingDir, 'BIDS', Subject, RelativeDir);
        Raw = dir(fullfile(BIDSDir, '*_bold.nii*'));
        Raw = Raw(~[Raw.isdir]);
        RawNames = {Raw.name};
        RawNames = RawNames(~cellfun('isempty', regexp(RawNames, '_bold\.nii(\.gz)?$', 'once')));
        RawKeys = regexprep(RawNames, '_bold\.nii(\.gz)?$', '');
        RawKeys = regexprep(RawKeys, '_echo-[^_]+', '');
        Derivatives = dir(fullfile(FuncDir, '*'));
        Derivatives = Derivatives(~[Derivatives.isdir]);
        Tokens = regexp({Derivatives.name}, '^(.*?_task-[^_]+.*?)_(?:echo-|space-|hemi-|desc-|from-)', 'tokens', 'once');
        Tokens = Tokens(~cellfun('isempty', Tokens));
        DerivedKeys = cellfun(@(x)x{1}, Tokens, 'UniformOutput', false);
        Keys = unique([RawKeys(:); DerivedKeys(:)]);
        if isempty(Keys)
            add_missing('', 'functional run (no BIDS run or derivative found)', FuncDir);
        end
        for iKey = 1:numel(Keys)
            Prefix = Keys{iKey};
            require(FuncDir, {[Prefix '*confounds_*.tsv']}, 'confounds TSV');
            Spaces = {'T1w', TargetSpace};
            for iSpace = 1:numel(Spaces)
                Stem = [Prefix '_space-' Spaces{iSpace}];
                require(FuncDir, {[Stem '*_desc-preproc_bold.nii.gz'], ...
                    [Stem '*_desc-preproc_bold.nii']}, [Spaces{iSpace} ' preprocessed BOLD']);
                require(FuncDir, {[Stem '*_desc-brain_mask.nii.gz'], ...
                    [Stem '*_desc-brain_mask.nii']}, [Spaces{iSpace} ' brain mask']);
            end
            for Surface = {'fsnative', SurfaceSpace}
                for Hemi = {'L', 'R'}
                    require(FuncDir, {[Prefix '_hemi-' Hemi{1} '_space-' Surface{1} '*_bold.func.gii']}, ...
                        [Surface{1} ' hemisphere ' Hemi{1}]);
                end
            end
            if IsMultiEcho
                Echoes = dir(fullfile(FuncDir, [Prefix '_echo-*_desc-preproc_bold.nii.gz']));
                Echoes = Echoes(~[Echoes.isdir] & [Echoes.bytes] > 0);
                EchoTokens = regexp({Echoes.name}, ['^' regexptranslate('escape', Prefix) ...
                    '_echo-([0-9]+)_desc-preproc_bold\.nii\.gz$'], 'tokens', 'once');
                Good = ~cellfun('isempty', EchoTokens);
                Echoes = Echoes(Good);
                EchoIDs = cellfun(@(x)x{1}, EchoTokens(Good), 'UniformOutput', false);
                if numel(unique(EchoIDs)) < 2
                    add_missing(Prefix, 'at least two native preprocessed echoes (.nii.gz)', ...
                        fullfile(FuncDir, [Prefix '_echo-*_desc-preproc_bold.nii.gz']));
                end
                % A surviving subset of echoes must not hide a missing raw echo.
                ExpectedRaw = RawNames(strcmp(RawKeys, Prefix));
                ExpectedTokens = regexp(ExpectedRaw, '_echo-([0-9]+)_', 'tokens', 'once');
                ExpectedTokens = ExpectedTokens(~cellfun('isempty', ExpectedTokens));
                ExpectedIDs = cellfun(@(x)x{1}, ExpectedTokens, 'UniformOutput', false);
                for EchoID = unique([ExpectedIDs(:); EchoIDs(:)])'
                    Stem = [Prefix '_echo-' EchoID{1} '_desc-preproc_bold'];
                    require(FuncDir, {[Stem '.nii.gz']}, ['echo ' EchoID{1} ' preprocessed BOLD']);
                    require(FuncDir, {[Stem '.json']}, ['echo ' EchoID{1} ' JSON']);
                end
            end
            if IsTedana
                require(FuncDir, {[Prefix '_from-boldref_to-T1w_mode-image*xfm.h5'], ...
                    [Prefix '_from-boldref_to-T1w_mode-image*xfm.txt']}, 'boldref-to-T1w transform');
            end
        end
        if IsTedana && ~isempty(Keys)
            AnatDirs = {fullfile(Root, Subject, 'anat')};
            Sessions = dir(fullfile(Root, Subject, 'ses-*'));
            Sessions = Sessions([Sessions.isdir]);
            for i = 1:numel(Sessions)
                AnatDirs{end+1} = fullfile(Root, Subject, Sessions(i).name, 'anat'); %#ok<AGROW>
            end
            Patterns = {[Subject '*_from-T1w_to-' TargetSpace '_mode-image_xfm.h5'], ...
                [Subject '*_from-T1w_to-' TargetSpace '_mode-image_xfm.txt']};
            if ~any(cellfun(@(x)local_has_file(x, Patterns), AnatDirs))
                add_missing('', ['T1w-to-' TargetSpace ' transform'], ...
                    fullfile(Root, Subject, ['[anat or ses-*/anat]/' Patterns{1}]));
            end
        end
    end
end
IsComplete = isempty(Missing);
if nargin > 1 && ~isempty(ReportFile)
    [Parent, ~, ~] = fileparts(ReportFile);
    if ~isempty(Parent) && ~exist(Parent, 'dir'), mkdir(Parent); end
    fid = fopen(ReportFile, 'w');
    if fid < 0, error('y_CheckFMRIPrepOutputs:ReportWrite', 'Cannot write %s', ReportFile); end
    Cleanup = onCleanup(@() fclose(fid)); %#ok<NASGU>
    fprintf(fid, 'SubjectID\tSessionIndex\tBasePrefix\tMissingOutput\tExpectedPath\n');
    for i = 1:numel(Missing)
        M = Missing(i);
        fprintf(fid, '%s\t%d\t%s\t%s\t%s\n', clean(M.SubjectID), M.SessionIndex, ...
            clean(M.BasePrefix), clean(M.MissingOutput), clean(M.ExpectedPath));
    end
end

    function require(Directory, Patterns, Label)
        if ~local_has_file(Directory, Patterns)
            add_missing(Prefix, Label, fullfile(Directory, strjoin(Patterns, ' OR ')));
        end
    end
    function add_missing(BasePrefix, Label, Path)
        Missing(end+1) = struct('SubjectID', Subject, 'SessionIndex', iSession, ...
            'BasePrefix', BasePrefix, 'MissingOutput', Label, 'ExpectedPath', Path);
    end
end

function tf = local_has_file(Directory, Patterns)
tf = false;
for i = 1:numel(Patterns)
    Files = dir(fullfile(Directory, Patterns{i}));
    if any(~[Files.isdir] & [Files.bytes] > 0)
        tf = true;
        return;
    end
end
end

function Value = local_option(Options, Name, Default)
Value = Default;
if isfield(Options, Name) && ~isempty(Options.(Name)), Value = Options.(Name); end
end

function Text = clean(Text)
Text = regexprep(Text, '[\t\r\n]+', ' ');
end
