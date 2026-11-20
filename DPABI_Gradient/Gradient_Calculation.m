function Result = Gradient_Calculation(InputData, InputFiles, InputType, OutDir, AlignmentType, ReferenceUI, nIterations, SparsityThreshold, nComp, UserMask)
% Gradient_Calculation: consistent multi-subject masking and gradient fitting.
% Compatible signature with the original DPABI_Gradient callback.
%
% IMPORTANT:
% 1. Matrix rows MUST identify the same nodes/locations across subjects.
% 2. 'timeseries': rows are nodes, columns are observations; FC=corr(Data').
% 3. 'fc': node-by-node square FC OR node-by-feature rectangular
%    connectivity profiles; pass directly to BrainSpace (no extra corr).
% 4. 'auto': square -> FC; rectangular -> timeseries (legacy fallback).
%    For rectangular FC profiles, explicitly select 'fc' in the GUI.
% 5. SparsityThreshold uses BrainSpace MATLAB's percentile convention:
%    90 retains approximately the top 10%; 10 removes bottom 10%.
%    This revision does NOT silently change the GUI's supplied setting.
%
% File/folder expansion supports .mat and NIfTI. Surface input requires
% a paired {LH,RH} cell for each subject, as in the original implementation.

if nargin < 3 || isempty(InputType), InputType = 'auto'; end
if nargin < 4 || isempty(OutDir), error('OutDir is required.'); end
if nargin < 5 || isempty(AlignmentType), AlignmentType = 'none'; end
if nargin < 6 || isempty(ReferenceUI), ReferenceUI = 'first subject'; end
if nargin < 7 || isempty(nIterations), nIterations = 10; end
if nargin < 8 || isempty(SparsityThreshold), SparsityThreshold = 10; end
if nargin < 9 || isempty(nComp), nComp = 10; end
if nargin < 10, UserMask = []; end

InputType = lower(strtrim(char(InputType)));
AlignmentType = lower(strtrim(char(AlignmentType)));
ReferenceUI = lower(strtrim(char(ReferenceUI)));
assert(isscalar(nComp) && isfinite(nComp) && nComp >= 1 && nComp == floor(nComp), 'nComp must be a positive integer.');
assert(isscalar(nIterations) && isfinite(nIterations) && nIterations >= 1 && nIterations == floor(nIterations), 'nIterations must be a positive integer.');
assert(isscalar(SparsityThreshold) && isfinite(SparsityThreshold) && SparsityThreshold >= 0 && SparsityThreshold <= 100, 'SparsityThreshold must be between 0 and 100.');

% Normalize subject inputs; do not confuse a nested LH/RH pair with 2 subjects.
if ~iscell(InputData)
    InputData = {InputData};
end
InputData = InputData(:);
if numel(InputData) == 1 && (ischar(InputData{1}) || (isstring(InputData{1}) && isscalar(InputData{1})))
    folder = char(InputData{1});
    if isfolder(folder)
        InputData = expand_subject_folder(folder);
        InputFiles = InputData;
    end
end
nSub = numel(InputData);
if nSub == 0, error('No input subjects found.'); end

fprintf('\nGradient Calculation Started (%d input subjects)\n', nSub);
Result = struct();
Result.Meta = struct();
Result.Meta.Header = cell(nSub,1);
Result.Meta.Type = strings(nSub,1);
Result.Meta.LHVertexNum = cell(nSub,1);
Result.Meta.RHVertexNum = cell(nSub,1);
Result.Meta.OriginalRowNum = nan(nSub,1);
Result.Meta.InputSize = cell(nSub,1);
Result.Meta.EffectiveInputType = strings(nSub,1);
Result.Meta.ReplacedNonfinite = zeros(nSub,1);
Result.Meta.ValidRowCount = zeros(nSub,1);
Result.Meta.Error = cell(nSub,1);
Result.Meta.UserMaskApplied = ~isempty(UserMask);

DataAll = cell(nSub,1);
RowValid = cell(nSub,1);
ValidIndex = false(nSub,1);

% PASS 1: load ALL inputs and determine original-row valid masks.
for iSub = 1:nSub
    try
        [Data, itemMeta] = load_subject(InputData{iSub});
        if ndims(Data) > 2
            Data = reshape(Data, [], size(Data,ndims(Data)));
        end
        Data = double(Data);
        if ~ismatrix(Data) || isempty(Data) || size(Data,2) < 2
            error('Input must have at least two columns after reshaping.');
        end
        Result.Meta.InputSize{iSub} = size(Data);
        Result.Meta.OriginalRowNum(iSub) = size(Data,1);
        Result.Meta.Header{iSub} = itemMeta.Header;
        Result.Meta.Type(iSub) = itemMeta.Type;
        Result.Meta.LHVertexNum{iSub} = itemMeta.LHVertexNum;
        Result.Meta.RHVertexNum{iSub} = itemMeta.RHVertexNum;

        typ = resolve_input_type(InputType, Data);
        Result.Meta.EffectiveInputType(iSub) = string(typ);
        nBad = nnz(~isfinite(Data));
        Result.Meta.ReplacedNonfinite(iSub) = nBad;
        if nBad > 0
            warning('Subject %d: replacing %d NaN/Inf values with 0 (original behavior). Review source quality.',iSub,nBad);
            Data(~isfinite(Data)) = 0;
        end

        % Same criterion as the original implementation; mask is logical in
        % ORIGINAL row space, rather than a shortened list of indices.
        mask = var(Data,0,2) > 0;
        if strcmp(typ,'fc') && size(Data,1) == size(Data,2)
            % In a square FC matrix, remove zero rows or zero columns.
            mask = mask & any(Data ~= 0,2) & any(Data ~= 0,1)';
        end
        % Optional GUI spatial mask: must match ORIGINAL node/row count.
        if ~isempty(UserMask)
            if ~isnumeric(UserMask) && ~islogical(UserMask)
                error('UserMask must be numeric or logical.');
            end
            if numel(UserMask) ~= size(Data,1)
                error('UserMask length %d differs from original row count %d.',numel(UserMask),size(Data,1));
            end
            mask = mask & (isfinite(UserMask(:)) & UserMask(:) ~= 0);
        end
        if ~any(mask), error('No valid rows after variance and user masking.'); end
        DataAll{iSub} = Data;
        RowValid{iSub} = mask;
        ValidIndex(iSub) = true;
        Result.Meta.ValidRowCount(iSub) = nnz(mask);
        fprintf('Subject %d: original %d x %d; valid rows %d; type %s\n', iSub,size(Data,1),size(Data,2),nnz(mask),typ);
    catch ME
        Result.Meta.Error{iSub} = getReport(ME,'basic','hyperlinks','off');
        warning('Subject %d load/validation failed: %s',iSub,ME.message);
    end
end
if ~any(ValidIndex), error('No valid subjects after input validation.'); end

% A group mask only makes sense for matched original spatial row indices.
validSubjects = find(ValidIndex);
originalN = Result.Meta.OriginalRowNum(validSubjects);
if any(originalN ~= originalN(1))
    error(['Input subjects have different original row counts (%s). ' ...
        'Subjects must represent the SAME nodes in the SAME order; do not truncate/pad automatically.'], mat2str(originalN'));
end
inputKinds = unique(Result.Meta.EffectiveInputType(validSubjects));
if numel(inputKinds) ~= 1
    error('Mixed FC and timeseries inputs cannot be combined in one run.');
end
effectiveType = char(inputKinds(1));

GroupMask = true(originalN(1),1);
for k = validSubjects(:)'
    GroupMask = GroupMask & RowValid{k};
end
nNodes = nnz(GroupMask);
if nNodes < 3
    error('Common valid node mask has only %d nodes. Check input orientation / data quality.',nNodes);
end
fprintf('Group common valid nodes: %d/%d\n',nNodes,numel(GroupMask));

% PASS 2: reselect identical spatial nodes for every subject and fit.
RawGradient = cell(nSub,1);
ValidLambda = cell(nSub,1);
FCdata = cell(nSub,1);
validIdx_all = cell(nSub,1);
RequestedNComp = nComp;
for k = validSubjects(:)'
    try
        if strcmp(effectiveType,'fc')
            if size(DataAll{k},1) == size(DataAll{k},2)
                FC = DataAll{k}(GroupMask,GroupMask);
                % A square node-by-node connectivity matrix is expected
                % to be approximately symmetric.
                if norm(FC-FC','fro') / max(1,norm(FC,'fro')) > 1e-6
                    warning('Subject %d: square FC is not symmetric; check input orientation.',k);
                end
            else
                FC = DataAll{k}(GroupMask,:); % node-by-feature connectivity profile
            end
        else
            X = DataAll{k}(GroupMask,:);
            FC = corr(X');
        end
        if any(~isfinite(FC(:)))
            error('FC contains NaN/Inf after common masking; inspect zero-variance rows and source data.');
        end
        if strcmp(effectiveType,'timeseries') && size(FC,1) ~= size(FC,2)
            error('Generated FC is not square.');
        end
        currentComp = min(RequestedNComp, size(FC,1)-1);
        gm = GradientMaps('kernel','na','approach','dm','n_components',currentComp);
        gm = gm.fit(FC,'sparsity',SparsityThreshold);
        gr = gm.gradients{1};
        if isempty(gr), error('BrainSpace returned empty gradients.'); end
        currentComp = min(currentComp,size(gr,2));
        RawGradient{k} = gr(:,1:currentComp);
        if iscell(gm.lambda), lam = gm.lambda{1}; else, lam = gm.lambda; end
        ValidLambda{k} = lam(1:min(currentComp,numel(lam)));
        FCdata{k} = FC;
        validIdx_all{k} = find(GroupMask);
    catch ME
        ValidIndex(k) = false;
        Result.Meta.Error{k} = getReport(ME,'basic','hyperlinks','off');
        warning('Subject %d embedding failed: %s',k,ME.message);
        RawGradient{k} = [];
        ValidLambda{k} = [];
        FCdata{k} = [];
        validIdx_all{k} = [];
    end
end
if ~any(ValidIndex), error('No valid subjects after gradient computation.'); end
validSubjects = find(ValidIndex);

% Harmonize number of components without changing the user request in-loop.
nCompOut = min(cellfun(@(g)size(g,2),RawGradient(validSubjects)));
for k = validSubjects(:)'
    RawGradient{k} = RawGradient{k}(:,1:nCompOut);
    ValidLambda{k} = ValidLambda{k}(1:min(nCompOut,numel(ValidLambda{k})));
end
AlignedGradient = RawGradient;
FCvalid = FCdata(validSubjects);
% For joint embedding, every subject must have the same feature dimension.
if ismember(AlignmentType,{'joint','ja','joint alignment'})
    featureN = cellfun(@(x)size(x,2),FCvalid);
    if any(featureN ~= featureN(1))
        error('Joint alignment requires identical feature-column counts across subjects: %s',mat2str(featureN'));
    end
end

switch AlignmentType
    case {'none','na'}
        % Independent gradients; no cross-subject alignment.
    case {'procrustes','pa','procrustes alignment'}
        if numel(validSubjects) >= 2
            switch ReferenceUI
                case {'first subject','first','the first gradient','first_subject'}
                    ref = RawGradient{validSubjects(1)};
                case {'mean','group mean','group_mean'}
                    % Simple sign-consistent mean initialization (not a
                    % substitute for the BrainSpace iterative PA fitting).
                    ref = RawGradient{validSubjects(1)};
                    tmp = zeros(size(ref));
                    for k = validSubjects(:)'
                        g = RawGradient{k};
                        for j = 1:nCompOut
                            r = corr(g(:,j),ref(:,j));
                            if isfinite(r) && r < 0, g(:,j) = -g(:,j); end
                        end
                        tmp = tmp+g;
                    end
                    ref = tmp/numel(validSubjects);
                otherwise
                    error('Unknown ReferenceUI: %s', ReferenceUI);
            end
            G = GradientMaps('kernel','na','approach','dm', ...
                'alignment','pa','n_components',nCompOut);
            G = G.fit(FCvalid,'reference',ref, ...
                'sparsity',SparsityThreshold,'niterations',nIterations);
            for j = 1:numel(validSubjects)
                AlignedGradient{validSubjects(j)} = G.aligned{j}(:,1:nCompOut);
            end
        end
    case {'joint','ja','joint alignment'}
        if numel(validSubjects) >= 2
            G = GradientMaps('kernel','na','approach','dm', ...
                'alignment','ja','n_components',nCompOut);
            G = G.fit(FCvalid,'sparsity',SparsityThreshold);
            for j = 1:numel(validSubjects)
                AlignedGradient{validSubjects(j)} = G.aligned{j}(:,1:nCompOut);
            end
        end
    otherwise
        error('Unknown AlignmentType: %s', AlignmentType);
end

Result.Gradient = AlignedGradient;
Result.RawGradient = RawGradient;
Result.Lambda = ValidLambda;
Result.ValidIndex = ValidIndex;
Result.ValidVertex = validIdx_all;
Result.InputType = InputType;
Result.InputFiles = InputFiles;
Result.Alignment = AlignmentType;
Result.ReferenceUI = ReferenceUI;
Result.SubjectNumber = nSub;
Result.GradientNumber = nCompOut;
Result.Mask = validIdx_all; % compatibility: cell of original-space index lists
Result.GroupMask = GroupMask; % correct logical vector in original row space
Result.Meta.EffectiveGroupInputType = effectiveType;
Result.Meta.SparsityThreshold = SparsityThreshold;
Result.Meta.NIterations = nIterations;
Result.Meta.RequestedComponents = RequestedNComp;
Result.Meta.CommonValidRowCount = nnz(GroupMask);

if ~exist(OutDir,'dir'), mkdir(OutDir); end
save(fullfile(OutDir,'Gradient_Result.mat'),'Result','-v7.3');
fprintf('Saved: %s\n',fullfile(OutDir,'Gradient_Result.mat'));
end

function typ = resolve_input_type(requested,Data)
    switch requested
        case {'fc','connectivity'}
            typ = 'fc';
        case {'timeseries','time series','ts'}
            typ = 'timeseries';
        case {'auto',''}
            if size(Data,1) == size(Data,2)
                typ = 'fc';
            else
                typ = 'timeseries';
            end
        otherwise
            error('Unknown InputType: %s',requested);
    end
end

function [Data, meta] = load_subject(x)
    meta = struct('Type',"matrix",'Header',[], 'LHVertexNum',[], 'RHVertexNum',[]);
    if iscell(x)
        if numel(x) ~= 2, error('Surface subject must contain exactly {LH,RH}.'); end
        LH = y_ReadAll(x{1}); RH = y_ReadAll(x{2});
        Data = [LH; RH];
        meta.Type = "surface";
        meta.LHVertexNum = size(LH,1);
        meta.RHVertexNum = size(RH,1);
    elseif isnumeric(x)
        Data = x;
    elseif ischar(x) || (isstring(x) && isscalar(x))
        p = char(x);
        if ~isfile(p), error('File not found: %s',p); end
        lowerPath = lower(p);
        if endsWith(lowerPath,'.mat')
            s = load(p);
            candidates = {'Data','FC','FCMatrix','Connectivity','TimeSeries','ROISignals'};
            chosen = '';
            for j = 1:numel(candidates)
                if isfield(s,candidates{j}) && isnumeric(s.(candidates{j})) && ~isscalar(s.(candidates{j}))
                    chosen = candidates{j}; break
                end
            end
            if isempty(chosen)
                names = fieldnames(s);
                matches = {};
                for j = 1:numel(names)
                    v = s.(names{j});
                    if isnumeric(v) && ~isscalar(v) && ismatrix(v)
                        matches{end+1} = names{j}; %#ok<AGROW>
                    end
                end
                if numel(matches) ~= 1
                    error('MAT file must contain one unambiguous numeric matrix. Candidates: %s',strjoin(matches,', '));
                end
                chosen = matches{1};
            end
            Data = s.(chosen);
        elseif endsWith(lowerPath,'.txt') || endsWith(lowerPath,'.csv')
            Data = readmatrix(p);
        elseif endsWith(lowerPath,'.nii') || endsWith(lowerPath,'.nii.gz')
            [Data,~,~,Header] = y_ReadAll(p);
            meta.Type = "volume";
            meta.Header = Header;
        elseif endsWith(lowerPath,'.gii')
            error('A GIFTI subject must be supplied as {LH.gii,RH.gii}.');
        else
            error('Unsupported input file: %s',p);
        end
    else
        error('Unsupported input element. Expected numeric matrix, path, or {LH,RH}.');
    end
    if ~isnumeric(Data), error('Input did not resolve to numeric data.'); end
end

function subjects = expand_subject_folder(folder)
    % One file = one subject. For a GUI that groups several files per
    % subject, preserve GUI grouping instead of passing the folder path.
    patterns = {'*.mat','*.txt','*.csv','*.nii','*.nii.gz'};
    allFiles = {};
    for j = 1:numel(patterns)
        files = dir(fullfile(folder,'**',patterns{j}));
        for k = 1:numel(files)
            if ~files(k).isdir
                allFiles{end+1,1} = fullfile(files(k).folder,files(k).name); %#ok<AGROW>
            end
        end
    end
    if isempty(allFiles), error('No .mat/.nii/.nii.gz files found under folder: %s',folder); end
    [~,idx] = sort(lower(string(allFiles)));
    subjects = allFiles(idx);
    fprintf('Expanded folder into %d file inputs (one file per subject).\n',numel(subjects));
end
