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

[ProgramPath, fileN, extn] = fileparts(which('DPARSF.m'));

OldDirTemp=pwd;
cd([ProgramPath,filesep,'dcm2nii']);
if ispc
    if strcmpi(Option,'DefaultINI')
        Option='-b dcm2nii.ini';
    end
    eval(['!dcm2nii.exe ',Option,' -o ',OutputDir,' ',InputFilename]);
elseif ismac
    if strcmpi(Option,'DefaultINI')
        Option='-b ./dcm2nii_linux.ini';
    end
    eval(['!./dcm2nii_mac ',Option,' -o ',OutputDir,' ',InputFilename]);
else
    if strcmpi(Option,'DefaultINI')
        Option='-b ./dcm2nii_linux.ini';
    end
    eval(['!chmod +x dcm2nii_linux']);
    eval(['!./dcm2nii_linux ',Option,' -o ',OutputDir,' ',InputFilename]);
end
cd(OldDirTemp);


