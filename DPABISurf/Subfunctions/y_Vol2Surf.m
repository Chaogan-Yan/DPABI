function y_Vol2Surf(InputFile,OutputFile,interp, TargetSpace)
% FORMAT y_Vol2Surf(InputFile,OutputFile,interp, TargetSpace)
% Input:
%   InputFile - input filename
%   OutputFile - output filename
%   interp - interpolation method. 0: nearest. 1: trilinear.
%   TargetSpace - Define the target space. 'fsaverage' or 'fsaverage5'
% Output:
%   The projected image file stored in OutputFile
%__________________________________________________________________________
% Written by YAN Chao-Gan 190114.
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com

[DPABIPath, fileN, extn] = fileparts(which('DPABI.m'));

if isnumeric(interp)
    if interp==0
        interp='nearest';
    elseif interp==1
        interp='trilinear';
    else
        error('Wrong interp type.')
    end
end


[InPath, InfileN, Inextn] = fileparts(InputFile);
if isempty(InPath)
    InPath=pwd;
end

[OutPath, OutfileN, Outextn] = fileparts(OutputFile);
if isempty(OutPath)
    OutPath=pwd;
end


if isdeployed && (isunix && (~ismac)) % If running within docker with compiled version
    Command = sprintf('mri_vol2surf --src %s --out %s --trgsubject %s --interp %s --hemi lh --mni152reg', fullfile(InPath,[InfileN, Inextn]),fullfile(OutPath,[OutfileN,'_lh',Outextn]),TargetSpace,interp);
    system(Command);
    Command = sprintf('mri_vol2surf --src %s --out %s --trgsubject %s --interp %s --hemi rh --mni152reg', fullfile(InPath,[InfileN, Inextn]),fullfile(OutPath,[OutfileN,'_rh',Outextn]),TargetSpace,interp);
    system(Command);
else
    if ispc
        CommandInit=sprintf('docker run -i --rm -v %s:/opt/freesurfer/license.txt -v %s:/InPath -v %s:/OutPath cgyan/dpabi', fullfile(DPABIPath, 'DPABISurf', 'FreeSurferLicense', 'license.txt'), InPath, OutPath); %YAN Chao-Gan, 181214. Remove -t because there is a tty issue in windows
    else
        CommandInit=sprintf('docker run -ti --rm -v %s:/opt/freesurfer/license.txt -v %s:/InPath -v %s:/OutPath cgyan/dpabi', fullfile(DPABIPath, 'DPABISurf', 'FreeSurferLicense', 'license.txt'), InPath, OutPath);
    end
    
    Command = sprintf('%s mri_vol2surf --src %s --out %s --trgsubject %s --interp %s --hemi lh --mni152reg', CommandInit, ['/InPath','/',[InfileN, Inextn]],['/OutPath','/',[OutfileN,'_lh',Outextn]],TargetSpace,interp);
    system(Command);
    Command = sprintf('%s mri_vol2surf --src %s --out %s --trgsubject %s --interp %s --hemi rh --mni152reg', CommandInit, ['/InPath','/',[InfileN, Inextn]],['/OutPath','/',[OutfileN,'_rh',Outextn]],TargetSpace,interp);
    system(Command);
end





