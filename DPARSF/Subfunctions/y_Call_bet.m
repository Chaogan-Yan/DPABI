function y_Call_bet(InputFilename, OutputFilename, Option, WorkingDir)
% function y_Call_bet(InputFilename, OutputFilename, Option)
% Call FSL's bet under Linux or Mac OS
% Call Chris Rorden's revised bet (distributed with MRIcroN) under Windows. ('eval' is not suitable for 'parfor')
% Input:
% 	InputFilename	 -   The Input File name. Could be one T1 image or functional image.
%   OutputFilename   -   The output file name.
% 	Option       	 -   The option for calling bet. E.g. '-f 0.3': for functional images.
%   WorkingDir       -   If need to call dpabi docker, then need the WorkingDir
% Output:
%	                 -   The NIfTI image after bet
%-----------------------------------------------------------
% Written by YAN Chao-Gan 131024.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com

if ~exist('Option','var')
    Option = '';
end

if ~ispc
    HasFSL = system('which bet'); %Test if FSL installed %YAN CHao-Gan, 190710
    
    if HasFSL == 0
        %If yes, call FSL's bet directly
        eval(['!bet ',InputFilename,' ',OutputFilename,' ',Option]);
    else
        %If not, use FSL's bet in dpabi docker
        [DPABIPath, fileN, extn] = fileparts(which('DPABI.m'));
        CommandInit=sprintf('docker run -ti --rm -v %s:/opt/freesurfer/license.txt -v %s:/data -e SUBJECTS_DIR=/data/freesurfer cgyan/dpabi', fullfile(DPABIPath, 'DPABISurf', 'FreeSurferLicense', 'license.txt'), WorkingDir);
        if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
            CommandInit=sprintf('export SUBJECTS_DIR=%s/freesurfer && ', WorkingDir);
        end
        
        InputFilename = strrep(InputFilename,WorkingDir,'/data'); %Replace the path for docker
        OutputFilename = strrep(OutputFilename,WorkingDir,'/data');
        Command = [CommandInit, ' bet ',InputFilename,' ',OutputFilename,' ',Option];
        system(Command);
    end
    
else
    [ProgramPath, fileN, extn] = fileparts(which('DPARSFA_run.m'));
    OldDirTemp=pwd;
    
    [InPath, InFile, InExt] = fileparts(InputFilename);
    [OutPath, OutFile, OutExt] = fileparts(OutputFilename);
    if strcmpi(OutExt,'.gz')
        OutputFilename=OutputFilename(1:end-3); %YAN Chao-Gan, 200329. In case .gz cause y_Write error later
    end
    
    [Data Head] = y_Read(InputFilename); %The header "Head" is reserved.
    
    %Write to target directory
    y_Write(Data,Head,fullfile(OutPath,[OutFile,'BeforeBet.img']));
    %E:\ITraWork\WorkTemp\Bet\mricron>dcm2nii -4 N -g N -m N -n N -r N -s Y -v N -x N -o E:\ITraWork\WorkTemp\Bet\Test  E:\ITraWork\WorkTemp\Bet\Test\N.img
    
    %Change to ANALYZE format
    cd([ProgramPath,filesep,'dcm2nii']);
    eval(['!dcm2nii.exe ','-4 N -g N -m N -n N -r N -s Y -v N -x N',' -o ',OutPath,' ',fullfile(OutPath,[OutFile,'BeforeBet.img'])]);
    
    %Bet
    cd([ProgramPath,filesep,'bet']);
    eval(['!bet ',fullfile(OutPath,['f',OutFile,'BeforeBet.img']),' ',fullfile(OutPath,[OutFile,'AfterBet.img']),' ',Option]);

    %Write in NIfTI with the reserved header.
    Data = y_Read(fullfile(OutPath,[OutFile,'AfterBet.img']));
    y_Write(Data,Head,OutputFilename);
    
    delete(fullfile(OutPath,[OutFile,'BeforeBet.*']));
    delete(fullfile(OutPath,['f',OutFile,'BeforeBet.*']));
    delete(fullfile(OutPath,[OutFile,'AfterBet.*']));

    cd(OldDirTemp);
end





