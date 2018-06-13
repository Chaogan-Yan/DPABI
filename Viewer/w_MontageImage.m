function [Image, Space]=w_MontageImage(IndexM, type, curfig, flag) 
% Written by Xindi WANG
% State Key Laboratory of Cognitive Neuroscience and Learning & IDG/McGovern 
% Institute for Brain Research, Beijing Normal University, Beijing, China
% sandywang.rest@gmail.com
%==========================================================================

if ~exist('flag','var')
    flag='Normal';
end
IndexM=flipdim(IndexM, 1);

global st
bb=st{curfig}.bb;
Dims = round(diff(bb)'+1);
Space = st{curfig}.Space;

switch upper(type)
    case 'T'
        R=Dims(2)*size(IndexM, 1);
        L=Dims(1)*size(IndexM, 2);
    case 'C'
        R=Dims(3)*size(IndexM, 1);
        L=Dims(1)*size(IndexM, 2);
    case 'S'
        if st{curfig}.mode == 0
            R=Dims(2)*size(IndexM, 1);
            L=Dims(3)*size(IndexM, 2);
        else
            R=Dims(3)*size(IndexM, 1);
            L=Dims(2)*size(IndexM, 2);
        end
end
if isfield(st{curfig}.vols{1},'blobs')
    Image=zeros(R, L, 3);
else
    Image=zeros(R, L);
end

if strcmpi(flag, 'Init')
    return;
end

i=1;
for index=1:numel(IndexM)
    [y, x]=ind2sub(size(IndexM), index);
    slice=IndexM(y, x);
    if isinf(slice)
        continue;
    end
    is=inv(st{curfig}.Space);
    
    switch upper(type)
        case 'T'
            cent = is(1:3,1:3)*[0;0;slice] + is(1:3,4);
            M = st{curfig}.Space\st{curfig}.vols{1}.premul*st{curfig}.vols{1}.mat;
            AM0 = [ 1 0 0 -bb(1,1)+1
                    0 1 0 -bb(1,2)+1
                    0 0 1 -cent(3)
                    0 0 0 1];
            AM = inv(AM0*M);
            AD = Dims([1 2]);
        case 'C'
            cent = is(1:3,1:3)*[0;slice;0] + is(1:3,4);
            M = st{curfig}.Space\st{curfig}.vols{1}.premul*st{curfig}.vols{1}.mat;
            AM0 = [ 1 0 0 -bb(1,1)+1
                    0 0 1 -bb(1,3)+1
                    0 1 0 -cent(2)
                    0 0 0 1];
            AM = inv(AM0*M);
            AD = Dims([1 3]);
        case 'S'
            cent = is(1:3,1:3)*[slice;0;0] + is(1:3,4);
            M = st{curfig}.Space\st{curfig}.vols{1}.premul*st{curfig}.vols{1}.mat;
            if st{curfig}.mode ==0
                AM0 = [ 0 0 1 -bb(1,3)+1
                        0 1 0 -bb(1,2)+1
                        1 0 0 -cent(1)
                        0 0 0 1];
                AM = inv(AM0*M); 
                AD = Dims([3 2]);
            else
                AM0 = [ 0 -1 0 +bb(2,2)+1
                        0  0 1 -bb(1,3)+1
                        1  0 0 -cent(1)
                        0  0 0 1];
                AM = inv(AM0*M);
                AD = Dims([2 3]);
            end
    end
    
    try
        %Revised by YAN Chao-Gan, 130720. Could also work with Data has been read into memory other than only depending on the file.
        if ~isfield(st{curfig}.vols{1},'Data')
            imga = spm_slice_vol(st{curfig}.vols{1},AM,AD,st{curfig}.hld)';
        else   %Revised by YAN Chao-Gan, 130720. Could also work with Data has been read into memory other than only depending on the file.
            imga = spm_slice_vol(st{curfig}.vols{1}.Data,AM,AD,st{curfig}.hld)';
        end
        
        ok   = true;
    catch
        fprintf('Cannot access file "%s".\n', st{curfig}.vols{1}.fname);
        fprintf('%s\n',getfield(lasterror,'message'));
        ok   = false;
    end
    if ok
        % get min/max threshold
        if strcmp(st{curfig}.vols{1}.window,'auto')
            mn = -Inf;
            mx = Inf;
        else
            mn = min(st{curfig}.vols{1}.window);
            mx = max(st{curfig}.vols{1}.window);
        end
        % threshold images
        imga = max(imga,mn); imgt = min(imga,mx);
        % compute intensity mapping, if histeq is available
        if license('test','image_toolbox') == 0
            st{curfig}.vols{1}.mapping = 'linear';
        end
        switch st{curfig}.vols{1}.mapping
            case 'linear'
            case 'histeq'
                % scale images to a range between 0 and 1
                imga1=(imga-min(imga(:)))/(max(imga(:)-min(imga(:)))+eps);
                img  = histeq(imga1(:),1024);
                imga = reshape(img(1:numel(imga1)),size(imga1));
                mn = 0;
                mx = 1;
            case 'quadhisteq'
                % scale images to a range between 0 and 1
                imga1=(imga-min(imga(:)))/(max(imga(:)-min(imga(:)))+eps);
                img  = histeq(imga1(:).^2,1024);
                imga = reshape(img(1:numel(imga1)),size(imga1));
                mn = 0;
                mx = 1;
            case 'loghisteq'
                sw = warning('off','MATLAB:log:logOfZero');
                imga = log(imga-min(imga(:)));
                warning(sw);
                imga(~isfinite(imga)) = 0;
                % scale log images to a range between 0 and 1
                imga1=(imga-min(imga(:)))/(max(imga(:)-min(imga(:)))+eps);
                img  = histeq(imga1(:),1024);
                imga = reshape(img(1:numel(imga1)),size(imga1));
                mn = 0;
                mx = 1;
        end
        % recompute min/max for display
        if strcmp(st{curfig}.vols{1}.window,'auto')
            mx = -inf; mn = inf;
        end
        %Add by Sandy, make the same mn/mx in a volume
        if ~isfield(st{curfig}.vols{1},'Data')
            if ~isempty(imga)
                tmp = imgt(isfinite(imga));
                mx = max([mx max(max(tmp))]);
                mn = min([mn min(min(tmp))]);
            end
        else
            mx=max(max(max(st{curfig}.vols{1}.Data)));
            mn=min(min(min(st{curfig}.vols{1}.Data)));
        end
        if mx==mn, mx=mn+eps; end
        
        if isfield(st{curfig}.vols{1},'blobs')
            if isstruct(st{curfig}.vols{i}.blobs{1}.colour)
                % Add blobs for display using a defined colourmap
                
                % colourmaps
                gryc = (0:63)'*ones(1,3)/63;
                
                % scale grayscale image, not isfinite -> black
                imga = scaletocmap(imga,mn,mx,gryc,65);

                gryc = [gryc; 0 0 0];

                
%                 mmga = zeros(size(imga));
%                 
%                 %Added by Sandy, 130916. Get Overlay Weight first
%                 for j=1:numel(st{curfig}.vols{1}.blobs)
%                     % get blob weight
%                     vol  = st{curfig}.vols{1}.blobs{j}.vol;
%                     M    = st{curfig}.Space\st{curfig}.vols{1}.premul*st{curfig}.vols{1}.blobs{j}.mat;
%                 
%                     %Revised by YAN Chao-Gan, 130720. Could also work with Data has been read into memory other than only depending on the file.
%                     if ~isfield(vol,'Data')
%                         tmpa = spm_slice_vol(vol,inv(AM0*M),AD,[0 NaN])';
%                     else   %Revised by YAN Chao-Gan, 130720. Could also work with Data has been read into memory other than only depending on the file.
%                         tmpa = spm_slice_vol(vol.Data,inv(AM0*M),AD,[0 NaN])';
%                     end
%                     mmga = mmga + (tmpa~=0);
%                 end
%                 
%                 mmga(mmga>0)=1./mmga(mmga>0);
%                 mmga=repmat(mmga(:),1,3);
%                 umpa=zeros(size(mmga));
%                 ompa=zeros(size(mmga));
%                 
%                 for j=1:numel(st{curfig}.vols{i}.blobs)
%                     actc = st{curfig}.vols{1}.blobs{j}.colour.cmap;
%                     actp = 1-st{curfig}.Transparency;
%                     % get max for blob image
%                     if isfield(st{curfig}.vols{1}.blobs{j},'max')
%                         cmx = st{curfig}.vols{1}.blobs{j}.max;
%                     else
%                         cmx = max([eps maxval(st{curfig}.vols{1}.blobs{j}.vol)]);
%                     end
%                     if isfield(st{curfig}.vols{1}.blobs{j},'min')
%                         cmn = st{curfig}.vols{1}.blobs{j}.min;
%                     else
%                         cmn = -cmx;
%                     end
%                     
%                     % get blob data
%                     vol  = st{curfig}.vols{1}.blobs{j}.vol;
%                     M    = st{curfig}.Space\st{curfig}.vols{1}.premul*st{curfig}.vols{1}.blobs{j}.mat;
%                 
%                     %Revised by YAN Chao-Gan, 130720. Could also work with Data has been read into memory other than only depending on the file.
%                     if ~isfield(vol,'Data')
%                         tmpa = spm_slice_vol(vol,inv(AM0*M),AD,[0 NaN])';
%                     else   %Revised by YAN Chao-Gan, 130720. Could also work with Data has been read into memory other than only depending on the file.
%                         tmpa = spm_slice_vol(vol.Data,inv(AM0*M),AD,[0 NaN])';
%                     end
%                 
%                 
%                     % actimg scaled round 0, black NaNs
%                     topc = size(actc,1)+1;
%                     tmpa = scaletocmap(tmpa,cmn,cmx,actc,topc);
%               
%                     %Except Underlay
%                     umpa = umpa+repmat((tmpa(:)~=topc),1,3);
%                 
%                     actc = [actc; 0 0 0];
%                 
%                     ompa = ompa+actc(tmpa(:),:).*mmga;
%                 end
%                 
%                 umpa=umpa==0;
                
                
                % combine gray and blob data to
                % truecolour
                
                %Modified by Sandy for Multi-Overlay 20140104
                umpa=ones(size(imga));
                umpa=repmat(umpa(:),1,3);
                ompa=zeros(size(umpa));
                for j=1:numel(st{curfig}.vols{i}.blobs)
                    actc = st{curfig}.vols{i}.blobs{j}.colour.cmap;
                    actp = st{curfig}.vols{i}.blobs{j}.colour.prop;
                    % get max for blob image
                    if isfield(st{curfig}.vols{i}.blobs{j},'max')
                        cmx = st{curfig}.vols{i}.blobs{j}.max;
                    else
                        cmx = max([eps maxval(st{curfig}.vols{i}.blobs{j}.vol)]);
                    end
                    if isfield(st{curfig}.vols{i}.blobs{j},'min')
                        cmn = st{curfig}.vols{i}.blobs{j}.min;
                    else
                        cmn = -cmx;
                    end
                    
                    % get blob data
                    vol  = st{curfig}.vols{i}.blobs{j}.vol;
                    M    = st{curfig}.Space\st{curfig}.vols{i}.premul*st{curfig}.vols{i}.blobs{j}.mat;
                
                    %Revised by YAN Chao-Gan, 130720. Could also work with Data has been read into memory other than only depending on the file.
                    if ~isfield(vol,'Data')
                        tmpa = spm_slice_vol(vol,inv(AM0*M),AD,[0 NaN])';
                    else   %Revised by YAN Chao-Gan, 130720. Could also work with Data has been read into memory other than only depending on the file.
                        tmpa = spm_slice_vol(vol.Data,inv(AM0*M),AD,[0 NaN])';
                    end
                
                
                    % actimg scaled round 0, black NaNs
                    topc = size(actc,1)+1;
                    tmpa = scaletocmap(tmpa,cmn,cmx,actc,topc);
              
                    %Overlay Transparent Weight
                    jmpa = actp*repmat((tmpa(:)~=topc),1,3);
                    
                    %Except Underlay
                    umpa = umpa-jmpa;
                    
                    %Negtive Weight Recoup
                    nmpa = umpa.*(umpa<0);
                    
                    %Modified Overlay Transparent Weight
                    jmpa=jmpa+nmpa;
                    
                    actc = [actc; 0 0 0];
                
                    ompa = ompa+jmpa.*actc(tmpa(:),:);
                    
                    umpa(umpa<0) = 0;
                end      
                imga = reshape(ompa+gryc(imga(:),:).*umpa, [size(imga) 3]);
                Image(AD(2)*(y-1)+1:AD(2)*y, AD(1)*(x-1)+1:AD(1)*x, :)=imga;
            end
        else
            scal = 64/(mx-mn);
            dcoff = -mn*scal;
            imga = imga*scal+dcoff;
            Image(AD(2)*(y-1)+1:AD(2)*y, AD(1)*(x-1)+1:AD(1)*x)=imga;
        end        
    end
end


function img = scaletocmap(inpimg,mn,mx,cmap,miscol)
if nargin < 5, miscol=1; end
cml = size(cmap,1);
scf = (cml-1)/(mx-mn);
img = round((inpimg-mn)*scf)+1;
img(img<1)   = 1; 
img(img>cml) = cml;
img(inpimg==0) = miscol; %Added by YAN Chao-Gan 130609, mask out the 0 voxels.
img(~isfinite(img)) = miscol;