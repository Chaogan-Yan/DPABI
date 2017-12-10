function [ClusterSize_OneTailed_NN6 ClusterSize_OneTailed_NN18 ClusterSize_OneTailed_NN26 ClusterSize_TwoTailed_NN6 ClusterSize_TwoTailed_NN18 ClusterSize_TwoTailed_NN26] = y_AlphaSim(maskfile,outdir,outname,pthr,iter,algor,fwhm_or_acf)
%   y_AlphaSim(maskfile,outdir,outname,rmm,s,pthr,iter)
%   Monte Carlo simulation program similar to the AlphaSim in AFNI.
%   The mechanism is based on AFNI's 3dClustSim, please see more details from http://afni.nimh.nih.gov/pub/dist/doc/manual/AlphaSim.pdf
%------------------------------------------------------------------------------------------------------------------------------
%   Input:
%       maskfile    - The image file indicate which voxels to analyze.
%       outdir      - The path to save the result file.
%       outname     - The filename of the result file.
%       pthr        - Individual voxel threshold probability
%       iter        - Number of Monte Carlo simulations.
%       algor       - The algorithm to generate random field
%                     'fwhm': use gaussian filtering
%                     'acf': alternative to gaussian filtering
%       fwhm_or_acf - if 'fwhm', [fwhmx, fwhmy, fwhmz], if 'acf', [a, b, c]
%   Output:
%       ClusterSize_OneTailed_NN6, ClusterSize_OneTailed_NN18, ...    - The Cluster Size threshold for alpha levels of [0.05 0.025 0.02 0.01]
%       outdir/outname.txt - You can find the cluster-size thresholds and voxel-wise p-value resulting a corrected P value in this file.
%   By YAN Chao-Gan, Dong Zhang-Ye and ZHU Wei-Xuan 091108.
%   State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
% 	Mail to Authors:  <a href="ycg.yan@gmail.com">YAN Chao-Gan</a>; <a	href="dongzy08@gmail.com">DONG Zhang-Ye</a> ; <a href="zhuweixuan@gmail.com">ZHU Wei-Xuan</a> 
%	Version=1.0;
%	Release=20091215;
%   Modified by YAN Chao-Gan 0901215: Fixed the error when rmm=6.
%------------------------------------------------------------------------------------------------------------------------------

% MODIFICATIONS Katharina Wittfeld (September 2014)
% line 72: normrnd replaced by randn (no Statistics Toolbox needed)
% line 86: norminv replaced by a workaround (no Statistics Toolbox needed)
% several modifications in iteration loop (all documented in the code)
% changes: 
% 	moved the masking step (this important: if masking is done before the gauss filter, the gauss filter will blur the borders of the mask and areas outside the mask will be taken into account)
% 	estimation of mean and sd for every iteration seperately (not sure if this has an imapct on the results)
% 	small adjustment in the thresholding step (not sure if the case of xthr<0 can even occure)
% line 103: bwlabeln ersetzt durch SPM-Variante
% line 105-117: joined the loops
%
% Modified by Sandy Wang 20161028
% Output 6 different types of simulation, 2 different types of thresholding
% (one-tailed and two-tailed) x 3 different connection approaches (surfer, edge and corner)
% YAN Chao-Gan, 161120. As the two tailed results are 10 voxels less than 3dClusterSim, this function is pending as for now.


uiwait(msgbox('According to our recent study, DPABI AlphaSim should not be used, please consider permutation test with TFCE. Please see: Chen, X., Lu, B., Yan, C.G.*, 2018. Reproducibility of R-fMRI metrics on the impact of different strategies for multiple comparison correction and sample sizes. Hum Brain Mapp 39, 300-318.'));

if ~(exist('spm_conv_vol.m'))
    uiwait(msgbox('This function is based on SPM, please install SPM5 or later version at first.','AlphaSim'));
    return
end

VariableLine=10000; %YAN Chao-Gan 091215. %VariableLine=3000;

[maskpath, maskname, masketc]=fileparts(maskfile);
[mask,voxdim,header]=y_ReadRPI(maskfile);
[nx,ny,nz] = size(mask);
mask = logical(mask);
nxyz = numel(find(mask));
%dvoxel=max(voxdim);

outfilename=outname;
if all(fwhm_or_acf == 4)
    fwhm_or_acf = [4.55, 4.55, 4.55];  %afni 4 : spm 4.55 
end

%connect=rmm; %Modified by Sandy, input 6, 18, and 26
%if rmm <= dvoxel*sqrt(2)
%    connect= 6; 
%else if rmm <= dvoxel*sqrt(3)
%        connect =18;
%     else
%        connect =26;  %Revised by YAN Chao-Gan 091215. Fixed the error when rmm=6. %connect =27 ;
%     end
%end

