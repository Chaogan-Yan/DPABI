function varargout = y_spm_orthviews(action,varargin)
% Display orthogonal views of a set of images
% FORMAT H = y_spm_orthviews('Image',filename[,position])
% filename - name of image to display
% area     - position of image {relative}
%            [left, bottom, width, height]
% H        - handle for orthogonal sections
%
% FORMAT y_spm_orthviews('Reposition',centre)
% centre   - X, Y & Z coordinates of centre voxel
%
% FORMAT y_spm_orthviews('Space'[,handle[,M,dim]])
% handle   - the view to define the space by, optionally with extra
%            transformation matrix and dimensions (e.g. one of the blobs
%            of a view)
% with no arguments - puts things into mm space
%
% FORMAT H = y_spm_orthviews('Caption', handle, string, [Property, Value])
% handle   - the view to which a caption should be added
% string   - the caption text to add
% optional:  Property-Value pairs, e.g. 'FontWeight', 'Bold'
%
% H        - the handle to the object whose String property has the caption
%
% FORMAT y_spm_orthviews('BB',bb)
% bb       - bounding box
%            [loX loY loZ
%             hiX hiY hiZ]
%
% FORMAT y_spm_orthviews('MaxBB')
% Set the bounding box big enough to display the whole of all images
%
% FORMAT y_spm_orthviews('Resolution'[,res])
% res      - resolution (mm)
% Set the sampling resolution for all images. The effective resolution
% will be the minimum of res and the voxel sizes of all images. If no
% resolution is specified, the minimum of 1mm and the voxel sizes of the
% images is used.
%
% FORMAT y_spm_orthviews('Zoom'[,fov[,res]])
% fov      - half width of field of view (mm)
% res      - resolution (mm)
% Set the displayed part and sampling resolution for all images. The
% image display will be centered at the current crosshair position. The
% image region [xhairs-fov xhairs+fov] will be shown.
% If no argument is given or fov == Inf, the image display will be reset to
% "Full Volume". If fov == 0, the image will be zoomed to the bounding box
% from spm_get_bbox for the non-zero voxels of the image. If fov is NaN,
% then a threshold can be entered, and spm_get_bbox will be used to derive
% the bounding box of the voxels above this threshold.
% Optionally, the display resolution can be set as well.
%
% FORMAT y_spm_orthviews('Redraw')
% Redraw the images
%
% FORMAT y_spm_orthviews('Reload_mats')
% Reload the voxel-world mapping matrices from the headers stored on disk,
% e.g. following reorientation of some images.
%
% FORMAT y_spm_orthviews('Delete', handle)
% handle   - image number to delete
%
% FORMAT y_spm_orthviews('Reset')
% Clear the orthogonal views
%
% FORMAT y_spm_orthviews('Pos')
% Return the co-ordinate of the crosshairs in millimetres in the
% standard space.
%
% FORMAT y_spm_orthviews('Pos', i)
% Return the voxel co-ordinate of the crosshairs in the image in the
% ith orthogonal section.
%
% FORMAT y_spm_orthviews('Xhairs','off') OR y_spm_orthviews('Xhairs')
% Disable the cross-hairs on the display
%
% FORMAT y_spm_orthviews('Xhairs','on')
% Enable the cross-hairs
%
% FORMAT y_spm_orthviews('Interp',hld)
% Set the hold value to hld (see spm_slice_vol)
%
% FORMAT y_spm_orthviews('AddBlobs',handle,XYZ,Z,mat,name)
% Add blobs from a pointlist to the image specified by the handle(s)
% handle   - image number to add blobs to
% XYZ      - blob voxel locations
% Z        - blob voxel intensities
% mat      - matrix from voxels to millimeters of blob.
% name     - a name for this blob
% This method only adds one set of blobs, and displays them using a split
% colour table.
%
% FORMAT y_spm_orthviews('SetBlobsMax', vn, bn, mx)
% Set maximum value for blobs overlay number bn of view number vn to mx.
%
% FORMAT y_spm_orthviews('AddColouredBlobs',handle,XYZ,Z,mat,colour,name)
% Add blobs from a pointlist to the image specified by the handle(s)
% handle   - image number to add blobs to
% XYZ      - blob voxel locations
% Z        - blob voxel intensities
% mat      - matrix from voxels to millimeters of blob.
% colour   - the 3 vector containing the colour that the blobs should be
% name     - a name for this blob
% Several sets of blobs can be added in this way, and it uses full colour.
% Although it may not be particularly attractive on the screen, the colour
% blobs print well.
%
% FORMAT y_spm_orthviews('AddColourBar',handle,blobno)
% Add colourbar for a specified blob set
% handle    - image number
% blobno    - blob number
%
% FORMAT y_spm_orthviews('RemoveBlobs',handle)
% Remove all blobs from the image specified by the handle(s)
%
% FORMAT y_spm_orthviews('Addtruecolourimage',handle,filename,colourmap,prop,mx,mn)
% Add blobs from an image in true colour
% handle    - image number to add blobs to [Default: 1]
% filename  - image containing blob data [Default: GUI input]
% colourmap - colormap to display blobs in [Default: GUI input]
% prop      - intensity proportion of activation cf grayscale [default: 0.4]
% mx        - maximum intensity to scale to [maximum value in activation image]
% mn        - minimum intensity to scale to [minimum value in activation image]
%
% FORMAT y_spm_orthviews('Register',hReg)
% hReg      - Handle of HandleGraphics object to build registry in
% See spm_XYZreg for more information.
%
% FORMAT y_spm_orthviews('AddContext',handle)
% FORMAT y_spm_orthviews('RemoveContext',handle)
% handle    - image number to add/remove context menu to
%
% FORMAT y_spm_orthviews('ZoomMenu',zoom,res)
% FORMAT [zoom, res] = y_spm_orthviews('ZoomMenu')
% zoom      - A list of predefined zoom values
% res       - A list of predefined resolutions
% This list is used by spm_image and y_spm_orthviews('addcontext',...) to
% create the 'Zoom' menu. The values can be retrieved by calling
% y_spm_orthviews('ZoomMenu') with 2 output arguments. Values of 0, NaN and
% Inf are treated specially, see the help for y_spm_orthviews('Zoom' ...).
%__________________________________________________________________________
%
% PLUGINS
% The display capabilities of y_spm_orthviews can be extended with plugins.
% These are located in the y_spm_orthviews subdirectory of the SPM
% distribution.
% The functionality of plugins can be accessed via calls to
% y_spm_orthviews('plugin_name', plugin_arguments). For detailed descriptions
% of each plugin see help y_spm_orthviews/spm_ov_'plugin_name'.
%__________________________________________________________________________
% Copyright (C) 1996-2012 Wellcome Trust Centre for Neuroimaging

% John Ashburner et al
% $Id: y_spm_orthviews.m 5450 2013-04-26 11:25:36Z guillaume $


% The basic fields of st are:
%         n        - the number of images currently being displayed
%         vols     - a cell array containing the data on each of the
%                    displayed images.
%         Space    - a mapping between the displayed images and the
%                    mm space of each image.
%         bb       - the bounding box of the displayed images.
%         centre   - the current centre of the orthogonal views
%         callback - a callback to be evaluated on a button-click.
%         xhairs   - crosshairs off/on
%         hld      - the interpolation method
%         fig      - the figure that everything is displayed in
%         mode     - the position/orientation of the sagittal view.
%                    - currently always 1
%
%         st{curfig}.registry.hReg \_ See spm_XYZreg for documentation
%         st{curfig}.registry.hMe  /
%
% For each of the displayed images, there is a non-empty entry in the
% vols cell array.  Handles returned by "y_spm_orthviews('Image',.....)"
% indicate the position in the cell array of the newly created ortho-view.
% Operations on each ortho-view require the handle to be passed.
%
% When a new image is displayed, the cell entry contains the information
% returned by spm_vol (type help spm_vol for more info).  In addition,
% there are a few other fields, some of which are documented here:
%
%         premul  - a matrix to premultiply the .mat field by.  Useful
%                   for re-orienting images.
%         window  - either 'auto' or an intensity range to display the
%                   image with.
%         mapping - Mapping of image intensities to grey values. Currently
%                   one of 'linear', 'histeq', loghisteq',
%                   'quadhisteq'. Default is 'linear'.
%                   Histogram equalisation depends on the image toolbox
%                   and is only available if there is a license available
%                   for it.
%         ax      - a cell array containing an element for the three
%                   views.  The fields of each element are handles for
%                   the axis, image and crosshairs.
%
%         blobs   - optional.  Is there for using to superimpose blobs.
%                   vol     - 3D array of image data
%                   mat     - a mapping from vox-to-mm (see spm_vol, or
%                             help on image formats).
%                   max     - maximum intensity for scaling to.  If it
%                             does not exist, then images are auto-scaled.
%
%                   There are two colouring modes: full colour, and split
%                   colour.  When using full colour, there should be a
%                   'colour' field for each cell element.  When using
%                   split colourscale, there is a handle for the colorbar
%                   axis.
%
%                   colour  - if it exists it contains the
%                             red,green,blue that the blobs should be
%                             displayed in.
%                   cbar    - handle for colorbar (for split colourscale).
%
% PLUGINS
% The plugin concept has been developed to extend the display capabilities
% of y_spm_orthviews without the need to rewrite parts of it. Interaction
% between y_spm_orthviews and plugins takes place
% a) at startup: The subfunction 'reset_st' looks for folders
%                'y_spm_orthviews' in spm('Dir') and each toolbox
%                folder. Files with a name spm_ov_PLUGINNAME.m in any of
%                these folders will be treated as plugins.
%                For each such file, PLUGINNAME will be added to the list
%                st{curfig}.plugins{:}.
%                The subfunction 'add_context' calls each plugin with
%                feval(['spm_ov_', st{curfig}.plugins{k}], ...
%                  'context_menu', i, parent_menu)
%                Each plugin may add its own submenu to the context
%                menu.
% b) at redraw:  After images and blobs of st{curfig}.vols{i} are drawn, the
%                struct st{curfig}.vols{i} is checked for field names that occur in
%                the plugin list st{curfig}.plugins{:}. For each matching entry, the
%                corresponding plugin is called with the command 'redraw':
%                feval(['spm_ov_', st{curfig}.plugins{k}], ...
%                  'redraw', i, TM0, TD, CM0, CD, SM0, SD);
%                The values of TM0, TD, CM0, CD, SM0, SD are defined in the
%                same way as in the redraw subfunction of y_spm_orthviews.
%                It is up to the plugin to do all necessary redraw
%                operations for its display contents. Each displayed item
%                must have set its property 'HitTest' to 'off' to let events
%                go through to the underlying axis, which is responsible for
%                callback handling. The order in which plugins are called is
%                undefined.
%
%
%
%___________________________________________________________________________
% Revised by YAN Chao-Gan, 130609. 
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com



global st

if nargin>2
    if ishandle(varargin{1})
        curfig=varargin{1};
    elseif all(ishandle(varargin{2}))
        curfig=varargin{2};
    end
else
    curfig=GetCurFig;
end

persistent zoomlist reslist

if isempty(st), reset_st; end

if ~nargin, action = ''; end

if ~any(strcmpi(action,{'reposition','pos'}))
    spm('Pointer','Watch');
end
    
