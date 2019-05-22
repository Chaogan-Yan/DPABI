function y_ZStandardization_Bilateral_Surf(InFile_LH, InFile_RH, OutputName_LH, OutputName_RH, AMaskFilename_LH, AMaskFilename_RH)
% y_ZStandardization_Bilateral_Surf(InFile_LH, InFile_RH, OutputName_LH, OutputName_RH, AMaskFilename_LH, AMaskFilename_RH)
% Calculate z-standardized data for bilateral hemispheres
% Input:
% 	InFile_LH	        The input surface file for left hemishpere
% 	InFile_RH	        The input surface  file for right hemishpere
%	OutputName_LH  	-	Output filename for left hemishpere. 
%	OutputName_RH  	-	Output filename for right hemishpere
% 	AMaskFilename_LH	the mask file name ofr left hemishpere, only compute the point within the mask
% 	AMaskFilename_RH	the mask file name ofr right hemishpere, only compute the point within the mask
% Output:
%   The standardized image will be output as where OutputName specified.
%-----------------------------------------------------------
% By YAN Chao-Gan 190521.
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com


BrainMaskData_LH=y_ReadAll(AMaskFilename_LH);
BrainMaskData_RH=y_ReadAll(AMaskFilename_RH);

[Data_LH, VoxelSize, FileList, Header_LH] = y_ReadAll(InFile_LH);
[Data_RH, VoxelSize, FileList, Header_RH] = y_ReadAll(InFile_RH);

Data_Bilateral=[Data_LH(find(BrainMaskData_LH));Data_RH(find(BrainMaskData_RH))];
Mean=mean(Data_Bilateral);
Std=std(Data_Bilateral);

Temp = ((Data_LH - Mean) ./ Std) .* (BrainMaskData_LH~=0);
y_Write(Temp,Header_LH,OutputName_LH);

Temp = ((Data_RH - Mean) ./ Std) .* (BrainMaskData_RH~=0);
y_Write(Temp,Header_RH,OutputName_RH);