ft11=zeros(1,VariableLine);   
mt11=zeros(1,VariableLine);
ft12=zeros(1,VariableLine);   
mt12=zeros(1,VariableLine);
ft13=zeros(1,VariableLine);   
mt13=zeros(1,VariableLine);

ft21=zeros(1,VariableLine);   
mt21=zeros(1,VariableLine);
ft22=zeros(1,VariableLine);   
mt22=zeros(1,VariableLine);
ft23=zeros(1,VariableLine);   
mt23=zeros(1,VariableLine);
count=nx*ny*nz; % Katharina Wittfeld, fixed to the number of voxels in the whole volume
%suma=0;        % Katharina Wittfeld, not needed if estimation of mean and sd is done seperately for every iteration 
%sumsq=0;       % Katharina Wittfeld, not needed if estimation of mean and sd is done seperately for every iteration 

for nt=1:iter
    foneimt11=zeros(1,VariableLine); 
    foneimt12=zeros(1,VariableLine); 
    foneimt13=zeros(1,VariableLine);
    
    foneimt21=zeros(1,VariableLine); 
    foneimt22=zeros(1,VariableLine); 
    foneimt23=zeros(1,VariableLine); 
    
    %fim=normrnd(0,1,nx,ny,nz);
    fim=randn(nx, ny, nz);

    %fim = fim.*mask;       % Katharina Wittfeld, will be down later in the script
    
    % Sandy Wang, justify fwhm or acf
    if strcmpi(algor, 'fwhm') % fwhm
        if any(fwhm_or_acf~=0)
            fim = gauss_filter(fwhm_or_acf,fim,voxdim); 
        end
    else %acf
        % Now do not execute anything
    end
    fimca=reshape(fim,1,[]);
    %count=count+nxyz;      % Katharina Wittfeld, count is fixed now to the number of voxels in the volume
    suma=sum(fimca);        % Katharina Wittfeld, before: suma=sum(fimca)+suma;
    sumsq=sum(fimca.*fimca);    % Katharina Wittfeld, before: sumsq=sum(fimca.*fimca)+sumsq;
    mean=suma/count;
    sd = sqrt((sumsq - (suma * suma)/count) / (count-1));
    
    %zthr =norminv(1 - pthr);
    % Sandy Wang, one-tailed and two-tailed 
    zthr1=norminv(1-pthr);
    zthr2=norminv(1-pthr/2);
    xthr1=sd*zthr1+mean;
    xthr2=sd*zthr2+mean;
    
    fim1=false(size(fim));
    fim2=false(size(fim));   
    fim1(fim>xthr1)=true;
    fim2(fim>xthr2)=true;
    fim2(fim<-xthr2)=true; %YAN Chao-Gan, 170206. Two tailed should have negative values.
    
    fim1 = fim1.*mask; 		% Katharina Wittfeld, apply mask 
    fim2 = fim2.*mask;
    a1=numel(find(fim1==1))/nxyz;
    a2=numel(find(fim2==1))/nxyz;
    %[theCluster, theCount] =bwlabeln(fim, connect);
    CC11=bwconncomp(fim1, 6);
    CC12=bwconncomp(fim1, 18);
    CC13=bwconncomp(fim1, 26);
        
    CC21=bwconncomp(fim2, 6);
    CC22=bwconncomp(fim2, 18);
    CC23=bwconncomp(fim2, 26);          
    %for i=1:theCount
    %    foneimt(numel(find(theCluster==i)))=foneimt(numel(find(theCluster==i)))+1;
    %end
    %for i=1:theCount
    %    ft(numel(find(theCluster==i)))=ft(numel(find(theCluster==i)))+1;
    %end
    
    % Katharina Wittfeld (joined the loops)
    for i=1:CC11.NumObjects
        ind=numel(CC11.PixelIdxList{i});
        foneimt11(ind)=foneimt11(ind)+1;
        ft11(ind)=ft11(ind)+1;
    end
    
    for i=1:CC12.NumObjects
        ind=numel(CC12.PixelIdxList{i});
        foneimt12(ind)=foneimt12(ind)+1;
        ft12(ind)=ft12(ind)+1;
    end
    
    for i=1:CC13.NumObjects
        ind=numel(CC13.PixelIdxList{i});
        foneimt13(ind)=foneimt13(ind)+1;
        ft13(ind)=ft13(ind)+1;
    end 
    
    for i=1:CC21.NumObjects
        ind=numel(CC21.PixelIdxList{i});
        foneimt21(ind)=foneimt21(ind)+1;
        ft21(ind)=ft21(ind)+1;
    end
    
    for i=1:CC22.NumObjects
        ind=numel(CC22.PixelIdxList{i});
        foneimt22(ind)=foneimt22(ind)+1;
        ft22(ind)=ft22(ind)+1;
    end
    
    for i=1:CC23.NumObjects
        ind=numel(CC23.PixelIdxList{i});
        foneimt23(ind)=foneimt23(ind)+1;
        ft23(ind)=ft23(ind)+1;
    end    
    
    mt11(find(foneimt11, 1, 'last' ))=mt11(find(foneimt11, 1, 'last' ))+1;
    mt12(find(foneimt12, 1, 'last' ))=mt12(find(foneimt12, 1, 'last' ))+1;
    mt13(find(foneimt13, 1, 'last' ))=mt13(find(foneimt13, 1, 'last' ))+1;
    
    mt21(find(foneimt21, 1, 'last' ))=mt21(find(foneimt21, 1, 'last' ))+1;
    mt22(find(foneimt22, 1, 'last' ))=mt22(find(foneimt22, 1, 'last' ))+1;
    mt23(find(foneimt23, 1, 'last' ))=mt23(find(foneimt23, 1, 'last' ))+1;
    
    fprintf('iter=%d  pvoxel1=%f pvoxel2=%f zthr1=%f zthr2=%f mean=%f\n',...
        nt,a1,a2,zthr1,zthr2,mean);
