function [VarStruct, StatOpt, IsMAT]=w_uiLoadMat(varargin)

if nargin==0
    PDir=pwd;
elseif nargin==1
    PDir=varargin{1};
else
    error('Invalid Input');
end

if exist(PDir, 'file')==2
    PDir=fileparts(PDir);
elseif exist(PDir, 'dir')==7
    PDir=PDir;
else
    PDir=pwd;
end

VarStruct=[];
StatOpt=[];
[File, Path]=uigetfile({'*.mat;*.txt', 'Matlab MAT-File (*.mat) or Text File (*.txt)';'*.*', 'All File (*.*)'},...
    'Pick File', PDir);

if isnumeric(File) && File==0
    return
end

FullName=fullfile(Path, File);
[Path, Name, Ext]=fileparts(FullName);
if strcmpi(Ext, '.txt')
    IsMAT = 0;
    TXT=readcell(FullName,'Delimiter',{' ','\t'});
    try
        TXT=cell2mat(TXT);
    end

    VarSizeStr=sprintf('%d x %d', size(TXT, 1), size(TXT, 2));
    
    StrCell={sprintf('[%s] TXT', VarSizeStr)};
    Var.TXT=TXT;
    
    VarStruct.Path=FullName;
    VarStruct.Var=Var;
    VarStruct.FieldNames={'TXT'};
    VarStruct.StrCell=StrCell;
    VarStruct.Type='TXT';

elseif strcmpi(Ext, '.mat')
    IsMAT = 1;
    M=load(FullName);
    FN=fieldnames(M);
    StrCell=[];
    
    Ind=false(numel(FN), 1);
    Var=[];
    for i=1:numel(FN)
        if (isnumeric(M.(FN{i})) || iscell(M.(FN{i}))) && size(M.(FN{i}), 3)==1
            Ind(i, 1)=true;
            TmpVar=M.(FN{i});
            if size(TmpVar, 1)==1
                TmpVar=TmpVar';
            end
            Var.(FN{i})=TmpVar;
            VarSizeStr=sprintf('%d x %d', size(TmpVar, 1), size(TmpVar, 2));
            StrCell=[StrCell; {sprintf('[%s] %s', VarSizeStr, FN{i})}];
        elseif isstruct(M.(FN{i}))
            S=M.(FN{i});
            if strcmpi(FN{i}, 'StatOpt') && any(strcmpi(fieldnames(S), 'TestFlag'))
                if ~any(strcmpi(fieldnames(S), 'TailedFlag'))
                    if strcmpi(S.TestFlag, 'F')
                        S.TailedFlag=1;
                    else
                        S.TailedFlag=2;
                    end
                end
                if ~any(strcmpi(fieldnames(S), 'Df'))
                    S.Df=0;
                end
                if ~any(strcmpi(fieldnames(S), 'Df2'))
                    S.Df2=0;
                end
                
                StatOpt=S;
            end
        end
    end
    if isempty(StrCell)
        return
    end
    VarStruct.Path=FullName;
    VarStruct.Var=Var;
    VarStruct.FieldNames=FN(Ind);
    VarStruct.StrCell=StrCell;
    VarStruct.Type='MAT';
end