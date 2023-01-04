function y_Call_dcm2nii(InputFilename, OutputDir, Option)
% function y_Call_dcm2nii(InputFilename, OutputDir, Option)
% Call Chris Rorden's dcm2nii for different platform as well as for parfor usage. ('eval' is not suitable for 'parfor')
% Input:
% 	InputFilename	 -   The Input File name. Could be one of the DICOM file
% 	                     or the T1 image want to perfrom reorient and crop
%   OutputDir        -   The output directory.
% 	Option       	 -   The option for calling dcm2nii. Could be:
%                        'DefaultINI': use dcm2nii.ini under the directory of dcm2nii
%                        Options for dcm2nii: e.g. '-g N -m N -n Y -r Y -v N -x Y': 
% Output:
%	                 -   The NIfTI images or the reoriented and cropped T1 image 
%-----------------------------------------------------------
% Written by YAN Chao-Gan 120817.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com
% YAN Chao-Gan, 191121. Revised for Calling dcm2niix. 

[ProgramPath, fileN, extn] = fileparts(which('DPARSFA_run.m'));

OldDirTemp=pwd;
cd([ProgramPath,filesep,'dcm2nii']);

if strcmpi(Option,'DefaultINI')
    Option='-b y -x y -z n'; %Option='-b dcm2nii.ini'; % YAN Chao-Gan, 191121. Revised for Calling dcm2niix.
end

if ispc
    %eval(['!dcm2nii.exe ',Option,' -o ',OutputDir,' ',InputFilename]);
    eval(['!dcm2niix.exe ',Option,' -o ',OutputDir,' ',InputFilename]); % YAN Chao-Gan, 191121. Revised for Calling dcm2niix. 
elseif ismac
    %eval(['!./dcm2nii_mac ',Option,' -o ',OutputDir,' ',InputFilename]);
    eval(['!./dcm2niix_mac ',Option,' -o ',OutputDir,' ',InputFilename]); % YAN Chao-Gan, 191121. Revised for Calling dcm2niix. 
else
    eval(['!chmod +x dcm2niix_linux']);
    %eval(['!./dcm2nii_linux ',Option,' -o ',OutputDir,' ',InputFilename]);
    eval(['!./dcm2niix_linux ',Option,' -o ',OutputDir,' ',InputFilename]); % YAN Chao-Gan, 191121. Revised for Calling dcm2niix. 
end
cd(OldDirTemp);