end

AlphaLevels=[0.05 0.025 0.02 0.01];

[ClusterSizeTalbe alpha_table11] = output_txt(fullfile(outdir, [outfilename, '_OneTailed_NN6.txt']), ...
    mt11, ft11,...
    iter, nxyz,...
    algor, fwhm_or_acf,...
    maskname, pthr);

%YAN Chao-Gan, 170206. Get the Cluster Size
for iAlpha=1:length(AlphaLevels)
    Temp=alpha_table11<AlphaLevels(iAlpha);
    TempIndex=find(Temp);
    if ~isempty(TempIndex)
        ClusterSize=ClusterSizeTalbe(TempIndex(1));
    else
        ClusterSize=Inf;
    end
    ClusterSize_OneTailed_NN6(iAlpha,1)=ClusterSize;
end

[ClusterSizeTalbe alpha_table11] = output_txt(fullfile(outdir, [outfilename, '_OneTailed_NN18.txt']), ...
    mt12, ft12,...
    iter, nxyz,...
    algor, fwhm_or_acf,...
    maskname, pthr);

for iAlpha=1:length(AlphaLevels)
    Temp=alpha_table11<AlphaLevels(iAlpha);
    TempIndex=find(Temp);
    if ~isempty(TempIndex)
        ClusterSize=ClusterSizeTalbe(TempIndex(1));
    else
        ClusterSize=Inf;
    end
    ClusterSize_OneTailed_NN18(iAlpha,1)=ClusterSize;
end

[ClusterSizeTalbe alpha_table11] = output_txt(fullfile(outdir, [outfilename, '_OneTailed_NN26.txt']), ...
    mt13, ft13,...
    iter, nxyz,...
    algor, fwhm_or_acf,...
    maskname, pthr);

for iAlpha=1:length(AlphaLevels)
    Temp=alpha_table11<AlphaLevels(iAlpha);
    TempIndex=find(Temp);
    if ~isempty(TempIndex)
        ClusterSize=ClusterSizeTalbe(TempIndex(1));
    else
        ClusterSize=Inf;
    end
    ClusterSize_OneTailed_NN26(iAlpha,1)=ClusterSize;
end

% YAN Chao-Gan, 170206. This function could be output now because of the change of including negative values for two tailed.
[ClusterSizeTalbe alpha_table11] = output_txt(fullfile(outdir, [outfilename, '_TwoTailed_NN6.txt']), ...
    mt21, ft21,...
    iter, nxyz,...
    algor, fwhm_or_acf,...
    maskname, pthr);

for iAlpha=1:length(AlphaLevels)
    Temp=alpha_table11<AlphaLevels(iAlpha);
    TempIndex=find(Temp);
    if ~isempty(TempIndex)
        ClusterSize=ClusterSizeTalbe(TempIndex(1));
    else
        ClusterSize=Inf;
    end
    ClusterSize_TwoTailed_NN6(iAlpha,1)=ClusterSize;
end

[ClusterSizeTalbe alpha_table11] = output_txt(fullfile(outdir, [outfilename, '_TwoTailed_NN18.txt']), ...
    mt22, ft22,...
    iter, nxyz,...
    algor, fwhm_or_acf,...
    maskname, pthr);

