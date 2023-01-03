function y_GroupAnalysis_PermutationTest_Image(DependentVolume,Predictor,OutputName,MaskFile,CovVolume,Contrast,TF_Flag,IsOutputResidual,Header,PALMSettings)
% function y_GroupAnalysis_PermutationTest_Image(DependentVolume,Predictor,OutputName,MaskFile,CovVolume,Contrast,TF_Flag,IsOutputResidual,Header,PALMSettings)
% Perform group analysis with permutation test. Using Dr. Anderson Winkler's PALM toolbox.  
% Input:
% 	DependentVolume		-	4D data matrix (DimX*DimY*DimZ*DimTimePoints) or the directory of 3D image data file or the filename of one 4D data file
%   Predictor - the Predictors M (subjects) by N (traits). SHOULD INCLUDE the CONSTANT column if needed. The program will not add constant column automatically.
%   OutputName - the output name. (should not have extention such as .img,.nii)
%   MaskFile - the mask file.
%   CovVolume  [optional] - 4D data matrix (DimX*DimY*DimZ*DimTimePoints) or the directory of image covariates, in which the files should be correspond to the DependentVolume
%   Contrast [optional] - Contrast for T-test for F-test. 1*ncolX matrix.
%   TF_Flag [optional] - 'T' or 'F'. Specify if T-test or F-test need to be performed for the contrast
%   IsOutputResidual [optional] - SHOULD be 0. This parameter is not used and just for compatibility. 
%   Header [optional] - If DependentVolume is given as a 4D Brain matrix, then Header should be designated.
% Output:
%   OutputName_b.nii, OutputName_T.nii     - beta and t value files results
%   OutputName_Residual.nii (optional)     - Residual files
%___________________________________________________________________________
% Written by YAN Chao-Gan 161116.
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com
% Revised by YAN Chao-Gan 181204. Add GIfTI support.

if ~isnumeric(DependentVolume)
    if (ischar(DependentVolume)) && (exist(DependentVolume,'file')==2) %YAN Chao-Gan, 210416. Read txt file
        [pathstr, name, ext] = fileparts(DependentVolume);
        if (strcmpi(ext, '.txt'))
            fid = fopen(DependentVolume);
            FileCell = textscan(fid,'%s\n'); 
            fclose(fid);
            DependentVolume=FileCell{1};
        end
    end
    [DependentVolume,VoxelSize,theImgFileList, Header] = y_ReadAll(DependentVolume);
    fprintf('\n\tImage Files in the Group:\n');
    for itheImgFileList=1:length(theImgFileList)
        fprintf('\t%s\n',theImgFileList{itheImgFileList});
    end
end

if (ischar(Predictor)) && (exist(Predictor,'file')==2) %YAN Chao-Gan, 210416. Read txt file
    Predictor=load(Predictor);
end

if ~isfield(Header,'cdata') && ~isfield(Header,'MatrixNames') %YAN Chao-Gan 181204. If NIfTI data
    Suffix='.nii';
else
    Suffix='.gii';
end

if exist('CovVolume','var') && (~isnumeric(CovVolume))
    if (ischar(CovVolume)) && (exist(CovVolume,'file')==2) %YAN Chao-Gan, 210416. Read txt file
        [pathstr, name, ext] = fileparts(CovVolume);
        if (strcmpi(ext, '.txt'))
            fid = fopen(CovVolume);
            FileCell = textscan(fid,'%s\n');
            fclose(fid);
            CovVolume=FileCell{1};
        end
    end
    
    [CovVolume,VoxelSize,theImgFileList] = y_ReadAll(CovVolume);%YAN Chao-Gan, 160119. Fixed a bug.  %[CovVolume] = y_ReadAll(DependentVolume);
    fprintf('\n\tImage Files as covariates:\n');
    for itheImgFileList=1:length(theImgFileList)
        fprintf('\t%s%s\n',theImgFileList{itheImgFileList});
    end
end

[Path, fileN, extn] = fileparts(OutputName);
TempDir=fullfile(Path,'Temp');
mkdir(TempDir);

%First do a normal stats with DPABI. Need to get some info there. %YAN Chao-Gan, 210123
y_GroupAnalysis_Image(DependentVolume,Predictor,OutputName,MaskFile,CovVolume,Contrast,TF_Flag,IsOutputResidual,Header);

if isfield(Header,'MatrixNames') %For DPABINet Matrix
    Header_DPABINetMatrix = Header;
    Header=gifti(double(DependentVolume));
end

y_Write(DependentVolume,Header,[TempDir,filesep,'DependentVolume',Suffix]);
if exist('CovVolume','var') && (~isempty(CovVolume))
    y_Write(CovVolume,Header,[TempDir,filesep,'CovVolume',Suffix]);
end

csvwrite([TempDir,filesep,'Design.csv'],Predictor);
csvwrite([TempDir,filesep,'Contrast.csv'],Contrast);

fid = fopen([TempDir,filesep,'PALMConfig.txt'],'w');
fprintf(fid,'-i %s\n',[TempDir,filesep,'DependentVolume',Suffix]);