switch lower(action)
    case 'image'
        H = specify_image(varargin{1});
        if ~isempty(H)
            if numel(varargin)>=2
                st{curfig}.vols{H}.area = varargin{2};
            else
                st{curfig}.vols{H}.area = [0 0 1 1];
            end
            if isempty(st{curfig}.bb)
                st{curfig}.bb = maxbb;
            else
                bb=maxbb;
                if ~isempty(find(st{curfig}.bb-bb, 1))
                    st{curfig}.bb=bb;
                    mmcentre     = mean(st{curfig}.Space*[maxbb';1 1],2)';
                    st{curfig}.centre    = mmcentre(1:3);
                end
            end
            resolution;
            bbox;
            cm_pos;
        end
        varargout{1} = curfig;
        if ~isfield(st{curfig}, 'centre')
            mmcentre     = mean(st{curfig}.Space*[maxbb';1 1],2)';
            st{curfig}.centre    = mmcentre(1:3);
        end
        redraw_all

    case 'caption'
        vh = valid_handles(varargin{1});
        nh = numel(vh);
        
        xlh = nan(nh, 1);
        for i = 1:nh
            xlh(i) = get(st{curfig}.vols{vh(i)}.ax{3}.ax, 'XLabel');
            if iscell(varargin{2})
                if i <= length(varargin{2})
                    set(xlh(i), 'String', varargin{2}{i});
                end
            else
                set(xlh(i), 'String', varargin{2});
            end
            for np = 4:2:nargin
                property = varargin{np-1};
                value = varargin{np};
                set(xlh(i), property, value);
            end
        end
        varargout{1} = xlh;
        
    case 'bb'
        if ~isempty(varargin) && all(size(varargin{1})==[2 3]), st{curfig}.bb = varargin{1}; end
        bbox;
        redraw_all;
        
    case 'redraw'
        if nargin < 2
            curfig=GetCurFig;
        else
            curfig=varargin{1};
        end
        redraw_all(curfig);
        eval(st{curfig}.callback);
        if isfield(st{curfig},'registry')
            spm_XYZreg('SetCoords',st{curfig}.centre,st{curfig}.registry.hReg,st{curfig}.registry.hMe);
        end
        
    case 'reload_mats'
        if nargin > 1
            handles = valid_handles(varargin{1});
        else
            handles = valid_handles;
        end
        for i = handles
            fnm = spm_file(st{curfig}.vols{i}.fname, 'number', st{curfig}.vols{i}.n);
            st{curfig}.vols{i}.mat = spm_get_space(fnm);
        end
        % redraw_all (done in y_spm_orthviews('reorient','context_quit'))
        
    case 'reposition'
        if isempty(varargin), tmp = findcent;
        else tmp = varargin{1}; end
        if nargin > 2
            curfig=varargin{2};
        end
        if numel(tmp) == 3
            h = valid_handles(st{curfig}.snap);
            if ~isempty(h)
                tmp = st{curfig}.vols{h(1)}.mat * ...
                    round(st{curfig}.vols{h(1)}.mat\[tmp(:); 1]);
            end
            st{curfig}.centre = tmp(1:3);
        end
        if st{curfig}.yoke
            allfig=curfig;
            for fig=1:numel(st)
                if fig~=curfig
                    if ~isempty(st{fig}) && st{fig}.yoke
                        allfig=[allfig,fig];
                        st{fig}.centre = tmp(1:3);
                    end
                end
            end
        else
            allfig=curfig;
        end
        for fig=allfig
            redraw_all(fig);
            eval(st{fig}.callback);
            if isfield(st{fig},'registry')
                spm_XYZreg('SetCoords',st{fig}.centre,st{fig}.registry.hReg,st{fig}.registry.hMe);
            end
            cm_pos(fig);
        end
        
    case 'setcoords'
        st{curfig}.centre = varargin{1};
        st{curfig}.centre = st{curfig}.centre(:);
        redraw_all;
        eval(st{curfig}.callback);
        cm_pos;
        
    case 'space'
        if numel(varargin) < 1
            st{curfig}.Space = eye(4);
            st{curfig}.bb = maxbb;
            resolution;
            bbox;
            redraw_all;
        else
            space(varargin{:});
            resolution;
            bbox;
            redraw_all;
        end
        
    case 'maxbb'
        st{curfig}.bb = maxbb;
        bbox;
        redraw_all;
        
    case 'resolution'
        resolution(varargin{:});
        bbox;
        redraw_all;
        
    case 'window'
        if numel(varargin)<2
            win = 'auto';
        elseif numel(varargin{2})==2
            win = varargin{2};
        end
        for i=valid_handles(varargin{1})
            st{curfig}.vols{i}.window = win;
        end
        redraw(varargin{1});
        
    case 'delete'
        my_delete(varargin{1});
        
    case 'move'
        move(varargin{1},varargin{2});
        % redraw_all;
        
    case 'reset'
        my_reset;
        
    case 'pos'
        if isempty(varargin)
            H = st{curfig}.centre(:);
        else
            H = pos(varargin{1});
        end
        varargout{1} = H;
        
    case 'interp'
        st{curfig}.hld = varargin{1};
        redraw_all;
        
    case 'xhairs'
        xhairs(varargin{1});
        
    case 'register'
        register(varargin{1});
        
    case 'addblobs'
        addblobs(varargin{:});
        % redraw(varargin{1});
        
    case 'setblobsmax'
        st{curfig}.vols{varargin{1}}.blobs{varargin{2}}.max = varargin{3};
        y_spm_orthviews('redraw')
        
    case 'addcolouredblobs'
        addcolouredblobs(varargin{:});
        % redraw(varargin{1});
        
    case 'addimage'
        addimage(varargin{1}, varargin{2});
        % redraw(varargin{1});
        
    case 'addcolouredimage'
        addcolouredimage(varargin{1}, varargin{2},varargin{3});
        % redraw(varargin{1});
        
    case 'addtruecolourimage'
        if nargin < 2
            varargin(1) = {1};
        end
        if nargin < 3
            varargin(2) = {spm_select(1, 'image', 'Image with activation signal')};
        end
        if nargin < 4
            actc = [];
            while isempty(actc)
                actc = getcmap(spm_input('Colourmap for activation image', '+1','s'));
            end
            varargin(3) = {actc};
        end
        if nargin < 5
            varargin(4) = {0.4};
        end
        if nargin < 6
            actv = spm_vol(varargin{2});
            varargin(5) = {max([eps maxval(actv)])};
        end
        if nargin < 7
            varargin(6) = {min([0 minval(actv)])};
        end
        
        addtruecolourimage(varargin{1}, varargin{2},varargin{3}, varargin{4}, ...
            varargin{5}, varargin{6});
        % redraw(varargin{1});

    case 'settruecolourimage'
        if nargin < 2
            varargin(1) = {1};
        end
        if nargin < 3
            varargin(2) = {spm_select(1, 'image', 'Image with activation signal')};
        end
        if nargin < 4
            actc = [];
            while isempty(actc)
                actc = getcmap(spm_input('Colourmap for activation image', '+1','s'));
            end
            varargin(3) = {actc};
        end
        if nargin < 5
            varargin(4) = {0.4};
        end
        if nargin < 6
            actv = spm_vol(varargin{2});
            varargin(5) = {max([eps maxval(actv)])};
        end
        if nargin < 7
            varargin(6) = {min([0 minval(actv)])};
        end
        
        if nargin < 8
            varargin(7) = 1;
        end
        
        settruecolourimage(varargin{1}, varargin{2},varargin{3}, varargin{4}, ...
            varargin{5}, varargin{6}, varargin{7});
        
    case 'addcolourbar'
        addcolourbar(varargin{1}, varargin{2});
        
    case 'redrawcolourbar'
        curfig=varargin{1};
        bset=varargin{2};
        
        if ~bset
            colormap(gray(64));
            return;
        end
        
        mn=st{curfig}.vols{1}.blobs{bset}.min;
        mx=st{curfig}.vols{1}.blobs{bset}.max;
        
        csz   = size(st{curfig}.vols{1}.blobs{bset}.colour.cmap);
        cdata = reshape(st{curfig}.vols{1}.blobs{bset}.colour.cmap, [csz(1) 1 csz(2)]);
        
        redraw_colourbar(1, bset, [mn, mx], cdata);
        
    case {'removeblobs','rmblobs'}
        rmblobs(varargin{1});
        % redraw(varargin{1});
        
    case 'addcontext'
        if nargin == 1
            handles = 1:max_img;
        else
            handles = varargin{1};
        end
        addcontexts(handles);
        
    case {'removecontext','rmcontext'}
        if nargin == 1
            handles = 1:max_img;
        else
            handles = varargin{1};
        end
        rmcontexts(handles);
        
    case 'context_menu'
        c_menu(varargin{:});
        
    case 'valid_handles'
        if nargin == 1
            handles = 1:max_img;
        else
            handles = varargin{1};
        end
        varargout{1} = valid_handles(handles);

    case 'zoom'
        zoom_op(varargin{:});
        
    case 'zoommenu'
        if isempty(zoomlist)
            zoomlist = [NaN 0 5    10  20 40 80 Inf];
            reslist  = [1   1 .125 .25 .5 .5 1  1  ];
        end
        if nargin >= 3
            if all(cellfun(@isnumeric,varargin(1:2))) && ...
                    numel(varargin{1})==numel(varargin{2})
                zoomlist = varargin{1}(:);
                reslist  = varargin{2}(:);
            else
                warning('y_spm_orthviews:zoom',...
                        'Invalid zoom or resolution list{curfig}.')
            end
        end
        if nargout > 0
            varargout{1} = zoomlist;
        end
        if nargout > 1
            varargout{2} = reslist;
        end
        
    otherwise
        addonaction = strcmpi(st{curfig}.plugins,action);
        if any(addonaction)
            feval(['w_spm_ov_' st{curfig}.plugins{addonaction}],varargin{:});
        end
end

spm('Pointer','Arrow');


%==========================================================================
% function H = specify_image(img)
%==========================================================================
function H = specify_image(img)
global st
curfig=GetCurFig;

H = [];
if isstruct(img)
    V = img(1);
else
    try
        V = spm_vol(img);
    catch
        fprintf('Can not use image "%s"\n', img);
        return;
    end
end
if numel(V)>1, V=V(1); end

ii = 1;
while ~isempty(st{curfig}.vols{ii}), ii = ii + 1; end

if isfield(st{curfig}.vols{1}, 'ax')
    VField=fieldnames(V);
    for n=1:size(VField, 1)
        st{curfig}.vols{1}.(VField{n})=V.(VField{n});
    end
    st{curfig}.bb=[];
    H=1;
    return;
end

handles=guidata(st{curfig}.fig);
if ~isfield(handles, 'DPABI_fig'); %Compatibility matlab2014b    
    DeleteFcn = ['y_spm_orthviews(''Delete'',' num2str(ii) ');'];
else
    DeleteFcn = '';
end
V.ax = cell(3,1);
for i=1:3
    ax = axes('Visible','on', 'Parent',st{curfig}.fig, ... % 'DrawMode','fast', 
        'YDir','normal', 'DeleteFcn',DeleteFcn, 'ButtonDownFcn',@repos_start);
    d  = image(0, 'Tag','Transverse', 'Parent',ax, 'DeleteFcn',DeleteFcn);
    set(ax, 'Ydir','normal', 'ButtonDownFcn',@repos_start);
    
    lx = line(0,0, 'Parent',ax, 'DeleteFcn',DeleteFcn);
    ly = line(0,0, 'Parent',ax, 'DeleteFcn',DeleteFcn);
    if ~st{curfig}.xhairs
        set(lx, 'Visible','off');
        set(ly, 'Visible','off');
    end
    axis(ax, 'image');
    V.ax{i} = struct('ax',ax,'d',d,'lx',lx,'ly',ly);
end
V.premul    = eye(4);
V.window    = 'auto';
V.mapping   = 'linear';
st{curfig}.vols{ii} = V;

H = ii;


%==========================================================================
% function addblobs(handle, xyz, t, mat, name)
%==========================================================================
function addblobs(handle, xyz, t, mat, name)
global st
curfig=GetCurFig;
if nargin < 5
    name = '';
end
for i=valid_handles(handle)
    if ~isempty(xyz)
        rcp      = round(xyz);
        dim      = max(rcp,[],2)';
        off      = rcp(1,:) + dim(1)*(rcp(2,:)-1 + dim(2)*(rcp(3,:)-1));
        vol      = zeros(dim)+NaN;
        vol(off) = t;
        vol      = reshape(vol,dim);
        st{curfig}.vols{i}.blobs=cell(1,1);
        mx = max([eps max(t)]);
        mn = min([0 min(t)]);
        st{curfig}.vols{i}.blobs{1} = struct('vol',vol,'mat',mat,'max',mx, 'min',mn,'name',name);
        addcolourbar(handle,1);
    end
end


%==========================================================================
% function addimage(handle, fname)
%==========================================================================
function addimage(handle, fname)
global st
curfig=GetCurFig;
for i=valid_handles(handle)
    if isstruct(fname)
        vol = fname(1);
    else
        vol = spm_vol(fname);
    end
    mat = vol.mat;
    st{curfig}.vols{i}.blobs=cell(1,1);
    mx = max([eps maxval(vol)]);
    mn = min([0 minval(vol)]);
    st{curfig}.vols{i}.blobs{1} = struct('vol',vol,'mat',mat,'max',mx,'min',mn);
    addcolourbar(handle,1);
end


%==========================================================================
% function addcolouredblobs(handle, xyz, t, mat, colour, name)
%==========================================================================
function addcolouredblobs(handle, xyz, t, mat, colour, name)
if nargin < 6
    name = '';
end
global st
curfig=GetCurFig;
for i=valid_handles(handle)
    if ~isempty(xyz)
        rcp      = round(xyz);
        dim      = max(rcp,[],2)';
        off      = rcp(1,:) + dim(1)*(rcp(2,:)-1 + dim(2)*(rcp(3,:)-1));
        vol      = zeros(dim)+NaN;
        vol(off) = t;
        vol      = reshape(vol,dim);
        if ~isfield(st{curfig}.vols{i},'blobs')
            st{curfig}.vols{i}.blobs=cell(1,1);
            bset = 1;
        else
            bset = numel(st{curfig}.vols{1}.blobs)+1;
        end
        mx = max([eps maxval(vol)]);
        mn = min([0 minval(vol)]);
        st{curfig}.vols{1}.blobs{bset} = struct('vol',vol, 'mat',mat, ...
            'max',mx, 'min',mn, 'colour',colour, 'name',name);
    end
end


%==========================================================================
% function addcolouredimage(handle, fname,colour)
%==========================================================================
function addcolouredimage(handle, fname,colour)
global st
curfig=GetCurFig;
for i=valid_handles(handle)
    if isstruct(fname)
        vol = fname(1);
    else
        vol = spm_vol(fname);
    end
    mat = vol.mat;
    if ~isfield(st{curfig}.vols{i},'blobs')
        st{curfig}.vols{i}.blobs=cell(1,1);
        bset = 1;
    else
        bset = numel(st{curfig}.vols{i}.blobs)+1;
    end
    mx = max([eps maxval(vol)]);
    mn = min([0 minval(vol)]);
    st{curfig}.vols{i}.blobs{bset} = struct('vol',vol, 'mat',mat, ...
        'max',mx, 'min',mn, 'colour',colour);
end


%==========================================================================
% function addtruecolourimage(handle,fname,colourmap,prop,mx,mn)
%==========================================================================
function addtruecolourimage(curfig,fname,colourmap,prop,mx,mn)
% adds true colour image to current displayed image
global st
%Remove loop by Sandy
%for i=valid_handles(handle)
if isstruct(fname)
    vol = fname(1);
else
    vol = spm_vol(fname);
end
mat = vol.mat;
if ~isfield(st{curfig}.vols{1},'blobs')
    st{curfig}.vols{1}.blobs=cell(1,1);
    bset = 1;
else
    bset = numel(st{curfig}.vols{1}.blobs)+1;
end

c = struct('cmap', colourmap,'prop',prop);
st{curfig}.vols{1}.blobs{bset} = struct('vol',vol, 'mat',mat, ...
    'max',mx, 'min',mn, 'colour',c);
addcolourbar(1,bset);
st{curfig}.curblob=bset;

%Add by Sandy to change colourbar when add overlay
if ~isfield(st{curfig}.vols{1}.blobs{bset},'colour')
    cmap = get(st{curfig}.fig,'Colormap');
    if size(cmap,1)~=128
        figure(st{curfig}.fig)
        spm_figure('Colormap','gray-hot')
    end
    redraw_colourbar(1,bset,[mn mx],(1:64)'+64);
elseif isstruct(st{curfig}.vols{1}.blobs{bset}.colour)
    csz   = size(st{curfig}.vols{1}.blobs{bset}.colour.cmap);
    cdata = reshape(st{curfig}.vols{1}.blobs{bset}.colour.cmap, [csz(1) 1 csz(2)]);
    redraw_colourbar(1,bset,[mn mx],cdata);
end
%end

%==========================================================================
% function settruecolourimage(handle,fname,colourmap,prop,mx,mn)
%==========================================================================
function settruecolourimage(curfig,fname,colourmap,prop,mx,mn,bset)
% set true colour image to current displayed image Add by Sandy
global st

if isstruct(fname)
    vol = fname(1);
else
    vol = spm_vol(fname);
end
mat = vol.mat;

c = struct('cmap', colourmap,'prop',prop);
st{curfig}.vols{1}.blobs{bset} = struct('vol',vol, 'mat',mat, ...
    'max',mx, 'min',mn, 'colour',c);
addcolourbar(1, bset, curfig);
st{curfig}.curblob=bset;
if ~isfield(st{curfig}.vols{1}.blobs{bset},'colour')
    cmap = get(st{curfig}.fig,'Colormap');
    if size(cmap,1)~=128
        figure(st{curfig}.fig)
        spm_figure('Colormap','gray-hot')
    end
    redraw_colourbar(1,bset,[mn mx],(1:64)'+64,curfig);
elseif isstruct(st{curfig}.vols{1}.blobs{bset}.colour)
    csz   = size(st{curfig}.vols{1}.blobs{bset}.colour.cmap);
    cdata = reshape(st{curfig}.vols{1}.blobs{bset}.colour.cmap, [csz(1) 1 csz(2)]);
    redraw_colourbar(1,bset,[mn mx],cdata,curfig);
end
st{curfig}.weight=zeros(size(st{curfig}.vols{1}.blobs{1}.vol.Data));

%==========================================================================
% function addcolourbar(vh,bh)
%==========================================================================
function addcolourbar(vh,bh,curfig)
global st
if nargin < 3 
    curfig=GetCurFig;
end
if st{curfig}.mode == 0,
    axpos = get(st{curfig}.vols{vh}.ax{2}.ax,'Position');
else
    axpos = get(st{curfig}.vols{vh}.ax{1}.ax,'Position');
end
handles=guidata(st{curfig}.fig);
if ~isfield(handles, 'DPABI_fig');
    st{curfig}.vols{vh}.blobs{bh}.cbar = axes('Parent',st{curfig}.fig,...
        'Position',[(axpos(1)+axpos(3)+0.05+(bh-1)*.1) (axpos(2)+0.005) 0.05 (axpos(4)-0.01)],...
        'Box','on', 'YDir','normal', 'XTickLabel',[], 'XTick',[]);
else
    st{curfig}.vols{vh}.blobs{bh}.cbar = handles.ColorAxe;
end
if isfield(st{curfig}.vols{vh}.blobs{bh},'name')
    ylabel(st{curfig}.vols{vh}.blobs{bh}.name,'parent',st{curfig}.vols{vh}.blobs{bh}.cbar);
end

%==========================================================================
% function rmblobs(handle)
%==========================================================================
function rmblobs(handle)
global st
curfig=GetCurFig;
%Remove loop by Sandy
if isfield(st{curfig}.vols{1},'blobs')
    handles=guidata(st{curfig}.fig);
    if ~isfield(handles, 'DPABI_fig');
        for j=1:numel(st{curfig}.vols{1}.blobs)
            if isfield(st{curfig}.vols{1}.blobs{j},'cbar') && ishandle(st{curfig}.vols{1}.blobs{j}.cbar),
                delete(st{curfig}.vols{1}.blobs{j}.cbar);
            end
        end
    end
    st{curfig}.vols{1} = rmfield(st{curfig}.vols{1},'blobs');
end
st{curfig}.curblob=0;


%==========================================================================
% function register(hreg)
%==========================================================================
function register(hreg)
global st
curfig=GetCurFig;
%tmp = uicontrol('Position',[0 0 1 1],'Visible','off','Parent',st{curfig}.fig);
h   = valid_handles;
if ~isempty(h)
    tmp = st{curfig}.vols{h(1)}.ax{1}.ax;
    st{curfig}.registry = struct('hReg',hreg,'hMe', tmp);
    spm_XYZreg('Add2Reg',st{curfig}.registry.hReg,st{curfig}.registry.hMe, 'y_spm_orthviews');
else
    warning('Nothing to register with');
end
st{curfig}.centre = spm_XYZreg('GetCoords',st{curfig}.registry.hReg);
st{curfig}.centre = st{curfig}.centre(:);


%==========================================================================
% function xhairs(state)
%==========================================================================
function xhairs(state)
global st
curfig=GetCurFig;
st{curfig}.xhairs = 0;
opt = 'on';
if ~strcmpi(state,'on')
    opt = 'off';
else
    st{curfig}.xhairs = 1;
end
for i=valid_handles
    for j=1:3
        set(st{curfig}.vols{i}.ax{j}.lx,'Visible',opt);
        set(st{curfig}.vols{i}.ax{j}.ly,'Visible',opt);
    end
end


%==========================================================================
% function H = pos(handle)
%==========================================================================
function H = pos(handle)
global st
curfig=GetCurFig;
H = [];
for i=valid_handles(handle)
    is = inv(st{curfig}.vols{i}.premul*st{curfig}.vols{i}.mat);
    H = is(1:3,1:3)*st{curfig}.centre(:) + is(1:3,4);
end


%==========================================================================
% function my_reset
%==========================================================================
function my_reset
global st
curfig=GetCurFig;
if ~isempty(st{curfig}) && isfield(st{curfig},'registry') && ishandle(st{curfig}.registry.hMe)
    delete(st{curfig}.registry.hMe); st = rmfield(st,'registry');
end
my_delete(curfig);
reset_st;


%==========================================================================
% function my_delete(handle)
%==========================================================================
function my_delete(handle)
global st
curfig=GetCurFig;
% remove blobs (and colourbars, if any)
if ~isempty(st{curfig}) %YAN Chao-Gan, 161006. For MATLAB2016b compatibility.
    rmblobs(handle);
    % remove displayed axes
    % Remove loop by Sandy
    kids = get(st{curfig}.fig,'Children');
    for j=1:3
        try
            if any(kids == st{curfig}.vols{1}.ax{j}.ax)
                set(get(st{curfig}.vols{1}.ax{j}.ax,'Children'),'DeleteFcn','');
                delete(st{curfig}.vols{1}.ax{j}.ax);
            end
        end
    end
    st{curfig}.vols{1} = [];
    st{curfig}=[];
end

%==========================================================================
% function resolution(res)
%==========================================================================
function resolution(res)
global st
curfig=GetCurFig;
if ~nargin, res = 1; end % Default minimum resolution 1mm
for i=valid_handles
    % adapt resolution to smallest voxel size of displayed images
    res  = min([res,sqrt(sum((st{curfig}.vols{i}.mat(1:3,1:3)).^2))]);
end
res      = res/mean(svd(st{curfig}.Space(1:3,1:3)));
Mat      = diag([res res res 1]);
st{curfig}.Space = st{curfig}.Space*Mat;
st{curfig}.bb    = st{curfig}.bb/res;


%==========================================================================
% function move(handle,pos)
%==========================================================================
function move(handle,pos)
global st
curfig=GetCurFig;
for i=valid_handles(handle)
    st{curfig}.vols{i}.area = pos;
end
bbox;
% redraw(valid_handles(handle));


%==========================================================================
% function bb = maxbb
%==========================================================================
function bb = maxbb
global st
curfig=GetCurFig;
mn = [Inf Inf Inf];
mx = -mn;
for i=valid_handles
    premul = st{curfig}.Space \ st{curfig}.vols{i}.premul;
    bb = spm_get_bbox(st{curfig}.vols{i}, 'fv', premul);
    mx = max([bb ; mx]);
    mn = min([bb ; mn]);
end
bb = [mn ; mx];


%==========================================================================
% function space(handle,M,dim)
%==========================================================================
function space(handle,M,dim)
global st
curfig=GetCurFig;
if ~isempty(st{curfig}.vols{handle})
    if nargin < 2
        M = st{curfig}.vols{handle}.mat;
        dim = st{curfig}.vols{handle}.dim(1:3);
    end
    Mat   = st{curfig}.vols{handle}.premul(1:3,1:3)*M(1:3,1:3);
    vox   = sqrt(sum(Mat.^2));
    if det(Mat(1:3,1:3))<0, vox(1) = -vox(1); end
    Mat   = diag([vox 1]);
    Space = (M)/Mat;
    bb    = [1 1 1; dim];
    bb    = [bb [1;1]];
    bb    = bb*Mat';
    bb    = bb(:,1:3);
    bb    = sort(bb);
    st{curfig}.Space = Space;
    st{curfig}.bb = bb;
end


%==========================================================================
% function zoom_op(fov,res)
%==========================================================================
function zoom_op(fov,res)
global st
curfig=GetCurFig;
if nargin < 1, fov = Inf; end
if nargin < 2, res = Inf; end

if isinf(fov)
    st{curfig}.bb = maxbb;
elseif isnan(fov) || fov == 0
    current_handle = valid_handles;
    if numel(current_handle) > 1 % called from check reg context menu
        current_handle = get_current_handle;
    end
    if fov == 0
        % zoom to bounding box of current image ~= 0
        thr = 'nz';
    else
        % zoom to bounding box of current image > chosen threshold
        thr = spm_input('Threshold (Y > ...)', '+1', 'r', '0', 1);
    end
    premul = st{curfig}.Space \ st{curfig}.vols{current_handle}.premul;
    st{curfig}.bb = spm_get_bbox(st{curfig}.vols{current_handle}, thr, premul);
else
    vx    = sqrt(sum(st{curfig}.Space(1:3,1:3).^2));
    vx    = vx.^(-1);
    pos   = y_spm_orthviews('pos');
    pos   = st{curfig}.Space\[pos ; 1];
    pos   = pos(1:3)';
    st{curfig}.bb = [pos-fov*vx; pos+fov*vx];
end
resolution(res);
bbox;
redraw_all;
if isfield(st{curfig}.vols{1},'sdip')
    spm_eeg_inv_vbecd_disp('RedrawDip');
end


%==========================================================================
% function repos_start(varargin)
% function repos_move(varargin)
% function repos_end(varargin)
%==========================================================================
function repos_start(varargin)
% don't use right mouse button to start reposition
if ~strcmpi(get(gcbf,'SelectionType'),'alt')
    set(gcbf,'windowbuttonmotionfcn',@repos_move, 'windowbuttonupfcn',@repos_end);
    y_spm_orthviews('reposition');
end

function repos_move(varargin)
y_spm_orthviews('reposition');

function repos_end(varargin)
set(gcbf,'windowbuttonmotionfcn','', 'windowbuttonupfcn','');


%==========================================================================
% function bbox
%==========================================================================
function bbox
global st
curfig=GetCurFig;
Dims = diff(st{curfig}.bb)'+1;

TD = Dims([1 2])';
CD = Dims([1 3])';
if st{curfig}.mode == 0, SD = Dims([3 2])'; else SD = Dims([2 3])'; end
%Add by Sandy for DPABI_VIEW call
handles=guidata(st{curfig}.fig);
if ~isfield(handles, 'DPABI_fig');
    un    = get(st{curfig}.fig,'Units');set(st{curfig}.fig,'Units','Pixels');
    sz    = get(st{curfig}.fig,'Position');set(st{curfig}.fig,'Units',un);
    sz    = sz(3:4);
    sz(1) = sz(1);
    sz(2) = sz(2);
else
    un    = get(handles.ViewFrame,'Units');set(handles.ViewFrame,'Units','Pixels');
    sz    = get(handles.ViewFrame,'Position');set(handles.ViewFrame,'Units',un);
    
    offxy = sz(1:2);
    sz    = sz(3:4);
end

for i=valid_handles
    area   = st{curfig}.vols{i}.area(:);
    area   = [area(1)*sz(1) area(2)*sz(2) area(3)*sz(1) area(4)*sz(2)];
    if st{curfig}.mode == 0
        sx = area(3)/(Dims(1)+Dims(3))/1.02;
    else
        sx = area(3)/(Dims(1)+Dims(2))/1.02;
    end
    sy     = area(4)/(Dims(2)+Dims(3))/1.02;
    s      = min([sx sy]);
    
    offy   = (area(4)-(Dims(2)+Dims(3))*1.02*s)/2 + area(2);
    sky    = s*(Dims(2)+Dims(3))*0.02;
    if st{curfig}.mode == 0
        offx = (area(3)-(Dims(1)+Dims(3))*1.02*s)/2 + area(1);
        skx  = s*(Dims(1)+Dims(3))*0.02;
    else
        offx = (area(3)-(Dims(1)+Dims(2))*1.02*s)/2 + area(1);
        skx  = s*(Dims(1)+Dims(2))*0.02;
    end
    
    if isfield(handles, 'DPABI_fig');
        offx=offx+offxy(1);
        offy=offy+offxy(2);
    end
    
    % Transverse
    set(st{curfig}.vols{i}.ax{1}.ax,'Units','pixels', ...
        'Position',[offx offy s*Dims(1) s*Dims(2)],...
        'Units','normalized','Xlim',[0 TD(1)]+0.5,'Ylim',[0 TD(2)]+0.5,...
        'Visible','on','XTick',[],'YTick',[]);
    
    % Coronal
    set(st{curfig}.vols{i}.ax{2}.ax,'Units','Pixels',...
        'Position',[offx offy+s*Dims(2)+sky s*Dims(1) s*Dims(3)],...
        'Units','normalized','Xlim',[0 CD(1)]+0.5,'Ylim',[0 CD(2)]+0.5,...
        'Visible','on','XTick',[],'YTick',[]);
    
    % Sagittal
    if st{curfig}.mode == 0
        set(st{curfig}.vols{i}.ax{3}.ax,'Units','Pixels', 'Box','on',...
            'Position',[offx+s*Dims(1)+skx offy s*Dims(3) s*Dims(2)],...
            'Units','normalized','Xlim',[0 SD(1)]+0.5,'Ylim',[0 SD(2)]+0.5,...
            'Visible','on','XTick',[],'YTick',[]);
    else
        set(st{curfig}.vols{i}.ax{3}.ax,'Units','Pixels', 'Box','on',...
            'Position',[offx+s*Dims(1)+skx offy+s*Dims(2)+sky s*Dims(2) s*Dims(3)],...
            'Units','normalized','Xlim',[0 SD(1)]+0.5,'Ylim',[0 SD(2)]+0.5,...
            'Visible','on','XTick',[],'YTick',[]);
    end
end


%==========================================================================
% function mx = maxval(vol)
%==========================================================================
function mx = maxval(vol)
if isstruct(vol)
    mx = -Inf;
    for i=1:vol.dim(3)
        
        if ~isfield(vol,'Data')
            tmp = spm_slice_vol(vol,spm_matrix([0 0 i]),vol.dim(1:2),0);
        else   %Revised by YAN Chao-Gan, 130720. Could also work with Data has been read into memory other than only depending on the file.
            tmp = spm_slice_vol(vol.Data,spm_matrix([0 0 i]),vol.dim(1:2),0);
        end
        
        
        imx = max(tmp(isfinite(tmp)));
        if ~isempty(imx), mx = max(mx,imx); end
    end
else
    mx = max(vol(isfinite(vol)));
end


%==========================================================================
% function mn = minval(vol)
%==========================================================================
function mn = minval(vol)
if isstruct(vol)
    mn = Inf;
    for i=1:vol.dim(3)
        
        if ~isfield(vol,'Data')
            tmp = spm_slice_vol(vol,spm_matrix([0 0 i]),vol.dim(1:2),0);
        else   %Revised by YAN Chao-Gan, 130720. Could also work with Data has been read into memory other than only depending on the file.
            tmp = spm_slice_vol(vol.Data,spm_matrix([0 0 i]),vol.dim(1:2),0);
        end
        
        
        imn = min(tmp(isfinite(tmp)));
        if ~isempty(imn), mn = min(mn,imn); end
    end
else
    mn = min(vol(isfinite(vol)));
end


%==========================================================================
% function redraw(arg1)
%==========================================================================
function redraw(fig)
global st
for curfig=fig

bb   = st{curfig}.bb;
%Add by Sandy for DPABI_VIEW call

handles=guidata(st{curfig}.fig);
if isfield(handles, 'DPABI_fig')
    X=st{curfig}.centre(1);
    if X<=bb(1,1)
        X=bb(1,1);
        set(handles.XReduceBtn, 'Enable', 'Off');
        set(handles.IAddBtn, 'Enable', 'Off');
    else
        set(handles.XReduceBtn, 'Enable', 'On');
        set(handles.IAddBtn, 'Enable', 'On');
    end
    if X>=bb(2,1)
        X=bb(2,1);
        set(handles.XAddBtn, 'Enable', 'Off');
        set(handles.IReduceBtn, 'Enable', 'Off');
    else
        set(handles.XAddBtn, 'Enable', 'On');
        set(handles.IReduceBtn, 'Enable', 'On');
    end
    
    Y=st{curfig}.centre(2);
    if Y<=bb(1,2)
        Y=bb(1,2);
        set(handles.YReduceBtn, 'Enable', 'Off');
        set(handles.JReduceBtn, 'Enable', 'Off');
    else
        set(handles.YReduceBtn, 'Enable', 'On');
        set(handles.JReduceBtn, 'Enable', 'On');
    end
    if Y>=bb(2,2)
        Y=bb(2,2);
        set(handles.YAddBtn, 'Enable', 'Off');
        set(handles.JAddBtn, 'Enable', 'Off');
    else
        set(handles.YAddBtn, 'Enable', 'On');
        set(handles.JAddBtn, 'Enable', 'On');
    end
    
    Z=st{curfig}.centre(3); 
    if Z<=bb(1,3)
        Z=bb(1,3);
        set(handles.ZReduceBtn, 'Enable', 'Off');
        set(handles.KReduceBtn, 'Enable', 'Off');
    else
        set(handles.ZReduceBtn, 'Enable', 'On');
        set(handles.KReduceBtn, 'Enable', 'On');
    end
    if Z>=bb(2,3)
        Z=bb(2,3);
        set(handles.ZAddBtn, 'Enable', 'Off');
        set(handles.KAddBtn, 'Enable', 'Off');
    else
        set(handles.ZAddBtn, 'Enable', 'On');
        set(handles.KAddBtn, 'Enable', 'On');
    end
    
    set(handles.XEntry,...
        'String', sprintf('%d', round(X)));
    set(handles.YEntry,...
        'String', sprintf('%d', round(Y)));
    set(handles.ZEntry,...
        'String', sprintf('%d', round(Z)));
    
    tmp=inv(st{curfig}.vols{1}.mat)*[X;Y;Z;1];
    I=round(tmp(1));
    J=round(tmp(2));
    K=round(tmp(3));
    
    AString={};
    if ~isempty(st{curfig}.AtlasInfo)
        for idx=1:numel(st{curfig}.AtlasInfo)
            AStruct=st{curfig}.AtlasInfo{idx};
            AMat=AStruct.Template.mat;
            APos=round(inv(AMat)*[X;Y;Z;1]);
            AI=APos(1);
            AJ=APos(2);
            AK=APos(3);
            try
                AIndex=AStruct.Template.Data(AI, AJ, AK);
            catch
                AIndex=0;
            end
            AName=AStruct.Template.Alias;
            ALab =cellfun(@(x) isequal(x, AIndex),...
                AStruct.Reference(:, 2));
            if any(ALab)
                ARegion=AStruct.Reference{ALab, 1};
            else
                ARegion='None';
            end
            AString{numel(AString)+1, 1}=...
                sprintf('%d) %s:\n->%s\n**\n', idx, AName, ARegion);
        end
    end
    
    set(handles.AtlasEntry, 'String', AString);
    
    if isfield(st{curfig}.vols{1}, 'blobs')
        curblob=st{curfig}.curblob;
        tmp=inv(st{curfig}.vols{1}.blobs{curblob}.vol.mat)*[X;Y;Z;1];
        OI=round(tmp(1));
        OJ=round(tmp(2));
        OK=round(tmp(3));

        set(handles.IEntry, 'String', sprintf('%d', OI));
        set(handles.JEntry, 'String', sprintf('%d', OJ));
        set(handles.KEntry, 'String', sprintf('%d', OK));
        try 
            OverlayValue=st{curfig}.vols{1}.blobs{curblob}.vol.Data(OI,OJ,OK);
        catch
            OverlayValue=0;
        end
        set(handles.OverlayValue, 'String',...
            sprintf('%g', OverlayValue));
        TCFlag=st{curfig}.TCFlag;
        if ~isempty(TCFlag)
            if ~ishandle(TCFlag)
                st{curfig}.TCFlag=0;
                if isfield(st{curfig}, 'TCLinObj')
                    st{curfig}=rmfield(st{curfig}, 'TCLinObj');
                end
            else
                TCHandle=guidata(TCFlag);
                Headers=TCHandle.Headers;
                TCAxe=TCHandle.TCAxe;
                if ~isfield(st{curfig}, 'TCLinObj') || ...
                    isempty(st{curfig}.TCLinObj{1}) || ...    
                    ~ishandle(st{curfig}.TCLinObj{1})
                    st{curfig}.TCLinObj=cell(numel(Headers), 1);
                end
                set(TCHandle.CoordFrame, 'Title',...
                    sprintf('Coordinate: X=%+d, Y=%+d, Z=%+d; I=%d, J=%d, K=%d',...
                    round(X), round(Y), round(Z), OI, OJ, OK))
                
                for i=1:numel(Headers)
                    if ~isempty(Headers{i})
                        tmp=inv(Headers{i}.mat)*[X;Y;Z;1];
                        TCI=round(tmp(1));
                        TCJ=round(tmp(2));
                        TCK=round(tmp(3));
                        try
                            TC=squeeze(Headers{i}.Raw(TCI,TCJ,TCK,:));
                        catch
                            TC=zeros(size(Headers{i}.Raw, 4), 1);
                        end
                        
                        if get(TCHandle.FrequencyButton, 'Value')
                            TR=str2double(get(TCHandle.TREntry, 'String'));
                            TNum=length(TC);
                            Pad=2^nextpow2(TNum);
                            
                            TC=TC-mean(TC);
                            AM=2*abs(fft(TC, Pad))/TNum;
                            AMP=(1:length(AM))';
                            AMP=(AMP-1)/(Pad*TR);
                            TC=AM(1:ceil(length(AM)/2)+1);
                            TCP=AMP(1:ceil(length(AMP)/2)+1);
                        else
                            TCP=(1:size(Headers{i}.Raw, 4))';
                        end
                        
                        if ~isempty(st{curfig}.TCLinObj{i})
                            set(st{curfig}.TCLinObj{i}, 'XData', TCP);
                            set(st{curfig}.TCLinObj{i}, 'YData', TC);
                        else
                            lin_obj=plot(TCAxe, TCP, TC);
                            legend(lin_obj, Headers{i}.fname, ...
                                'Location', 'NorthOutside');
                            st{curfig}.TCLinObj{i}=lin_obj;
                        end
                    end
                end
            end
        end
    else
        set(handles.IEntry, 'String', sprintf('%d', I));
        set(handles.JEntry, 'String', sprintf('%d', J));
        set(handles.KEntry, 'String', sprintf('%d', K));        
        set(handles.OverlayValue, 'String', '0');
    end
    try
        UnderlayValue=st{curfig}.vols{1}.Data(I,J,K);
    catch
        UnderlayValue=0;
    end
    set(handles.UnderlayValue, 'String',...
        sprintf('%g', UnderlayValue));
    
    MPFlag=st{curfig}.MPFlag;
    if ~isempty(MPFlag)
        for m=1:numel(MPFlag)
            if ~isempty(st{curfig}.MPFlag{m}) && ishandle(st{curfig}.MPFlag{m})
                w_Montage('RedrawXhairs', curfig, MPFlag{m});
            end
        end
    end
end

Dims = round(diff(bb)'+1);
is   = inv(st{curfig}.Space);
cent = is(1:3,1:3)*st{curfig}.centre(:) + is(1:3,4);

%for i = valid_handles(arg1) Remove loop by Sandy
    i=1;
    M = st{curfig}.Space\st{curfig}.vols{i}.premul*st{curfig}.vols{i}.mat;
    TM0 = [ 1 0 0 -bb(1,1)+1
            0 1 0 -bb(1,2)+1
            0 0 1 -cent(3)
            0 0 0 1];
    TM = inv(TM0*M);
    TD = Dims([1 2]);
    
    CM0 = [ 1 0 0 -bb(1,1)+1
            0 0 1 -bb(1,3)+1
            0 1 0 -cent(2)
            0 0 0 1];
    CM = inv(CM0*M);
    CD = Dims([1 3]);
    
    if st{curfig}.mode ==0
        SM0 = [ 0 0 1 -bb(1,3)+1
                0 1 0 -bb(1,2)+1
                1 0 0 -cent(1)
                0 0 0 1];
        SM = inv(SM0*M); 
        SD = Dims([3 2]);
    else
        SM0 = [ 0 -1 0 +bb(2,2)+1
                0  0 1 -bb(1,3)+1
                1  0 0 -cent(1)
                0  0 0 1];
        SM = inv(SM0*M);
        SD = Dims([2 3]);
    end
    
    try
        
        %Revised by YAN Chao-Gan, 130720. Could also work with Data has been read into memory other than only depending on the file.
        if ~isfield(st{curfig}.vols{i},'Data')
            imgt = spm_slice_vol(st{curfig}.vols{i},TM,TD,st{curfig}.hld)';
            imgc = spm_slice_vol(st{curfig}.vols{i},CM,CD,st{curfig}.hld)';
            imgs = spm_slice_vol(st{curfig}.vols{i},SM,SD,st{curfig}.hld)';
        else   %Revised by YAN Chao-Gan, 130720. Could also work with Data has been read into memory other than only depending on the file.
            imgt = spm_slice_vol(st{curfig}.vols{i}.Data,TM,TD,st{curfig}.hld)';
            imgc = spm_slice_vol(st{curfig}.vols{i}.Data,CM,CD,st{curfig}.hld)';
            imgs = spm_slice_vol(st{curfig}.vols{i}.Data,SM,SD,st{curfig}.hld)';
        end
        
        ok   = true;
    catch
        fprintf('Cannot access file "%s".\n', st{curfig}.vols{i}.fname);
        fprintf('%s\n',getfield(lasterror,'message'));
        ok   = false;
    end
    if ok
        % get min/max threshold
        if strcmp(st{curfig}.vols{i}.window,'auto')
            mn = -Inf;
            mx = Inf;
        else
            mn = min(st{curfig}.vols{i}.window);
            mx = max(st{curfig}.vols{i}.window);
        end
        % threshold images
        imgt = max(imgt,mn); imgt = min(imgt,mx);
        imgc = max(imgc,mn); imgc = min(imgc,mx);
        imgs = max(imgs,mn); imgs = min(imgs,mx);
        % compute intensity mapping, if histeq is available
        if license('test','image_toolbox') == 0
            st{curfig}.vols{i}.mapping = 'linear';
        end
        switch st{curfig}.vols{i}.mapping
            case 'linear'
            case 'histeq'
                % scale images to a range between 0 and 1
                imgt1=(imgt-min(imgt(:)))/(max(imgt(:)-min(imgt(:)))+eps);
                imgc1=(imgc-min(imgc(:)))/(max(imgc(:)-min(imgc(:)))+eps);
                imgs1=(imgs-min(imgs(:)))/(max(imgs(:)-min(imgs(:)))+eps);
                img  = histeq([imgt1(:); imgc1(:); imgs1(:)],1024);
                imgt = reshape(img(1:numel(imgt1)),size(imgt1));
                imgc = reshape(img(numel(imgt1)+(1:numel(imgc1))),size(imgc1));
                imgs = reshape(img(numel(imgt1)+numel(imgc1)+(1:numel(imgs1))),size(imgs1));
                mn = 0;
                mx = 1;
            case 'quadhisteq'
                % scale images to a range between 0 and 1
                imgt1=(imgt-min(imgt(:)))/(max(imgt(:)-min(imgt(:)))+eps);
                imgc1=(imgc-min(imgc(:)))/(max(imgc(:)-min(imgc(:)))+eps);
                imgs1=(imgs-min(imgs(:)))/(max(imgs(:)-min(imgs(:)))+eps);
                img  = histeq([imgt1(:).^2; imgc1(:).^2; imgs1(:).^2],1024);
                imgt = reshape(img(1:numel(imgt1)),size(imgt1));
                imgc = reshape(img(numel(imgt1)+(1:numel(imgc1))),size(imgc1));
                imgs = reshape(img(numel(imgt1)+numel(imgc1)+(1:numel(imgs1))),size(imgs1));
                mn = 0;
                mx = 1;
            case 'loghisteq'
                sw = warning('off','MATLAB:log:logOfZero');
                imgt = log(imgt-min(imgt(:)));
                imgc = log(imgc-min(imgc(:)));
                imgs = log(imgs-min(imgs(:)));
                warning(sw);
                imgt(~isfinite(imgt)) = 0;
                imgc(~isfinite(imgc)) = 0;
                imgs(~isfinite(imgs)) = 0;
                % scale log images to a range between 0 and 1
                imgt1=(imgt-min(imgt(:)))/(max(imgt(:)-min(imgt(:)))+eps);
                imgc1=(imgc-min(imgc(:)))/(max(imgc(:)-min(imgc(:)))+eps);
                imgs1=(imgs-min(imgs(:)))/(max(imgs(:)-min(imgs(:)))+eps);
                img  = histeq([imgt1(:); imgc1(:); imgs1(:)],1024);
                imgt = reshape(img(1:numel(imgt1)),size(imgt1));
                imgc = reshape(img(numel(imgt1)+(1:numel(imgc1))),size(imgc1));
                imgs = reshape(img(numel(imgt1)+numel(imgc1)+(1:numel(imgs1))),size(imgs1));
                mn = 0;
                mx = 1;
        end
        % recompute min/max for display
        if strcmp(st{curfig}.vols{i}.window,'auto')
            mx = -inf; mn = inf;
        end
        %Add by Sandy, make the same mn/mx in a volume
        if ~isfield(st{curfig}.vols{i},'Data')
            if ~isempty(imgt)
                tmp = imgt(isfinite(imgt));
                mx = max([mx max(max(tmp))]);
            mn = min([mn min(min(tmp))]);
            end
            if ~isempty(imgc)
                tmp = imgc(isfinite(imgc));
                mx = max([mx max(max(tmp))]);
                mn = min([mn min(min(tmp))]);
            end
            if ~isempty(imgs)
                tmp = imgs(isfinite(imgs));
                mx = max([mx max(max(tmp))]);
                mn = min([mn min(min(tmp))]);
            end
        else
            if ~isfield(st{curfig}.vols{i},'mx')
                mx=max(max(max(st{curfig}.vols{i}.Data)));
            else
                mx=st{curfig}.vols{i}.mx;
            end
            
            if ~isfield(st{curfig}.vols{i},'mn')
                mn=min(min(min(st{curfig}.vols{i}.Data)));
            else
                mn=st{curfig}.vols{i}.mn;
            end
        end
        
        if mx==mn, mx=mn+eps; end
        
        if isfield(st{curfig}.vols{i},'blobs')
            j=1;
            if ~isfield(st{curfig}.vols{i}.blobs{j},'colour')
                % Add blobs for display using the split colourmap
                scal = 64/(mx-mn);
                dcoff = -mn*scal;
                imgt = imgt*scal+dcoff;
                imgc = imgc*scal+dcoff;
                imgs = imgs*scal+dcoff;
                
                if isfield(st{curfig}.vols{i}.blobs{j},'max')
                    mx = st{curfig}.vols{i}.blobs{j}.max;
                else
                    mx = max([eps maxval(st{curfig}.vols{i}.blobs{j}.vol)]);
                    st{curfig}.vols{i}.blobs{j}.max = mx;
                end
                if isfield(st{curfig}.vols{i}.blobs{j},'min')
                    mn = st{curfig}.vols{i}.blobs{j}.min;
                else
                    mn = min([0 minval(st{curfig}.vols{i}.blobs{j}.vol)]);
                    st{curfig}.vols{i}.blobs{j}.min = mn;
                end
                
                vol  = st{curfig}.vols{i}.blobs{j}.vol;
                M    = st{curfig}.Space\st{curfig}.vols{i}.premul*st{curfig}.vols{i}.blobs{j}.mat;
                
                %Revised by YAN Chao-Gan, 130720. Could also work with Data has been read into memory other than only depending on the file.
                if ~isfield(vol,'Data')
                    tmpt = spm_slice_vol(vol,inv(TM0*M),TD,[0 NaN])';
                    tmpc = spm_slice_vol(vol,inv(CM0*M),CD,[0 NaN])';
                    tmps = spm_slice_vol(vol,inv(SM0*M),SD,[0 NaN])';
                else   %Revised by YAN Chao-Gan, 130720. Could also work with Data has been read into memory other than only depending on the file.
                    tmpt = spm_slice_vol(vol.Data,inv(TM0*M),TD,[0 NaN])';
                    tmpc = spm_slice_vol(vol.Data,inv(CM0*M),CD,[0 NaN])';
                    tmps = spm_slice_vol(vol.Data,inv(SM0*M),SD,[0 NaN])';
                end
                
                %tmpt_z = find(tmpt==0);tmpt(tmpt_z) = NaN;
                %tmpc_z = find(tmpc==0);tmpc(tmpc_z) = NaN;
                %tmps_z = find(tmps==0);tmps(tmps_z) = NaN;
                
                sc   = 64/(mx-mn);
                off  = 65.51-mn*sc;
                msk  = find(isfinite(tmpt)); imgt(msk) = off+tmpt(msk)*sc;
                msk  = find(isfinite(tmpc)); imgc(msk) = off+tmpc(msk)*sc;
                msk  = find(isfinite(tmps)); imgs(msk) = off+tmps(msk)*sc;
                
            elseif isstruct(st{curfig}.vols{i}.blobs{j}.colour)
                % Add blobs for display using a defined colourmap
                
                % colourmaps
                gryc = (0:63)'*ones(1,3)/63;
                
                % scale grayscale image, not isfinite -> black
                imgt = scaletocmap(imgt,mn,mx,gryc,65);
                imgc = scaletocmap(imgc,mn,mx,gryc,65);
                imgs = scaletocmap(imgs,mn,mx,gryc,65);
                gryc = [gryc; 0 0 0];

               
                %Modified by Sandy for Multi-Overlay 20140104
                umpt=ones(size(imgt));
                umpc=ones(size(imgc));
                umps=ones(size(imgs));
                umpt=repmat(umpt(:),1,3);
                umpc=repmat(umpc(:),1,3);
                umps=repmat(umps(:),1,3);
                ompt=zeros(size(umpt));
                ompc=zeros(size(umpc));
                omps=zeros(size(umps));
                
                if isfield(handles, 'DPABI_fig')
                    if ~isempty(st{curfig}.SSFlag) && ishandle(st{curfig}.SSFlag)
                        SSFlag=st{curfig}.SSFlag;
                        SSHandle=guidata(SSFlag);
                        IsPreview=get(SSHandle.PreviewBtn, 'Value');
                        if IsPreview
                            AtlasIdx=get(SSHandle.StructuralPopup, 'Value');
                            AStruct=st{curfig}.AtlasInfo{AtlasIdx};
                            vol=AStruct.Template;
                            M=st{curfig}.Space\st{curfig}.vols{i}.premul*vol.mat;

                            AMat=AStruct.Template.mat;
                            APos=round(inv(AMat)*[X;Y;Z;1]);
                            AI=APos(1);
                            AJ=APos(2);
                            AK=APos(3);
            
                            AIndex=AStruct.Template.Data(AI, AJ, AK);
                                
                            if AIndex
                                SSactc=AStruct.Template.CMap;
                                SSactp=0.8;
                                
                                Mask=double(AStruct.Template.Data==AIndex);
                                SStopc = size(SSactc,1)+1;
                                
                                tmpt = spm_slice_vol(Mask,inv(TM0*M),TD,[0 NaN])';
                                tmpc = spm_slice_vol(Mask,inv(CM0*M),CD,[0 NaN])';
                                tmps = spm_slice_vol(Mask,inv(SM0*M),SD,[0 NaN])';
                   
                                tmpt = scaletocmap(tmpt, 0, 1, SSactc, SStopc);
                                tmpc = scaletocmap(tmpc, 0, 1, SSactc, SStopc);
                                tmps = scaletocmap(tmps, 0, 1, SSactc, SStopc);
                                
                                jmpt = SSactp*repmat((tmpt(:)~=SStopc),1,3);
                                jmpc = SSactp*repmat((tmpc(:)~=SStopc),1,3);
                                jmps = SSactp*repmat((tmps(:)~=SStopc),1,3);
                                
                                umpt = umpt-jmpt;
                                umpc = umpc-jmpc;
                                umps = umps-jmps;
                    
                                SSactc = [SSactc; 0 0 0];
                
                                ompt = ompt+jmpt.*SSactc(tmpt(:),:);
                                ompc = ompc+jmpc.*SSactc(tmpc(:),:);
                                omps = omps+jmps.*SSactc(tmps(:),:);           
                            end
                        end
                    else
                        st{curfig}.SSFlag=[];
                    end
                end
                
                curblob=st{curfig}.curblob;
                blobSeq=[curblob:numel(st{curfig}.vols{i}.blobs) 1:curblob-1];
                for j=blobSeq %1:numel(st{curfig}.vols{i}.blobs)
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
                        tmpt = spm_slice_vol(vol,inv(TM0*M),TD,[0 NaN])';
                        tmpc = spm_slice_vol(vol,inv(CM0*M),CD,[0 NaN])';
                        tmps = spm_slice_vol(vol,inv(SM0*M),SD,[0 NaN])';
                    else   %Revised by YAN Chao-Gan, 130720. Could also work with Data has been read into memory other than only depending on the file.
                        tmpt = spm_slice_vol(vol.Data,inv(TM0*M),TD,[0 NaN])';
                        tmpc = spm_slice_vol(vol.Data,inv(CM0*M),CD,[0 NaN])';
                        tmps = spm_slice_vol(vol.Data,inv(SM0*M),SD,[0 NaN])';
                    end
                
                
                    % actimg scaled round 0, black NaNs
                    topc = size(actc,1)+1;
                    tmpt = scaletocmap(tmpt,cmn,cmx,actc,topc);
                    tmpc = scaletocmap(tmpc,cmn,cmx,actc,topc);
                    tmps = scaletocmap(tmps,cmn,cmx,actc,topc);
              
                    %Overlay Transparent Weight
                    jmpt = actp*repmat((tmpt(:)~=topc),1,3);
                    jmpc = actp*repmat((tmpc(:)~=topc),1,3);
                    jmps = actp*repmat((tmps(:)~=topc),1,3);
                    
                    %Except Underlay
                    umpt = umpt-jmpt;
                    umpc = umpc-jmpc;
                    umps = umps-jmps;
                    
                    %Negtive Weight Recoup
                    nmpt = umpt.*(umpt<0);
                    nmpc = umpc.*(umpc<0);
                    nmps = umps.*(umps<0);
                    
                    %Modified Overlay Transparent Weight
                    jmpt=jmpt+nmpt;
                    jmpc=jmpc+nmpc;
                    jmps=jmps+nmps;
                    
                    actc = [actc; 0 0 0];
                
                    ompt = ompt+jmpt.*actc(tmpt(:),:);
                    ompc = ompc+jmpc.*actc(tmpc(:),:);
                    omps = omps+jmps.*actc(tmps(:),:);
                    
                    umpt(umpt<0) = 0;
                    umpc(umpc<0) = 0;
                    umps(umps<0) = 0;
                end      
%                 if isfield(handles, 'DPABI_fig') && IsPreview
%                     SSactc=AStruct.Template.CMap;
%                     M = st{curfig}.Space\st{curfig}.vols{i}.premul*AStruct.Template.mat;
%                     
%                     
%                     tmpt = spm_slice_vol(Mask,inv(TM0*M),TD,[0 NaN])';
%                     tmpc = spm_slice_vol(Mask,inv(CM0*M),CD,[0 NaN])';
%                     tmps = spm_slice_vol(Mask,inv(SM0*M),SD,[0 NaN])';
%                     
%                     SStopc = size(SSactc,1)+1;
%                     tmpt = scaletocmap(tmpt, 0, 1, SSactc, SStopc);
%                     tmpc = scaletocmap(tmpc, 0, 1, SSactc, SStopc);
%                     tmps = scaletocmap(tmps, 0, 1, SSactc, SStopc);
%                     
%                     umpt = umpt+repmat((tmpt(:)~=SStopc),1,3);
%                     umpc = umpc+repmat((tmpc(:)~=SStopc),1,3);
%                     umps = umps+repmat((tmps(:)~=SStopc),1,3);
%                 
%                     SSactc = [SSactc; 0 0 0];
%                 
%                     ompt = ompt+SSactc(tmpt(:),:).*mmgt;
%                     ompc = ompc+SSactc(tmpc(:),:).*mmgc;
%                     omps = omps+SSactc(tmps(:),:).*mmgs;
%                 end
%                 
%                 umpt=umpt==0;
%                 umpc=umpc==0;
%                 umps=umps==0;
                
                
                % combine gray and blob data to
                % truecolour
                
                %Revised by Sandy, 20140104. 
                imgt = reshape(ompt+gryc(imgt(:),:).*umpt, [size(imgt) 3]);
                imgc = reshape(ompc+gryc(imgc(:),:).*umpc, [size(imgc) 3]);
                imgs = reshape(omps+gryc(imgs(:),:).*umps, [size(imgs) 3]);
                
                %Revised by YAN Chao-Gan, 130609. The unwanted voxels will keep full color of underlay.
%                 imgt = reshape(ompt*actp+ ...
%                     gryc(imgt(:),:)*(1-actp) + umpt.*gryc(imgt(:),:)*(actp)  , ...
%                     [size(imgt) 3]);
%                 imgc = reshape(ompc*actp+ ...
%                     gryc(imgc(:),:)*(1-actp) + umpc.*gryc(imgc(:),:)*(actp)  , ...
%                     [size(imgc) 3]);
%                 imgs = reshape(omps*actp+ ...
%                     gryc(imgs(:),:)*(1-actp) + umps.*gryc(imgs(:),:)*(actp)  , ...
%                     [size(imgs) 3]);
%                 imgt = reshape(actc(tmpt(:),:)*actp+ ...
%                     gryc(imgt(:),:)*(1-actp), ...
%                     [size(imgt) 3]);
%                 imgc = reshape(actc(tmpc(:),:)*actp+ ...
%                     gryc(imgc(:),:)*(1-actp), ...
%                     [size(imgc) 3]);
%                 imgs = reshape(actc(tmps(:),:)*actp+ ...
%                     gryc(imgs(:),:)*(1-actp), ...
%                     [size(imgs) 3]);
                %Revising finished, YAN Chao-Gan, 130609.
            else
                % Add full colour blobs - several sets at once
                scal  = 1/(mx-mn);
                dcoff = -mn*scal;
                
                wt = zeros(size(imgt));
                wc = zeros(size(imgc));
                ws = zeros(size(imgs));
                
                imgt  = repmat(imgt*scal+dcoff,[1,1,3]);
                imgc  = repmat(imgc*scal+dcoff,[1,1,3]);
                imgs  = repmat(imgs*scal+dcoff,[1,1,3]);
                
                cimgt = zeros(size(imgt));
                cimgc = zeros(size(imgc));
                cimgs = zeros(size(imgs));
                
                colour = zeros(numel(st{curfig}.vols{i}.blobs),3);
                for k=1:numel(st{curfig}.vols{i}.blobs) % get colours of all images first
                    if isfield(st{curfig}.vols{i}.blobs{k},'colour')
                        colour(k,:) = reshape(st{curfig}.vols{i}.blobs{k}.colour, [1 3]);
                    else
                        colour(k,:) = [1 0 0];
                    end
                end
                %colour = colour/max(sum(colour));
                
                for k=1:numel(st{curfig}.vols{i}.blobs)
                    if isfield(st{curfig}.vols{i}.blobs{k},'max')
                        mx = st{curfig}.vols{i}.blobs{k}.max;
                    else
                        mx = max([eps max(st{curfig}.vols{i}.blobs{k}.vol(:))]);
                        st{curfig}.vols{i}.blobs{k}.max = mx;
                    end
                    if isfield(st{curfig}.vols{i}.blobs{k},'min')
                        mn = st{curfig}.vols{i}.blobs{k}.min;
                    else
                        mn = min([0 min(st{curfig}.vols{i}.blobs{k}.vol(:))]);
                        st{curfig}.vols{i}.blobs{k}.min = mn;
                    end
                    
                    vol  = st{curfig}.vols{i}.blobs{k}.vol;
                    M    = st{curfig}.Space\st{curfig}.vols{i}.premul*st{curfig}.vols{i}.blobs{k}.mat;
                    
                    
                    if ~isfield(vol,'Data')
                        tmpt = spm_slice_vol(vol,inv(TM0*M),TD,[0 NaN])';
                        tmpc = spm_slice_vol(vol,inv(CM0*M),CD,[0 NaN])';
                        tmps = spm_slice_vol(vol,inv(SM0*M),SD,[0 NaN])';
                    else   %Revised by YAN Chao-Gan, 130720. Could also work with Data has been read into memory other than only depending on the file.
                        tmpt = spm_slice_vol(vol.Data,inv(TM0*M),TD,[0 NaN])';
                        tmpc = spm_slice_vol(vol.Data,inv(CM0*M),CD,[0 NaN])';
                        tmps = spm_slice_vol(vol.Data,inv(SM0*M),SD,[0 NaN])';
                    end
                    

                    % check min/max of sampled image
                    % against mn/mx as given in st
                    tmpt(tmpt(:)<mn) = mn;
                    tmpc(tmpc(:)<mn) = mn;
                    tmps(tmps(:)<mn) = mn;
                    tmpt(tmpt(:)>mx) = mx;
                    tmpc(tmpc(:)>mx) = mx;
                    tmps(tmps(:)>mx) = mx;
                    tmpt = (tmpt-mn)/(mx-mn);
                    tmpc = (tmpc-mn)/(mx-mn);
                    tmps = (tmps-mn)/(mx-mn);
                    tmpt(~isfinite(tmpt)) = 0;
                    tmpc(~isfinite(tmpc)) = 0;
                    tmps(~isfinite(tmps)) = 0;
                    
                    cimgt = cimgt + cat(3,tmpt*colour(k,1),tmpt*colour(k,2),tmpt*colour(k,3));
                    cimgc = cimgc + cat(3,tmpc*colour(k,1),tmpc*colour(k,2),tmpc*colour(k,3));
                    cimgs = cimgs + cat(3,tmps*colour(k,1),tmps*colour(k,2),tmps*colour(k,3));
                    
                    wt = wt + tmpt;
                    wc = wc + tmpc;
                    ws = ws + tmps;
                    cdata=permute(shiftdim((1/64:1/64:1)'* ...
                        colour(k,:),-1),[2 1 3]);
                    redraw_colourbar(i,k,[mn mx],cdata);
                end
                
                imgt = repmat(1-wt,[1 1 3]).*imgt+cimgt;
                imgc = repmat(1-wc,[1 1 3]).*imgc+cimgc;
                imgs = repmat(1-ws,[1 1 3]).*imgs+cimgs;
                
                imgt(imgt<0)=0; imgt(imgt>1)=1;
                imgc(imgc<0)=0; imgc(imgc>1)=1;
                imgs(imgs<0)=0; imgs(imgs>1)=1;
            end
        else
            if isfield(handles, 'DPABI_fig')
                if ~isempty(st{curfig}.SSFlag) && ishandle(st{curfig}.SSFlag)
                    SSFlag=st{curfig}.SSFlag;
                    SSHandle=guidata(SSFlag);
                    IsPreview=get(SSHandle.PreviewBtn, 'Value');
                    if IsPreview
                        AtlasIdx=get(SSHandle.StructuralPopup, 'Value');
                        AStruct=st{curfig}.AtlasInfo{AtlasIdx};
                        vol=AStruct.Template;
                        M=st{curfig}.Space\st{curfig}.vols{i}.premul*vol.mat;

                        AMat=AStruct.Template.mat;
                        APos=round(inv(AMat)*[X;Y;Z;1]);
                        AI=APos(1);
                        AJ=APos(2);
                        AK=APos(3);
            
                        AIndex=AStruct.Template.Data(AI, AJ, AK);
                                
                        if AIndex
                            Mask=double(AStruct.Template.Data==AIndex);
                            
                            tmpt = spm_slice_vol(Mask,inv(TM0*M),TD,[0 NaN])';
                            tmpc = spm_slice_vol(Mask,inv(CM0*M),CD,[0 NaN])';
                            tmps = spm_slice_vol(Mask,inv(SM0*M),SD,[0 NaN])';
                        else
                            IsPreview=0;
                        end
                    end
                else
                    st{curfig}.SSFlag=[];
                    IsPreview=0;
                end
            else
                IsPreview=0;
            end
            
            if IsPreview
                % colourmaps
                gryc = (0:63)'*ones(1,3)/63;
                
                % scale grayscale image, not isfinite -> black
                imgt = scaletocmap(imgt,mn,mx,gryc,65);
                imgc = scaletocmap(imgc,mn,mx,gryc,65);
                imgs = scaletocmap(imgs,mn,mx,gryc,65);
                
                gryc = [gryc; 0 0 0];
                
                SSactc=AStruct.Template.CMap;
                SSactp=0.8;
                    
                SStopc = size(SSactc,1)+1;
                
                tmpt = scaletocmap(tmpt, 0, 1, SSactc, SStopc);
                tmpc = scaletocmap(tmpc, 0, 1, SSactc, SStopc);
                tmps = scaletocmap(tmps, 0, 1, SSactc, SStopc);
                   
                umpt = repmat((tmpt(:)~=SStopc),1,3);
                umpc = repmat((tmpc(:)~=SStopc),1,3);
                umps = repmat((tmps(:)~=SStopc),1,3);
                
                SSactc = [SSactc; 0 0 0];
                
                ompt = SSactc(tmpt(:),:);
                ompc = SSactc(tmpc(:),:);
                omps = SSactc(tmps(:),:);
                
                umpt=umpt==0;
                umpc=umpc==0;
                umps=umps==0;
                
                imgt = reshape(ompt*SSactp+ ...
                    gryc(imgt(:),:)*(1-SSactp) + umpt.*gryc(imgt(:),:)*(SSactp)  , ...
                    [size(imgt) 3]);
                imgc = reshape(ompc*SSactp+ ...
                    gryc(imgc(:),:)*(1-SSactp) + umpc.*gryc(imgc(:),:)*(SSactp)  , ...
                    [size(imgc) 3]);
                imgs = reshape(omps*SSactp+ ...
                    gryc(imgs(:),:)*(1-SSactp) + umps.*gryc(imgs(:),:)*(SSactp)  , ...
                    [size(imgs) 3]);
            else
                scal = 64/(mx-mn);
                dcoff = -mn*scal;
                imgt = imgt*scal+dcoff;
                imgc = imgc*scal+dcoff;
                imgs = imgs*scal+dcoff;
            end
        end
        
        set(st{curfig}.vols{i}.ax{1}.d,'HitTest','off', 'Cdata',imgt);
        set(st{curfig}.vols{i}.ax{1}.lx,'HitTest','off',...
            'Xdata',[0 TD(1)]+0.5,'Ydata',[1 1]*(cent(2)-bb(1,2)+1));
        set(st{curfig}.vols{i}.ax{1}.ly,'HitTest','off',...
            'Ydata',[0 TD(2)]+0.5,'Xdata',[1 1]*(cent(1)-bb(1,1)+1));
        
        set(st{curfig}.vols{i}.ax{2}.d,'HitTest','off', 'Cdata',imgc);
        set(st{curfig}.vols{i}.ax{2}.lx,'HitTest','off',...
            'Xdata',[0 CD(1)]+0.5,'Ydata',[1 1]*(cent(3)-bb(1,3)+1));
        set(st{curfig}.vols{i}.ax{2}.ly,'HitTest','off',...
            'Ydata',[0 CD(2)]+0.5,'Xdata',[1 1]*(cent(1)-bb(1,1)+1));
        
        set(st{curfig}.vols{i}.ax{3}.d,'HitTest','off','Cdata',imgs);
        if st{curfig}.mode ==0
            set(st{curfig}.vols{i}.ax{3}.lx,'HitTest','off',...
                'Xdata',[0 SD(1)]+0.5,'Ydata',[1 1]*(cent(2)-bb(1,2)+1));
            set(st{curfig}.vols{i}.ax{3}.ly,'HitTest','off',...
                'Ydata',[0 SD(2)]+0.5,'Xdata',[1 1]*(cent(3)-bb(1,3)+1));
        else
            set(st{curfig}.vols{i}.ax{3}.lx,'HitTest','off',...
                'Xdata',[0 SD(1)]+0.5,'Ydata',[1 1]*(cent(3)-bb(1,3)+1));
            set(st{curfig}.vols{i}.ax{3}.ly,'HitTest','off',...
                'Ydata',[0 SD(2)]+0.5,'Xdata',[1 1]*(bb(2,2)+1-cent(2)));
        end
        
        if ~isempty(st{curfig}.plugins) % process any addons
            for k = 1:numel(st{curfig}.plugins)
                if isfield(st{curfig}.vols{i},st{curfig}.plugins{k})
                    feval(['w_spm_ov_', st{curfig}.plugins{k}], ...
                        'redraw', i, TM0, TD, CM0, CD, SM0, SD);
                end
            end
        end
    end
end
drawnow;


%==========================================================================
% function redraw_all
%==========================================================================
function redraw_all(varargin)
if ~isempty(varargin)
    redraw(varargin{1})
else
    curfig=GetCurFig;
    redraw(curfig);
end


%==========================================================================
% function redraw_colourbar(vh,bh,interval,cdata)
%==========================================================================
function redraw_colourbar(vh,bh,interval,cdata,curfig)
global st
if nargin<5
    curfig=GetCurFig;
end
if isfield(st{curfig}.vols{vh}.blobs{bh},'cbar')
    if st{curfig}.mode == 0
        axpos = get(st{curfig}.vols{vh}.ax{2}.ax,'Position');
    else
        axpos = get(st{curfig}.vols{vh}.ax{1}.ax,'Position');
    end
    % only scale cdata if we have out-of-range truecolour values
    if ndims(cdata)==3 && max(cdata(:))>1
        cdata=cdata./max(cdata(:));
    end
    image([0 1],interval,cdata,'Parent',st{curfig}.vols{vh}.blobs{bh}.cbar);
    handles=guidata(st{curfig}.fig);
    if ~isfield(handles, 'DPABI_fig')
        set(st{curfig}.vols{vh}.blobs{bh}.cbar, ...
            'Position',[(axpos(1)+axpos(3)+0.05+(bh-1)*.1)...
            (axpos(2)+0.005) 0.05 (axpos(4)-0.01)],...
            'YDir','normal','XTickLabel',[],'XTick',[]);
    else
        set(st{curfig}.vols{vh}.blobs{bh}.cbar, ...
            'YDir','normal','XTickLabel',[],'XTick',[]);
    end
    if isfield(st{curfig}.vols{vh}.blobs{bh},'name')
        ylabel(st{curfig}.vols{vh}.blobs{bh}.name,'parent',st{curfig}.vols{vh}.blobs{bh}.cbar);
    end
end


%==========================================================================
% function centre = findcent
%==========================================================================
function centre = findcent
global st
curfig=GetCurFig;
obj    = get(st{curfig}.fig,'CurrentObject');
centre = [];
cent   = [];
cp     = [];
for i=valid_handles
    for j=1:3
        if ~isempty(obj)
            if (st{curfig}.vols{i}.ax{j}.ax == obj),
                cp = get(obj,'CurrentPoint');
            end
        end
        if ~isempty(cp)
            cp   = cp(1,1:2);
            is   = inv(st{curfig}.Space);
            cent = is(1:3,1:3)*st{curfig}.centre(:) + is(1:3,4);
            switch j
                case 1
                    cent([1 2])=[cp(1)+st{curfig}.bb(1,1)-1 cp(2)+st{curfig}.bb(1,2)-1];
                case 2
                    cent([1 3])=[cp(1)+st{curfig}.bb(1,1)-1 cp(2)+st{curfig}.bb(1,3)-1];
                case 3
                    if st{curfig}.mode ==0
                        cent([3 2])=[cp(1)+st{curfig}.bb(1,3)-1 cp(2)+st{curfig}.bb(1,2)-1];
                    else
                        cent([2 3])=[st{curfig}.bb(2,2)+1-cp(1) cp(2)+st{curfig}.bb(1,3)-1];
                    end
            end
            break;
        end
    end
    if ~isempty(cent), break; end
end
if ~isempty(cent), centre = st{curfig}.Space(1:3,1:3)*cent(:) + st{curfig}.Space(1:3,4); end


%==========================================================================
% function handles = valid_handles(handles)
%==========================================================================
function handles = valid_handles(handles)
global st
curfig=GetCurFig;
if ~nargin, handles = 1:max_img; end
if isempty(st{curfig}) || ~isfield(st{curfig},'vols')
    handles = [];
else
    handles = handles(:)';
    handles = handles(handles<=max_img & handles>=1 & ~rem(handles,1));
    for h=handles
        if isempty(st{curfig}.vols{h}), handles(handles==h)=[]; end
    end
end


%==========================================================================
% function reset_st
%==========================================================================
function reset_st
global st
curfig=GetCurFig;
fig = spm_figure('FindWin','Graphics');
bb  = []; %[ [-78 78]' [-112 76]' [-50 85]' ];
st  = struct('n', 0, 'vols',{cell(max_img,1)}, 'bb',bb, 'Space',eye(4), ...
             'centre',[0 0 0], 'callback',';', 'xhairs',1, 'hld',1, ...
             'fig',fig, 'mode',1, 'plugins',{{}}, 'snap',[]);

xTB = spm('TBs');
if ~isempty(xTB)
    pluginbase = {spm('Dir') xTB.dir};
else
    pluginbase = {spm('Dir')};
end
for k = 1:numel(pluginbase)
    pluginpath = fullfile(pluginbase{k},'y_spm_orthviews');
    if isdir(pluginpath)
        pluginfiles = dir(fullfile(pluginpath,'spm_ov_*.m'));
        if ~isempty(pluginfiles)
            if ~isdeployed, addpath(pluginpath); end
            for l = 1:numel(pluginfiles)
                pluginname = spm_file(pluginfiles(l).name,'basename');
                st{curfig}.plugins{end+1} = strrep(pluginname, 'spm_ov_','');
            end
        end
    end
end


%==========================================================================
% function img = scaletocmap(inpimg,mn,mx,cmap,miscol)
%==========================================================================
function img = scaletocmap(inpimg,mn,mx,cmap,miscol)
if nargin < 5, miscol=1; end
cml = size(cmap,1);
scf = (cml-1)/(mx-mn);
img = round((inpimg-mn)*scf)+1;
img(img<1)   = 1; 
img(img>cml) = cml;
img(inpimg==0) = miscol; %Added by YAN Chao-Gan 130609, mask out the 0 voxels.
img(~isfinite(img)) = miscol;


%==========================================================================
% function cmap = getcmap(acmapname)
%==========================================================================
function cmap = getcmap(acmapname)
% get colormap of name acmapname
if ~isempty(acmapname)
    cmap = evalin('base',acmapname,'[]');
    if isempty(cmap) % not a matrix, is .mat file?
        acmat = spm_file(acmapname, 'ext','.mat');
        if exist(acmat, 'file')
            s    = struct2cell(load(acmat));
            cmap = s{1};
        end
    end
end
if size(cmap, 2)~=3
    warning('Colormap was not an N by 3 matrix')
    cmap = [];
end


%==========================================================================
% function item_parent = addcontext(volhandle)
%==========================================================================
function item_parent = addcontext(volhandle)
global st
curfig=GetCurFig;
% create context menu
set(0,'CurrentFigure',st{curfig}.fig);
% contextmenu
item_parent = uicontextmenu;

% contextsubmenu 0
item00 = uimenu(item_parent, 'Label','unknown image', 'UserData','filename');
y_spm_orthviews('context_menu','image_info',item00,volhandle);
item0a = uimenu(item_parent, 'UserData','pos_mm', 'Separator','on', ...
    'Callback','y_spm_orthviews(''context_menu'',''repos_mm'');');
item0b = uimenu(item_parent, 'UserData','pos_vx', ...
    'Callback','y_spm_orthviews(''context_menu'',''repos_vx'');');
item0c = uimenu(item_parent, 'UserData','v_value');

% contextsubmenu 1
item1    = uimenu(item_parent,'Label','Zoom', 'Separator','on');
[zl, rl] = y_spm_orthviews('ZoomMenu');
for cz = numel(zl):-1:1
    if isinf(zl(cz))
        czlabel = 'Full Volume';
    elseif isnan(zl(cz))
        czlabel = 'BBox, this image > ...';
    elseif zl(cz) == 0
        czlabel = 'BBox, this image nonzero';
    else
        czlabel = sprintf('%dx%d mm', 2*zl(cz), 2*zl(cz));
    end
    item1_x = uimenu(item1, 'Label',czlabel,...
        'Callback', sprintf(...
        'y_spm_orthviews(''context_menu'',''zoom'',%d,%d)',zl(cz),rl(cz)));
    if isinf(zl(cz)) % default display is Full Volume
        set(item1_x, 'Checked','on');
    end
end

% contextsubmenu 2
checked   = {'off','off'};
checked{st{curfig}.xhairs+1} = 'on';
item2     = uimenu(item_parent,'Label','Crosshairs');
item2_1   = uimenu(item2,      'Label','on',  'Callback','y_spm_orthviews(''context_menu'',''Xhair'',''on'');','Checked',checked{2});
item2_2   = uimenu(item2,      'Label','off', 'Callback','y_spm_orthviews(''context_menu'',''Xhair'',''off'');','Checked',checked{1});

% contextsubmenu 3
if st{curfig}.Space == eye(4)
    checked = {'off', 'on'};
else
    checked = {'on', 'off'};
end
item3     = uimenu(item_parent,'Label','Orientation');
item3_1   = uimenu(item3,      'Label','World space', 'Callback','y_spm_orthviews(''context_menu'',''orientation'',3);','Checked',checked{2});
item3_2   = uimenu(item3,      'Label','Voxel space (1st image)', 'Callback','y_spm_orthviews(''context_menu'',''orientation'',2);','Checked',checked{1});
item3_3   = uimenu(item3,      'Label','Voxel space (this image)', 'Callback','y_spm_orthviews(''context_menu'',''orientation'',1);','Checked','off');

% contextsubmenu 3
if isempty(st{curfig}.snap)
    checked = {'off', 'on'};
else
    checked = {'on', 'off'};
end
item3     = uimenu(item_parent,'Label','Snap to Grid');
item3_1   = uimenu(item3,      'Label','Don''t snap', 'Callback','y_spm_orthviews(''context_menu'',''snap'',3);','Checked',checked{2});
item3_2   = uimenu(item3,      'Label','Snap to 1st image', 'Callback','y_spm_orthviews(''context_menu'',''snap'',2);','Checked',checked{1});
item3_3   = uimenu(item3,      'Label','Snap to this image', 'Callback','y_spm_orthviews(''context_menu'',''snap'',1);','Checked','off');

% contextsubmenu 4
if st{curfig}.hld == 0
    checked = {'off', 'off', 'on'};
elseif st{curfig}.hld > 0
    checked = {'off', 'on', 'off'};
else
    checked = {'on', 'off', 'off'};
end
item4     = uimenu(item_parent,'Label','Interpolation');
item4_1   = uimenu(item4,      'Label','NN',    'Callback','y_spm_orthviews(''context_menu'',''interpolation'',3);', 'Checked',checked{3});
item4_2   = uimenu(item4,      'Label','Trilin', 'Callback','y_spm_orthviews(''context_menu'',''interpolation'',2);','Checked',checked{2});
item4_3   = uimenu(item4,      'Label','Sinc',  'Callback','y_spm_orthviews(''context_menu'',''interpolation'',1);','Checked',checked{1});

% contextsubmenu 5
% item5     = uimenu(item_parent,'Label','Position', 'Callback','y_spm_orthviews(''context_menu'',''position'');');

% contextsubmenu 6
item6       = uimenu(item_parent,'Label','Image','Separator','on');
item6_1     = uimenu(item6,      'Label','Window');
item6_1_1   = uimenu(item6_1,    'Label','local');
item6_1_1_1 = uimenu(item6_1_1,  'Label','auto', 'Callback','y_spm_orthviews(''context_menu'',''window'',2);');
item6_1_1_2 = uimenu(item6_1_1,  'Label','manual', 'Callback','y_spm_orthviews(''context_menu'',''window'',1);');
item6_1_1_3 = uimenu(item6_1_1,  'Label','percentiles', 'Callback','y_spm_orthviews(''context_menu'',''window'',3);');
item6_1_2   = uimenu(item6_1,    'Label','global');
item6_1_2_1 = uimenu(item6_1_2,  'Label','auto', 'Callback','y_spm_orthviews(''context_menu'',''window_gl'',2);');
item6_1_2_2 = uimenu(item6_1_2,  'Label','manual', 'Callback','y_spm_orthviews(''context_menu'',''window_gl'',1);');
if license('test','image_toolbox') == 1
    offon = {'off', 'on'};
    checked = offon(strcmp(st{curfig}.vols{volhandle}.mapping, ...
        {'linear', 'histeq', 'loghisteq', 'quadhisteq'})+1);
    item6_2     = uimenu(item6,      'Label','Intensity mapping');
    item6_2_1   = uimenu(item6_2,    'Label','local');
    item6_2_1_1 = uimenu(item6_2_1,  'Label','Linear', 'Checked',checked{1}, ...
        'Callback','y_spm_orthviews(''context_menu'',''mapping'',''linear'');');
    item6_2_1_2 = uimenu(item6_2_1,  'Label','Equalised histogram', 'Checked',checked{2}, ...
        'Callback','y_spm_orthviews(''context_menu'',''mapping'',''histeq'');');
    item6_2_1_3 = uimenu(item6_2_1,  'Label','Equalised log-histogram', 'Checked',checked{3}, ...
        'Callback','y_spm_orthviews(''context_menu'',''mapping'',''loghisteq'');');
    item6_2_1_4 = uimenu(item6_2_1,  'Label','Equalised squared-histogram', 'Checked',checked{4}, ...
        'Callback','y_spm_orthviews(''context_menu'',''mapping'',''quadhisteq'');');
    item6_2_2   = uimenu(item6_2,    'Label','global');
    item6_2_2_1 = uimenu(item6_2_2,  'Label','Linear', 'Checked',checked{1}, ...
        'Callback','y_spm_orthviews(''context_menu'',''mapping_gl'',''linear'');');
    item6_2_2_2 = uimenu(item6_2_2,  'Label','Equalised histogram', 'Checked',checked{2}, ...
        'Callback','y_spm_orthviews(''context_menu'',''mapping_gl'',''histeq'');');
    item6_2_2_3 = uimenu(item6_2_2,  'Label','Equalised log-histogram', 'Checked',checked{3}, ...
        'Callback','y_spm_orthviews(''context_menu'',''mapping_gl'',''loghisteq'');');
    item6_2_2_4 = uimenu(item6_2_2,  'Label','Equalised squared-histogram', 'Checked',checked{4}, ...
        'Callback','y_spm_orthviews(''context_menu'',''mapping_gl'',''quadhisteq'');');
end

% contextsubmenu 7
item7     = uimenu(item_parent,'Label','Blobs');
item7_1   = uimenu(item7,      'Label','Add blobs');
item7_1_1 = uimenu(item7_1,    'Label','local',  'Callback','y_spm_orthviews(''context_menu'',''add_blobs'',2);');
item7_1_2 = uimenu(item7_1,    'Label','global', 'Callback','y_spm_orthviews(''context_menu'',''add_blobs'',1);');
item7_2   = uimenu(item7,      'Label','Add image');
item7_2_1 = uimenu(item7_2,    'Label','local',  'Callback','y_spm_orthviews(''context_menu'',''add_image'',2);');
item7_2_2 = uimenu(item7_2,    'Label','global', 'Callback','y_spm_orthviews(''context_menu'',''add_image'',1);');
item7_3   = uimenu(item7,      'Label','Add colored blobs','Separator','on');
item7_3_1 = uimenu(item7_3,    'Label','local',  'Callback','y_spm_orthviews(''context_menu'',''add_c_blobs'',2);');
item7_3_2 = uimenu(item7_3,    'Label','global', 'Callback','y_spm_orthviews(''context_menu'',''add_c_blobs'',1);');
item7_4   = uimenu(item7,      'Label','Add colored image');
item7_4_1 = uimenu(item7_4,    'Label','local',  'Callback','y_spm_orthviews(''context_menu'',''add_c_image'',2);');
item7_4_2 = uimenu(item7_4,    'Label','global', 'Callback','y_spm_orthviews(''context_menu'',''add_c_image'',1);');
item7_5   = uimenu(item7,      'Label','Remove blobs',        'Visible','off','Separator','on');
item7_6   = uimenu(item7,      'Label','Remove colored blobs','Visible','off');
item7_6_1 = uimenu(item7_6,    'Label','local', 'Visible','on');
item7_6_2 = uimenu(item7_6,    'Label','global','Visible','on');
item7_7   = uimenu(item7,      'Label','Set blobs max', 'Visible','off');

for i=1:3
    set(st{curfig}.vols{volhandle}.ax{i}.ax,'UIcontextmenu',item_parent);
    st{curfig}.vols{volhandle}.ax{i}.cm = item_parent;
end

% process any plugins
for k = 1:numel(st{curfig}.plugins)
    feval(['w_spm_ov_', st{curfig}.plugins{k}],'context_menu',volhandle,item_parent);
    if k==1
        h = get(item_parent,'Children');
        set(h(1),'Separator','on'); 
    end
end


%==========================================================================
% function addcontexts(handles)
%==========================================================================
function addcontexts(handles)
for ii = valid_handles(handles)
    addcontext(ii);
end
y_spm_orthviews('reposition',y_spm_orthviews('pos'));


%==========================================================================
% function rmcontexts(handles)
%==========================================================================
function rmcontexts(handles)
global st
curfig=GetCurFig;
for ii = valid_handles(handles)
    for i=1:3
        set(st{curfig}.vols{ii}.ax{i}.ax,'UIcontextmenu',[]);
        try st{curfig}.vols{ii}.ax{i} = rmfield(st{curfig}.vols{ii}.ax{i},'cm'); end
    end
end


%==========================================================================
% function c_menu(varargin)
%==========================================================================
function c_menu(varargin)
global st
curfig=GetCurFig;

switch lower(varargin{1})
    case 'image_info'
        if nargin <3
            current_handle = get_current_handle;
        else
            current_handle = varargin{3};
        end
        if isfield(st{curfig}.vols{current_handle},'fname')
            [p,n,e,v] = spm_fileparts(st{curfig}.vols{current_handle}.fname);
            if isfield(st{curfig}.vols{current_handle},'n')
                v = sprintf(',%d',st{curfig}.vols{current_handle}.n);
            end
            set(varargin{2}, 'Label',[n e v]);
        end
        delete(get(varargin{2},'children'));
        if exist('p','var')
            item1 = uimenu(varargin{2}, 'Label', p);
        end
        if isfield(st{curfig}.vols{current_handle},'descrip')
            item2 = uimenu(varargin{2}, 'Label',...
                st{curfig}.vols{current_handle}.descrip);
        end
        dt = st{curfig}.vols{current_handle}.dt(1);
        item3 = uimenu(varargin{2}, 'Label', sprintf('Data type: %s', spm_type(dt)));
        str   = 'Intensity: varied';
        if size(st{curfig}.vols{current_handle}.pinfo,2) == 1
            if st{curfig}.vols{current_handle}.pinfo(2)
                str = sprintf('Intensity: Y = %g X + %g',...
                    st{curfig}.vols{current_handle}.pinfo(1:2)');
            else
                str = sprintf('Intensity: Y = %g X', st{curfig}.vols{current_handle}.pinfo(1)');
            end
        end
        item4  = uimenu(varargin{2}, 'Label',str);
        item5  = uimenu(varargin{2}, 'Label', 'Image dimensions', 'Separator','on');
        item51 = uimenu(varargin{2}, 'Label',...
            sprintf('%dx%dx%d', st{curfig}.vols{current_handle}.dim(1:3)));
        
        prms   = spm_imatrix(st{curfig}.vols{current_handle}.mat);
        item6  = uimenu(varargin{2}, 'Label', 'Voxel size', 'Separator','on');
        item61 = uimenu(varargin{2}, 'Label', sprintf('%.2f %.2f %.2f', prms(7:9)));
        
        O      = st{curfig}.vols{current_handle}.mat\[0 0 0 1]'; O=O(1:3)';
        item7  = uimenu(varargin{2}, 'Label', 'Origin', 'Separator','on');
        item71 = uimenu(varargin{2}, 'Label', sprintf('%.2f %.2f %.2f', O));
        
        R      = spm_matrix([0 0 0 prms(4:6)]);
        item8  = uimenu(varargin{2}, 'Label', 'Rotations', 'Separator','on');
        item81 = uimenu(varargin{2}, 'Label', sprintf('%.2f %.2f %.2f', R(1,1:3)));
        item82 = uimenu(varargin{2}, 'Label', sprintf('%.2f %.2f %.2f', R(2,1:3)));
        item83 = uimenu(varargin{2}, 'Label', sprintf('%.2f %.2f %.2f', R(3,1:3)));
        item9  = uimenu(varargin{2},...
            'Label','Specify other image...',...
            'Callback','y_spm_orthviews(''context_menu'',''swap_img'');',...
            'Separator','on');
        
    case 'repos_mm'
        oldpos_mm = y_spm_orthviews('pos');
        newpos_mm = spm_input('New Position (mm)','+1','r',sprintf('%.2f %.2f %.2f',oldpos_mm),3);
        y_spm_orthviews('reposition',newpos_mm);
        
    case 'repos_vx'
        current_handle = get_current_handle;
        oldpos_vx = y_spm_orthviews('pos', current_handle);
        newpos_vx = spm_input('New Position (voxels)','+1','r',sprintf('%.2f %.2f %.2f',oldpos_vx),3);
        newpos_mm = st{curfig}.vols{current_handle}.mat*[newpos_vx;1];
        y_spm_orthviews('reposition',newpos_mm(1:3));
        
    case 'zoom'
        zoom_all(varargin{2:end});
        bbox;
        redraw_all;
        
    case 'xhair'
        y_spm_orthviews('Xhairs',varargin{2});
        cm_handles = get_cm_handles;
        for i = 1:numel(cm_handles)
            z_handle = get(findobj(cm_handles(i),'label','Crosshairs'),'Children');
            set(z_handle,'Checked','off'); %reset check
            if strcmp(varargin{2},'off'), op = 1; else op = 2; end
            set(z_handle(op),'Checked','on');
        end
        
    case 'orientation'
        cm_handles = get_cm_handles;
        for i = 1:numel(cm_handles)
            z_handle = get(findobj(cm_handles(i),'label','Orientation'),'Children');
            set(z_handle,'Checked','off');
        end
        if varargin{2} == 3
            y_spm_orthviews('Space');
            for i = 1:numel(cm_handles),
                z_handle = findobj(cm_handles(i),'label','World space');
                set(z_handle,'Checked','on');
            end
        elseif varargin{2} == 2,
            y_spm_orthviews('Space',1);
            for i = 1:numel(cm_handles)
                z_handle = findobj(cm_handles(i),'label',...
                    'Voxel space (1st image)');
                set(z_handle,'Checked','on');
            end
        else
            y_spm_orthviews('Space',get_current_handle);
            z_handle = findobj(st{curfig}.vols{get_current_handle}.ax{1}.cm, ...
                'label','Voxel space (this image)');
            set(z_handle,'Checked','on');
            return;
        end
        
    case 'snap'
        cm_handles = get_cm_handles;
        for i = 1:numel(cm_handles)
            z_handle = get(findobj(cm_handles(i),'label','Snap to Grid'),'Children');
            set(z_handle,'Checked','off');
        end
        if varargin{2} == 3
            st{curfig}.snap = [];
        elseif varargin{2} == 2
            st{curfig}.snap = 1;
        else
            st{curfig}.snap = get_current_handle;
            z_handle = get(findobj(st{curfig}.vols{get_current_handle}.ax{1}.cm,'label','Snap to Grid'),'Children');
            set(z_handle(1),'Checked','on');
            return;
        end
        for i = 1:numel(cm_handles)
            z_handle = get(findobj(cm_handles(i),'label','Snap to Grid'),'Children');
            set(z_handle(varargin{2}),'Checked','on');
        end
        
    case 'interpolation'
        tmp        = [-4 1 0];
        st{curfig}.hld     = tmp(varargin{2});
        cm_handles = get_cm_handles;
        for i = 1:numel(cm_handles)
            z_handle = get(findobj(cm_handles(i),'label','Interpolation'),'Children');
            set(z_handle,'Checked','off');
            set(z_handle(varargin{2}),'Checked','on');
        end
        redraw_all;
        
    case 'window'
        current_handle = get_current_handle;
        if varargin{2} == 2
            y_spm_orthviews('window',current_handle);
        elseif varargin{2} == 3
            pc = spm_input('Percentiles', '+1', 'w', '3 97', 2, 100);
            wn = spm_summarise(st{curfig}.vols{current_handle}, 'all', ...
                @(X) spm_percentile(X, pc));
            y_spm_orthviews('window',current_handle,wn);
        else
            if isnumeric(st{curfig}.vols{current_handle}.window)
                defstr = sprintf('%.2f %.2f', st{curfig}.vols{current_handle}.window);
            else
                defstr = '';
            end
            [w,yp] = spm_input('Range','+1','e',defstr,[1 inf]);
            while numel(w) < 1 || numel(w) > 2
                uiwait(warndlg('Window must be one or two numbers','Wrong input size','modal'));
                [w,yp] = spm_input('Range',yp,'e',defstr,[1 inf]);
            end
            if numel(w) == 1
                w(2) = w(1)+eps;
            end
            y_spm_orthviews('window',current_handle,w);
        end
        
    case 'window_gl'
        if varargin{2} == 2
            for i = 1:numel(get_cm_handles)
                st{curfig}.vols{i}.window = 'auto';
            end
        else
            current_handle = get_current_handle;
            if isnumeric(st{curfig}.vols{current_handle}.window)
                defstr = sprintf('%d %d', st{curfig}.vols{current_handle}.window);
            else
                defstr = '';
            end
            [w,yp] = spm_input('Range','+1','e',defstr,[1 inf]);
            while numel(w) < 1 || numel(w) > 2
                uiwait(warndlg('Window must be one or two numbers','Wrong input size','modal'));
                [w,yp] = spm_input('Range',yp,'e',defstr,[1 inf]);
            end
            if numel(w) == 1
                w(2) = w(1)+eps;
            end
            for i = 1:numel(get_cm_handles)
                st{curfig}.vols{i}.window = w;
            end
        end
        redraw_all;
        
    case 'mapping'
        checked = strcmp(varargin{2}, ...
            {'linear', 'histeq', 'loghisteq', 'quadhisteq'});
        checked = checked(end:-1:1); % Handles are stored in inverse order
        current_handle = get_current_handle;
        cm_handles = get_cm_handles;
        st{curfig}.vols{current_handle}.mapping = varargin{2};
        z_handle = get(findobj(cm_handles(current_handle), ...
            'label','Intensity mapping'),'Children');
        for k = 1:numel(z_handle)
            c_handle = get(z_handle(k), 'Children');
            set(c_handle, 'checked', 'off');
            set(c_handle(checked), 'checked', 'on');
        end
        redraw_all;
        
    case 'mapping_gl'
        checked = strcmp(varargin{2}, ...
            {'linear', 'histeq', 'loghisteq', 'quadhisteq'});
        checked = checked(end:-1:1); % Handles are stored in inverse order
        cm_handles = get_cm_handles;
        for k = valid_handles
            st{curfig}.vols{k}.mapping = varargin{2};
            z_handle = get(findobj(cm_handles(k), ...
                'label','Intensity mapping'),'Children');
            for l = 1:numel(z_handle)
                c_handle = get(z_handle(l), 'Children');
                set(c_handle, 'checked', 'off');
                set(c_handle(checked), 'checked', 'on');
            end
        end
        redraw_all;
        
    case 'swap_img'
        current_handle = get_current_handle;
        newimg = spm_select(1,'image','select new image');
        if ~isempty(newimg)
            new_info = spm_vol(newimg);
            fn = fieldnames(new_info);
            for k=1:numel(fn)
                st{curfig}.vols{current_handle}.(fn{k}) = new_info.(fn{k});
            end
            y_spm_orthviews('context_menu','image_info',get(gcbo, 'parent'));
            redraw_all;
        end
        
    case 'add_blobs'
        % Add blobs to the image - in split colortable
        cm_handles = valid_handles;
        if varargin{2} == 2, cm_handles = get_current_handle; end
        spm_input('!DeleteInputObj');
        [SPM,xSPM] = spm_getSPM;
        if ~isempty(SPM)
            for i = 1:numel(cm_handles)
                addblobs(cm_handles(i),xSPM.XYZ,xSPM.Z,xSPM.M);
                % Add options for removing blobs
                c_handle = findobj(findobj(st{curfig}.vols{cm_handles(i)}.ax{1}.cm,'label','Blobs'),'Label','Remove blobs');
                set(c_handle,'Visible','on');
                delete(get(c_handle,'Children'));
                item7_3_1 = uimenu(c_handle,'Label','local','Callback','y_spm_orthviews(''context_menu'',''remove_blobs'',2);');
                if varargin{2} == 1,
                    item7_3_2 = uimenu(c_handle,'Label','global','Callback','y_spm_orthviews(''context_menu'',''remove_blobs'',1);');
                end
                % Add options for setting maxima for blobs
                c_handle = findobj(findobj(st{curfig}.vols{cm_handles(i)}.ax{1}.cm,'label','Blobs'),'Label','Set blobs max');
                set(c_handle,'Visible','on');
                delete(get(c_handle,'Children'));
                uimenu(c_handle,'Label','local','Callback','y_spm_orthviews(''context_menu'',''setblobsmax'',2);');
                if varargin{2} == 1
                    uimenu(c_handle,'Label','global','Callback','y_spm_orthviews(''context_menu'',''setblobsmax'',1);');
                end
            end
            redraw_all;
        end
        
    case 'remove_blobs'
        cm_handles = valid_handles;
        if varargin{2} == 2, cm_handles = get_current_handle; end
        for i = 1:numel(cm_handles)
            rmblobs(cm_handles(i));
            % Remove options for removing blobs
            c_handle = findobj(findobj(st{curfig}.vols{cm_handles(i)}.ax{1}.cm,'label','Blobs'),'Label','Remove blobs');
            delete(get(c_handle,'Children'));
            set(c_handle,'Visible','off');
            % Remove options for setting maxima for blobs
            c_handle = findobj(findobj(st{curfig}.vols{cm_handles(i)}.ax{1}.cm,'label','Blobs'),'Label','Set blobs max');
            set(c_handle,'Visible','off');
        end
        redraw_all;
        
    case 'add_image'
        % Add blobs to the image - in split colortable
        cm_handles = valid_handles;
        if varargin{2} == 2, cm_handles = get_current_handle; end
        spm_input('!DeleteInputObj');
        fname = spm_select(1,'image','select image');
        if ~isempty(fname)
            for i = 1:numel(cm_handles)
                addimage(cm_handles(i),fname);
                % Add options for removing blobs
                c_handle = findobj(findobj(st{curfig}.vols{cm_handles(i)}.ax{1}.cm,'label','Blobs'),'Label','Remove blobs');
                set(c_handle,'Visible','on');
                delete(get(c_handle,'Children'));
                item7_3_1 = uimenu(c_handle,'Label','local','Callback','y_spm_orthviews(''context_menu'',''remove_blobs'',2);');
                if varargin{2} == 1
                    item7_3_2 = uimenu(c_handle,'Label','global','Callback','y_spm_orthviews(''context_menu'',''remove_blobs'',1);');
                end
                % Add options for setting maxima for blobs
                c_handle = findobj(findobj(st{curfig}.vols{cm_handles(i)}.ax{1}.cm,'label','Blobs'),'Label','Set blobs max');
                set(c_handle,'Visible','on');
                delete(get(c_handle,'Children'));
                uimenu(c_handle,'Label','local','Callback','y_spm_orthviews(''context_menu'',''setblobsmax'',2);');
                if varargin{2} == 1
                    uimenu(c_handle,'Label','global','Callback','y_spm_orthviews(''context_menu'',''setblobsmax'',1);');
                end
            end
            redraw_all;
        end
        
    case 'add_c_blobs'
        % Add blobs to the image - in full colour
        cm_handles = valid_handles;
        if varargin{2} == 2, cm_handles = get_current_handle; end
        spm_input('!DeleteInputObj');
        [SPM,xSPM] = spm_getSPM;
        if ~isempty(SPM)
            c = spm_input('Colour','+1','m',...
                'Red blobs|Yellow blobs|Green blobs|Cyan blobs|Blue blobs|Magenta blobs',[1 2 3 4 5 6],1);
            colours = [1 0 0;1 1 0;0 1 0;0 1 1;0 0 1;1 0 1];
            c_names = {'red';'yellow';'green';'cyan';'blue';'magenta'};
            hlabel = sprintf('%s (%s)',xSPM.title,c_names{c});
            for i = 1:numel(cm_handles)
                addcolouredblobs(cm_handles(i),xSPM.XYZ,xSPM.Z,xSPM.M,colours(c,:),xSPM.title);
                addcolourbar(cm_handles(i),numel(st{curfig}.vols{cm_handles(i)}.blobs));
                c_handle    = findobj(findobj(st{curfig}.vols{cm_handles(i)}.ax{1}.cm,'label','Blobs'),'Label','Remove colored blobs');
                ch_c_handle = get(c_handle,'Children');
                set(c_handle,'Visible','on');
                %set(ch_c_handle,'Visible',on');
                item7_4_1   = uimenu(ch_c_handle(2),'Label',hlabel,'ForegroundColor',colours(c,:),...
                    'Callback','c = get(gcbo,''UserData'');y_spm_orthviews(''context_menu'',''remove_c_blobs'',2,c);',...
                    'UserData',c);
                if varargin{2} == 1
                    item7_4_2 = uimenu(ch_c_handle(1),'Label',hlabel,'ForegroundColor',colours(c,:),...
                        'Callback','c = get(gcbo,''UserData'');y_spm_orthviews(''context_menu'',''remove_c_blobs'',1,c);',...
                        'UserData',c);
                end
            end
            redraw_all;
        end
        
    case 'remove_c_blobs'
        cm_handles = valid_handles;
        if varargin{2} == 2, cm_handles = get_current_handle; end
        colours = [1 0 0;1 1 0;0 1 0;0 1 1;0 0 1;1 0 1];
        for i = 1:numel(cm_handles)
            if isfield(st{curfig}.vols{cm_handles(i)},'blobs')
                for j = 1:numel(st{curfig}.vols{cm_handles(i)}.blobs)
                    if all(st{curfig}.vols{cm_handles(i)}.blobs{j}.colour == colours(varargin{3},:));
                        if isfield(st{curfig}.vols{cm_handles(i)}.blobs{j},'cbar')
                            delete(st{curfig}.vols{cm_handles(i)}.blobs{j}.cbar);
                        end
                        st{curfig}.vols{cm_handles(i)}.blobs(j) = [];
                        break;
                    end
                end
                rm_c_menu = findobj(st{curfig}.vols{cm_handles(i)}.ax{1}.cm,'Label','Remove colored blobs');
                delete(gcbo);
                if isempty(st{curfig}.vols{cm_handles(i)}.blobs)
                    st{curfig}.vols{cm_handles(i)} = rmfield(st{curfig}.vols{cm_handles(i)},'blobs');
                    set(rm_c_menu, 'Visible', 'off');
                end
            end
        end
        redraw_all;
        
    case 'add_c_image'
        % Add truecolored image
        cm_handles = valid_handles;
        if varargin{2} == 2, cm_handles = get_current_handle; end
        spm_input('!DeleteInputObj');
        fname = spm_select([1 Inf],'image','select image(s)');
        for k = 1:size(fname,1)
            c = spm_input(sprintf('Image %d: Colour',k),'+1','m',...
                'Red blobs|Yellow blobs|Green blobs|Cyan blobs|Blue blobs|Magenta blobs',[1 2 3 4 5 6],1);
            colours = [1 0 0;1 1 0;0 1 0;0 1 1;0 0 1;1 0 1];
            c_names = {'red';'yellow';'green';'cyan';'blue';'magenta'};
            hlabel = sprintf('%s (%s)',fname(k,:),c_names{c});
            for i = 1:numel(cm_handles)
                addcolouredimage(cm_handles(i),fname(k,:),colours(c,:));
                addcolourbar(cm_handles(i),numel(st{curfig}.vols{cm_handles(i)}.blobs));
                c_handle    = findobj(findobj(st{curfig}.vols{cm_handles(i)}.ax{1}.cm,'label','Blobs'),'Label','Remove colored blobs');
                ch_c_handle = get(c_handle,'Children');
                set(c_handle,'Visible','on');
                %set(ch_c_handle,'Visible',on');
                item7_4_1 = uimenu(ch_c_handle(2),'Label',hlabel,'ForegroundColor',colours(c,:),...
                    'Callback','c = get(gcbo,''UserData'');y_spm_orthviews(''context_menu'',''remove_c_blobs'',2,c);','UserData',c);
                if varargin{2} == 1
                    item7_4_2 = uimenu(ch_c_handle(1),'Label',hlabel,'ForegroundColor',colours(c,:),...
                        'Callback','c = get(gcbo,''UserData'');y_spm_orthviews(''context_menu'',''remove_c_blobs'',1,c);',...
                        'UserData',c);
                end
            end
            redraw_all;
        end
        
    case 'setblobsmax'
        if varargin{2} == 1
            % global
            cm_handles = valid_handles;
            mx = -inf;
            for i = 1:numel(cm_handles)
                if ~isfield(st{curfig}.vols{cm_handles(i)}, 'blobs'), continue, end
                for j = 1:numel(st{curfig}.vols{cm_handles(i)}.blobs)
                    mx = max(mx, st{curfig}.vols{cm_handles(i)}.blobs{j}.max);
                end
            end
            mx = spm_input('Maximum value', '+1', 'r', mx, 1);
            for i = 1:numel(cm_handles)
                if ~isfield(st{curfig}.vols{cm_handles(i)}, 'blobs'), continue, end
                for j = 1:numel(st{curfig}.vols{cm_handles(i)}.blobs)
                    st{curfig}.vols{cm_handles(i)}.blobs{j}.max = mx;
                end
            end
        else
            % local (should handle coloured blobs, but not implemented yet)
            cm_handle = get_current_handle;
            colours = [1 0 0;1 1 0;0 1 0;0 1 1;0 0 1;1 0 1];
            if ~isfield(st{curfig}.vols{cm_handle}, 'blobs'), return, end
            for j = 1:numel(st{curfig}.vols{cm_handle}.blobs)
                if nargin < 4 || ...
                        all(st{curfig}.vols{cm_handle}.blobs{j}.colour == colours(varargin{3},:))
                    mx = st{curfig}.vols{cm_handle}.blobs{j}.max;
                    mx = spm_input('Maximum value', '+1', 'r', mx, 1);
                    st{curfig}.vols{cm_handle}.blobs{j}.max = mx;
                end
            end
        end
        redraw_all;
end


%==========================================================================
% function current_handle = get_current_handle
%==========================================================================
function current_handle = get_current_handle
cm_handle      = get(gca,'UIContextMenu');
cm_handles     = get_cm_handles;
current_handle = find(cm_handles==cm_handle);


%==========================================================================
% function cm_pos
%==========================================================================
function cm_pos(varargin)
global st
if ~isempty(varargin)
    curfig=varargin{1};
else
    curfig=GetCurFig;
end
for i = 1:numel(valid_handles)
    if isfield(st{curfig}.vols{i}.ax{1},'cm')
        set(findobj(st{curfig}.vols{i}.ax{1}.cm,'UserData','pos_mm'),...
            'Label',sprintf('mm:  %.1f %.1f %.1f',y_spm_orthviews('pos')));
        pos = y_spm_orthviews('pos',i);
        set(findobj(st{curfig}.vols{i}.ax{1}.cm,'UserData','pos_vx'),...
            'Label',sprintf('vx:  %.1f %.1f %.1f',pos));
        try
            %Fixed by Sandy 20140106
            if isfield(st{curfig}.vols{i}, 'Data')
                Y = spm_sample_vol(st{curfig}.vols{i}.Data,pos(1),pos(2),pos(3),st{curfig}.hld);
            else
                Y = spm_sample_vol(st{curfig}.vols{i},pos(1),pos(2),pos(3),st{curfig}.hld);
            end
        catch
            Y = NaN;
            fprintf('Cannot access file "%s".\n', st{curfig}.vols{i}.fname);
        end
        set(findobj(st{curfig}.vols{i}.ax{1}.cm,'UserData','v_value'),...
            'Label',sprintf('Y = %g',Y));
    end
end


%==========================================================================
% function cm_handles = get_cm_handles
%==========================================================================
function cm_handles = get_cm_handles
global st
curfig=GetCurFig;
cm_handles = [];
for i = valid_handles
    cm_handles = [cm_handles st{curfig}.vols{i}.ax{1}.cm];
end


%==========================================================================
% function zoom_all(zoom,res)
%==========================================================================
function zoom_all(zoom,res)
cm_handles = get_cm_handles;
zoom_op(zoom,res);
for i = 1:numel(cm_handles)
    z_handle = get(findobj(cm_handles(i),'label','Zoom'),'Children');
    set(z_handle,'Checked','off');
    if isinf(zoom)
        set(findobj(z_handle,'Label','Full Volume'),'Checked','on');
    elseif zoom > 0
        set(findobj(z_handle,'Label',sprintf('%dx%d mm', 2*zoom, 2*zoom)),'Checked','on');
    end % leave all unchecked if either bounding box option was chosen
end


%==========================================================================
% function m = max_img
%==========================================================================
function m = max_img
m = 1;

function curfig = GetCurFig(varargin)
if nargin<2
    curfig=gcf;
    curfig=w_Compatible2014bFig(curfig);
    if rem(curfig, 1)
        curfig=gcbf;
        try
            if strcmpi(curfig.Name,'DPARSF') %YAN Chao-Gan, 181213. In case calling from DPARSF main
                curfig=1;
            end
        catch
        end
    end
else
    curfig=varargin{1};
end