for iAlpha=1:length(AlphaLevels)
    Temp=alpha_table11<AlphaLevels(iAlpha);
    TempIndex=find(Temp);
    if ~isempty(TempIndex)
        ClusterSize=ClusterSizeTalbe(TempIndex(1));
    else
        ClusterSize=Inf;
    end
    ClusterSize_TwoTailed_NN18(iAlpha,1)=ClusterSize;
end

[ClusterSizeTalbe alpha_table11] = output_txt(fullfile(outdir, [outfilename, '_TwoTailed_NN26.txt']), ...
    mt23, ft23,...
    iter, nxyz,...
    algor, fwhm_or_acf,...
    maskname, pthr);

for iAlpha=1:length(AlphaLevels)
    Temp=alpha_table11<AlphaLevels(iAlpha);
    TempIndex=find(Temp);
    if ~isempty(TempIndex)
        ClusterSize=ClusterSizeTalbe(TempIndex(1));
    else
        ClusterSize=Inf;
    end
    ClusterSize_TwoTailed_NN26(iAlpha,1)=ClusterSize;
end





function [ClusterSizeTalbe alpha_table11] = output_txt(outputname, mt11, ft11, iter, nxyz, algor, fwhm_or_acf, maskname, pthr)
divisor=iter*nxyz;

g_max_cluster_size11 = find(mt11, 1, 'last' );
total_num_clusters11 = sum(ft11);
prob_table11=zeros(1,g_max_cluster_size11);
alpha_table11=zeros(1,g_max_cluster_size11);
cum_prop_table11=zeros(1,g_max_cluster_size11);
ClusterSizeTalbe=[1:g_max_cluster_size11]'; %YAN Chao-Gan, 170206
for i = 1:g_max_cluster_size11
      prob_table11(i) = i * ft11(i) / divisor;
      alpha_table11(i) = mt11(i) / iter;
      cum_prop_table11(i) = ft11(i) / total_num_clusters11;
end
for i = 1:g_max_cluster_size11-1
      j = g_max_cluster_size11 - i +1;
      prob_table11(j-1) = prob_table11(j)+prob_table11(j-1);
      alpha_table11(j-1) = alpha_table11(j)+alpha_table11(j-1);
      cum_prop_table11(i+1) = cum_prop_table11(i)+cum_prop_table11(i+1);
end

if ~strcmp(outputname(1),'_') %YAN Chao-Gan, 170206. If the outfilename is empty, they will not output text files.
    fid=fopen(outputname,'w');
    if(fid)
        if all(fwhm_or_acf == 4.55)
            fwhm_or_acf=[4, 4, 4];
        end
        fprintf(fid,'Mask filename = %s\n',maskname);
        fprintf(fid,'Voxels in mask = %d\n',nxyz);
        if strcmpi(algor, 'fwhm')
            fprintf(fid,...
                'Gaussian filter width (FWHM, in mm) = [%.3f, %.3f, %.3f]\n',...
                fwhm_or_acf(1), fwhm_or_acf(2), fwhm_or_acf(3));
        else % acf
            
        end
        fprintf(fid,'Individual voxel threshold probability = %.3f\n',pthr);
        fprintf(fid,'Number of Monte Carlo simulations = %d\n\n\n',iter);
        
        fprintf(fid,'Cl Size\tFrequency\tCum Prop\tp/Voxel\tMax Freq\tAlpha\n');
        for i=1:g_max_cluster_size11
            fprintf(fid,'%d\t\t%d\t\t%f\t%f\t%d\t\t%f\n',i,ft11(i),cum_prop_table11(i),prob_table11(i),mt11(i),alpha_table11(i));
        end
        fclose(fid);
    end
end


function Q=gauss_filter(s,P,VOX)
if length(s) == 1; s = [s s s];end 
s  = s./VOX;					% voxel anisotropy
s  = max(s,ones(size(s)));			% lower bound on FWHM
s  = s/sqrt(8*log(2));				% FWHM -> Gaussian parameter

x  = round(6*s(1)); x = [-x:x];
y  = round(6*s(2)); y = [-y:y];
z  = round(6*s(3)); z = [-z:z];
x  = exp(-(x).^2/(2*(s(1)).^2)); 
y  = exp(-(y).^2/(2*(s(2)).^2)); 
z  = exp(-(z).^2/(2*(s(3)).^2));
x  = x/sum(x);
y  = y/sum(y);
z  = z/sum(z);

i  = (length(x) - 1)/2;
j  = (length(y) - 1)/2;
k  = (length(z) - 1)/2;
Q=P;
spm_conv_vol(P,Q,x,y,z,-[i,j,k]);