if exist('MaskFile','var') && ~isempty(MaskFile)
    %The data type has an effect on the results, thus convert to double
    [MaskData,Temp,theImgFileList, MaskHeader] = y_ReadAll(MaskFile);
    if isfield(Header,'cdata')
        y_Write(MaskData,gifti(double(MaskData)),[TempDir,filesep,'MaskFile',Suffix]);
    else
        y_Write(MaskData,MaskHeader,[TempDir,filesep,'MaskFile',Suffix]);
    end
    fprintf(fid,'-m %s\n',[TempDir,filesep,'MaskFile',Suffix]); %fprintf(fid,'-m %s\n',MaskFile);
end

if isfield(PALMSettings,'SurfFile') && ~isempty(PALMSettings.SurfFile) %YAN Chao-Gan 181204. If GIfTI data, need surface
    fprintf(fid,'-s %s',PALMSettings.SurfFile);
    if isfield(PALMSettings,'SurfAreaFile') && ~isempty(PALMSettings.SurfAreaFile)
        fprintf(fid,' %s',PALMSettings.SurfAreaFile);
    end
    fprintf(fid,'\n');
end

if exist('CovVolume','var') && (~isempty(CovVolume))
    fprintf(fid,'-evperdat %s %g\n',[TempDir,filesep,'CovVolume',Suffix],length(Contrast));
end
fprintf(fid,'-d %s\n',[TempDir,filesep,'Design.csv']);
if strcmpi(TF_Flag,'T')
    fprintf(fid,'-t %s\n',[TempDir,filesep,'Contrast.csv']);
elseif strcmpi(TF_Flag,'F')
    csvwrite([TempDir,filesep,'Contrast_T_forF.csv'],PALMSettings.Contrast_T_forF);
    fprintf(fid,'-t %s -f %s -fonly\n',[TempDir,filesep,'Contrast_T_forF.csv'],[TempDir,filesep,'Contrast.csv']);
end
if isfield(PALMSettings,'Pearson') && PALMSettings.Pearson
    fprintf(fid,'-pearson\n');
end
if isfield(PALMSettings,'ISE') && PALMSettings.ISE
    fprintf(fid,'-ise\n');
end
if isfield(PALMSettings,'EE') && PALMSettings.EE
    fprintf(fid,'-ee\n');
end
if isfield(PALMSettings,'Whole') && PALMSettings.Whole
    fprintf(fid,'-whole\n');
end
if isfield(PALMSettings,'Within') && PALMSettings.Within
    fprintf(fid,'-within\n');
end
if PALMSettings.TFCE
    fprintf(fid,'-T\n');
end
if isfield(PALMSettings,'TFCE2D') && (PALMSettings.TFCE2D) %YAN Chao-Gan 221115. TFCE2D
    fprintf(fid,'-T\n');
    fprintf(fid,'-tfce2D\n');
end
if PALMSettings.FDR
    fprintf(fid,'-fdr\n');
end
if PALMSettings.TwoTailed
    fprintf(fid,'-twotail\n');
end
if PALMSettings.SavePermutations
    fprintf(fid,'-saveperms\n');
end
if PALMSettings.ClusterInference
    fprintf(fid,'-C %g\n',PALMSettings.ClusterFormingThreshold);
end
if ~strcmpi(PALMSettings.AccelerationMethod,'NoAcceleration');
    fprintf(fid,'-accel %s\n',PALMSettings.AccelerationMethod);
end
fprintf(fid,'-n %g\n',PALMSettings.nPerm);
if isfield(PALMSettings,'ExchangeabilityBlocks') && (~isempty(PALMSettings.ExchangeabilityBlocks))
    csvwrite([TempDir,filesep,'ExchangeabilityBlocks.csv'],PALMSettings.ExchangeabilityBlocks);
    fprintf(fid,'-eb %s\n',[TempDir,filesep,'ExchangeabilityBlocks.csv']);
end
fprintf(fid,'-o %s\n',fullfile(Path, fileN));
fclose(fid);
palm([TempDir,filesep,'PALMConfig.txt']);


%If this is DPABINet Matrix, then read the gifti fwep and save into matrices
if exist('Header_DPABINetMatrix','var') && (~isempty(Header_DPABINetMatrix))
    [Path, Name, Ext]=fileparts(OutputName); %YAN Chao-Gan, 200516. Deal with the Ext
    DirFile=dir(fullfile(Path, [Name,'_dpv_*stat_fwep.gii']));
    FileName=fullfile(Path, DirFile(1).name);
    Data=y_ReadAll(FileName);
    y_Write(Data,Header_DPABINetMatrix,fullfile(Path, [Name,'_PALM_fwep.mat']));
    
    DirFile=dir(fullfile(Path, [Name,'_dpv_*stat_uncp.gii']));
    FileName=fullfile(Path, DirFile(1).name);
    Data=y_ReadAll(FileName);
    y_Write(Data,Header_DPABINetMatrix,fullfile(Path, [Name,'_PALM_uncp.mat']));
end

