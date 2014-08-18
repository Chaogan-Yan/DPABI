function [Z P] = y_TFRtoZ(ImgFile,OutputName,Flag,Df1,Df2)
% FORMAT [Z P] = y_TFRtoZ(ImgFile,OutputName,Flag,Df1,Df2)
%   Input:
%     ImgFile - T, F or R statistical image which wanted to be converted to Z statistical value
%     OutputName - The output name
%     Flag   - 'T', 'F' or 'R'. Indicate the type of the input statsical image
%     Df1 - the degree of freedom of the statistical image. For F statistical image, there is also Df2
%     Df2 - the second degree of freedom of F statistical image
%   Output:
%     Z - Z statistical image. Also output as .img/.hdr.
%     P - The corresponding P value
%___________________________________________________________________________
% Written by YAN Chao-Gan 100424.
% State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
% ycg.yan@gmail.com
% Modified by Sandy 20140324 for DPABI_VIEW

if ischar(ImgFile)
    [Data VoxelSize Header]=rest_readfile(ImgFile);
else %Added by Sandy for DPABI_VIEW
    Header=ImgFile;
    Data=Header.Raw;
end
[nDim1,nDim2,nDim3]=size(Data);

if (~exist('Flag','var')) || (exist('Flag','var') && isempty(Flag))
   Header_DF = w_ReadDF(Header);
   Flag = Header_DF.TestFlag;
   Df1 = Header_DF.Df;
   Df2 = Header_DF.Df2;
end

if strcmpi(Flag,'F')
    fprintf('Convert F to Z...\n');

    Z = norminv(fcdf(Data, Df1, Df2)); %YAN Chao-Gan 100814. Use one-tail because F value is positive and one-tail.
    Z(Data==0) = 0;
    P = 1-fcdf(Data, Df1, Df2);

    %YAN Chao-Gan, 121223. Convert the big F values to Z values in an approximation like spm_t2z to treat big T values.
    %Referenced from spm_t2z.m
    
    %Tol = 1E-16; %minimum tail probability for direct computation
    Tol = 1E-10; %minimum tail probability for direct computation. This is the tolorance value used in spm_t2z.
    
    F1    = finv(1 - Tol, Df1, Df2);
    %mQb   = Data > F1;
    mQb   = isinf(Z); %Only deal with those with Inf values. YAN Chao-Gan, 121223.
    if any(mQb(:))
        z1          = -norminv(Tol);
        F2          = F1-[1:5]/10;
        z2          = norminv(fcdf(F2,Df1,Df2));
        %-least squares line through ([f1,t2],[z1,z2]) : z = m*f + c
        mc          = [[F1,F2]',ones(length([F1,F2]),1)] \ [z1,z2]';
        
        %-------------------------------------------------------------------
        %-Logarithmic extrapolation
        %-------------------------------------------------------------------
        l0=1/mc(1);
        %-Perform logarithmic extrapolation, negate z for positive t-values
        Z(mQb) = ( log( Data(mQb) -F1 + l0 ) + (z1-log(l0)) );
        %-------------------------------------------------------------------
    end
    
    
else % T image or R image: YAN Chao-Gan 100814. Changed to call spm_t2z to use approximation in case of big T values.
    
    if strcmpi(Flag,'R')
        fprintf('Convert R to T...\n');
        Data = Data .* sqrt(Df1 / (1 - Data.*Data));
    end
    
    fprintf('Convert T to Z...\n');
    
    P = 2*(1-tcdf(abs(Data),Df1)); %Two-tailed P value
    
    Tol = 1E-16; %minimum tail probability for direct computation
    Z = spm_t2z(Data,Df1,Tol);
    Z = reshape(Z,[nDim1,nDim2,nDim3]);
end


Z(isnan(Z))=0;
P(isnan(P))=1;

if ~isempty(OutputName)
    Header.descrip=sprintf('{Z_[%.1f]}',1);
    y_Write(Z, Header, OutputName);
end
fprintf('\n\tT/F/R to Z Calculation finished.\n');