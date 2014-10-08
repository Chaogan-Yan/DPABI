function y_AlphaSim(maskfile,outdir,outname,rmm,s,pthr,iter)
%   y_AlphaSim(maskfile,outdir,outname,rmm,s,pthr,iter)
%   Monte Carlo simulation program similar to the AlphaSim in AFNI.
%   The mechanism is based on AFNI's AlphaSim, please see more details from http://afni.nimh.nih.gov/pub/dist/doc/manual/AlphaSim.pdf
%------------------------------------------------------------------------------------------------------------------------------
%   Input:
%       maskfile - The image file indicate which voxels to analyze.
%       outdir   - The path to save the result file.
%       outname  - The filename of the result file.
%       rmm      - Cluster connection radius (mm).
%       s        - Gaussian filter width (FWHM, in mm).
%       pthr     - Individual voxel threshold probability
%       iter     - Number of Monte Carlo simulations.
%   Output:
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
dvoxel=max(voxdim);

outfilename=outname;
outfile=strcat(outdir,filesep,outfilename,'.txt');
if s == 4
    s = 4.55;  %afni 4 : spm 4.55 
end
if rmm <= dvoxel*sqrt(2)
    connect= 6; 
else if rmm <= dvoxel*sqrt(3)
        connect =18;
     else
        connect =26;  %Revised by YAN Chao-Gan 091215. Fixed the error when rmm=6. %connect =27 ;
     end
end

ft=zeros(1,VariableLine);   
mt=zeros(1,VariableLine);   
count=nx*ny*nz; % Katharina Wittfeld, fixed to the number of voxels in the whole volume
%suma=0;        % Katharina Wittfeld, not needed if estimation of mean and sd is done seperately for every iteration 
%sumsq=0;       % Katharina Wittfeld, not needed if estimation of mean and sd is done seperately for every iteration 

for nt=1:iter
    foneimt=zeros(1,VariableLine); 
    %fim=normrnd(0,1,nx,ny,nz);
    fim=randn(nx,ny,nz);  	% Katharina Wittfeld, alternative version without the use of the Statistic Toolbox, before: fim=normrnd(0,1,nx,ny,nz); 

    %fim = fim.*mask;       % Katharina Wittfeld, will be down later in the script
    if s ~= 0
      fim = gauss_filter(s,fim,voxdim); 
    end
    fimca=reshape(fim,1,[]);
    %count=count+nxyz;      % Katharina Wittfeld, count is fixed now to the number of voxels in the volume
    suma=sum(fimca);        % Katharina Wittfeld, before: suma=sum(fimca)+suma;
    sumsq=sum(fimca.*fimca);    % Katharina Wittfeld, before: sumsq=sum(fimca.*fimca)+sumsq;
    mean=suma/count;
    sd = sqrt((sumsq - (suma * suma)/count) / (count-1));
    
    %zthr =norminv(1 - pthr);
    zthr=-sqrt(2) * erfcinv((1-pthr)*2); % Katharina Wittfeld, alternative version without the use of the Statistic Toolbox, before: zthr =norminv(1 - pthr);

    xthr=sd*zthr+mean;
    
    %fim(fim<=xthr)=0;  
    %fim(fim>xthr)=1;
    % Katharina Wittfeld ('safe' version, could be a problem if xthr<0 otherwise (don't know if this would be possible))
    fim2=fim;
    fim2(fim<=xthr)=0;      
    fim2(fim>xthr)=1;
    fim=fim2;
    
    fim = fim.*mask; 		% Katharina Wittfeld, apply mask 
    
    a=numel(find(fim==1))/nxyz;
    %[theCluster, theCount] =bwlabeln(fim, connect);
    
    [theCluster, theCount] = spm_bwlabel(fim, connect); % Katharina Wittfeld, alternative version without use of the Imaging processing toolbox, before: [theCluster, theCount] =bwlabeln(fim, connect);
    
    %for i=1:theCount
    %    foneimt(numel(find(theCluster==i)))=foneimt(numel(find(theCluster==i)))+1;
    %end
    %for i=1:theCount
    %    ft(numel(find(theCluster==i)))=ft(numel(find(theCluster==i)))+1;
    %end
    
    % Katharina Wittfeld (joined the loops)
    for i=1:theCount
        numCluster_i=numel(find(theCluster==i));
        foneimt(numCluster_i)=foneimt(numCluster_i)+1;
        ft(numCluster_i)=ft(numCluster_i)+1;
    end
    
    mt(find(foneimt, 1, 'last' ))=mt(find(foneimt, 1, 'last' ))+1;
    fprintf('iter=%d  pvoxel=%f zthr=%f mc=%d mean=%f\n',nt,a,xthr,find(foneimt, 1, 'last' ),mean);
end
g_max_cluster_size = find(mt, 1, 'last' );
total_num_clusters = sum(ft);
divisor=iter*nxyz;
prob_table=zeros(1,g_max_cluster_size);
alpha_table=zeros(1,g_max_cluster_size);
cum_prop_table=zeros(1,g_max_cluster_size);
for i = 1:g_max_cluster_size
      prob_table(i) = i * ft(i) / divisor;
      alpha_table(i) = mt(i) / iter;
      cum_prop_table(i) = ft(i) / total_num_clusters;
end
for i = 1:g_max_cluster_size-1
      j = g_max_cluster_size - i +1;
      prob_table(j-1) = prob_table(j)+prob_table(j-1);
      alpha_table(j-1) = alpha_table(j)+alpha_table(j-1);
      cum_prop_table(i+1) = cum_prop_table(i)+cum_prop_table(i+1);
end


fid=fopen(sprintf('%s',outfile),'w');
 if(fid)
     if s == 4.55
         s=4;
     end
     fprintf(fid,'AlphaSim\nMonte Carlo simulation program similar to the AlphaSim in AFNI\nBy YAN Chao-Gan (ycg.yan@gmail.com).\nThe mechanism is based on AFNI''s AlphaSim, please see more details from http://afni.nimh.nih.gov/pub/dist/doc/manual/AlphaSim.pdf\nState Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875\n\n\n');
     
     fprintf(fid,'Mask filename = %s\n',maskname);
     fprintf(fid,'Voxels in mask = %d\n',nxyz);
     fprintf(fid,'Gaussian filter width (FWHM, in mm) = %.3f\n',s);
     fprintf(fid,'Cluster connection radius: rmm = %.2f\n',rmm);
     fprintf(fid,'Individual voxel threshold probability = %.3f\n',pthr);
     fprintf(fid,'Number of Monte Carlo simulations = %d\n',iter);
     fprintf(fid,'Output filename = %s\n\n\n',outfilename);
   
     fprintf(fid,'Cl Size\tFrequency\tCum Prop\tp/Voxel\tMax Freq\tAlpha\n');
     for i=1:g_max_cluster_size
         fprintf(fid,'%d\t\t%d\t\t%f\t%f\t%d\t\t%f\n',i,ft(i),cum_prop_table(i),prob_table(i),mt(i),alpha_table(i));
     end
     fclose(fid);
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
