function colormapeditor(fig)
%COLORMAPEDITOR starts colormap editor ui
%
%   When started the colormap editor displays the current figure's colormap
%   as a strip of rectangluar cells. Nodes, displayed as rectangles(end
%   nodes) or carrots below the strip, separate regions of uniform slope in
%   R,G and B.   The grays colormap, for example, has only two nodes since
%   R,G and B increase at a constant slope from the first to last index in
%   the map. Most of the other standard colormaps have additional nodes where
%   the slopes of the R,G or B curves change.
% 
%   As the mouse is moved over the color cells the colormap index, CData
%   value r,g,b and h,s,v values for that cell are displayed in the Current
%   Color Info box of the gui.
%
%   To add a node: 
%       Click below the cell where you wish to add the node
%
%   To delete a node:
%       Select the node by clicking on it and hit the Delete key or
%       Edit->Delete, or Ctrl-X
%
%   To move a node:
%       Click and drag or select and use left and right arrow keys.
%
%   To change a node's color:
%       Double click or click to select and Edit->Set Node Color. If multiple
%       nodes are selected the color change will apply to the last node
%       selected (current node).
%
%   To select this node, that node and all nodes between:
%       Click on this node, then Shift-Click on that node.
%
%   To select this, that and the other node:
%       Click on this, Ctrl-Click on that and the other.
%
%   To move multiple nodes at once: 
%       Select multiple nodes then use left and right arrow keys to move them
%       all at once.  Movement will stop when one of the selected nodes bumps
%       into an unselected node or end node. 
%
%   To delete multiple nodes:
%       Select the nodes and hit the Delete key, or Edit->Delete, or Ctrl-X.
%
%   To avoid flashing while editing the colormap set the figures DoubleBuffer
%   property to 'on'.
%
%   The "Interpolating Colorspace" selection determines what colorspace is
%   used to calculate the color of cells between nodes.  Initially this is
%   set to RGB, meaning that the R,G and B values of cells between nodes are
%   linearly interpolated between the R,G and B values of the nodes. Changing
%   the interpolating colorspace to HSV causes the cells between nodes to be
%   re-calculated by interpolating their H,S and V values from  the H,S and V
%   values of the nodes.  This usually produces very different results.
%   Because Hue is conceptually mapped about a color circle, the
%   interpolation between Hue values could be ambiguous.  To minimize
%   ambiguity the shortest distance around the circle is used.  For example,
%   if two  nodes have Hues of 2(slightly orange red) and 356 (slightly
%   magenta red), the cells between them would not have hues 3,4,5 ....
%   353,354,355  (orange/red-yellow-green-cyan-blue-magenta/red) but 357,
%   358, 1, 2  (orange/red-red-magenta/red).
%
%   The "Color Data Min" and "Color Data Max" editable text areas contain 
%   the values that correspond to the current axes "Clim" property.  These
%   values may be set here and are useful for selecting a range of data
%   values to which the colormap will map.  For example, your CData values
%   might range from 0 to 100, but the range of interest may be between 40 
%   and 60.  Using Color Data Min and Max (or the Axes Clim property) the
%   full variation of the colormap can be placed between the values 40 and 60
%   to improve visual/color resolution in that range.   Color Data Min
%   corresponds to Clim(0) and is the CData value to which the first Colormap
%   index is mapped.  All CData Values below this will display in the same
%   color as the first index.  Color Data Max corresponds to Clim(1) and is
%   the CData value to which the last Colormap index is mapped.  All CData 
%   values greater than this will display the same color as the last index.
%   Setting Color Data Min and Max (or Clim) will only affect the display of
%   objects (Surfaces, Patches, Images) who's CDataMapping Property is set to
%   'Scaled'.  e.g.  imagesc(im) but not image(im).
%
%   Immediate Apply is checked by default, and applies changes as they are
%   made.  If Immediate Apply is unselected, changes in the colormap editor
%   will not be applied until the apply or OK button is selected, and any
%   changes made will be lost if the Cancel button is selected.
%
%   See also COLORMAP


%   G. DeLoid 03/04/2002
%
%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.2.4.24.2.1 $  $Date: 2010/07/06 14:40:31 $

error(javachk('mwt', 'The Colormap Editor'));

import com.mathworks.page.cmapeditor.*;

% look for figure input
if nargin
    % colormapeditor([]) should do nothing
    if isempty(fig)
        return
    end
    
    if nargin == 1
        if ~any(ishandle_valid(fig)) || ~ishghandle(fig,'figure')
            error('MATLAB:colormapeditor:InvalidFigureHandle', 'Invalid figure handle');
        end
    end
else
    fig = [];
end

% get figure if not provided
if isempty(fig)
    fig = get(0,'CurrentFigure');
    if isempty(fig)
        fig=figure;
    end
end

% make sure the colormap is valid
check_colormap(get(fig,'Colormap'))



% reuse the only one if it's there
cme = get_cmapeditor();
if ~isempty(cme)
    cme.bringToFront;
    cme.setVisible;
    return;
end

% start colormapeditor and make it the only one
if feature('HGUsingMATLABClasses') % Work around G621525
    com.mathworks.page.cmapeditor.CMEditFrame.sendJavaWindowFocusEventsToMatlab(true);
end
cme = CMEditor;
set_cmapeditor(cme);
cme.init;
    
% attach the matlab callback interface so we get notified of updates
cb = handle(cme.getMatlabQue.getCallback,'callbackproperties');
set(cb,'delayedCallback',@handle_callback)

update_colormap(get(fig,'Colormap'));

ax = get(fig,'CurrentAxes');
handle_axes_change(fig,ax,false);
cme.setFigure (java(handle(fig)));
start_listeners(fig,ax);

% all set, show it now
cme.setVisible;

%----------------------------------------------------------------------%
% FUNCTIONS CALLED BY FROM JAVA EDITOR
%----------------------------------------------------------------------%
function handle_callback(callback_source, eventData) %#ok<INUSL>
% callback_source is not used
cme = get_cmapeditor();
cme_ = eventData.getEditor;
if isempty(cme) || (~isempty(cme_) && cme_.isDisposed)
    % This error was put in to catch the scenario where a callback for the cmeditor
    % is gone before a callback is handled. Since the cmeditor goes away in response
    % to a matlab event from the figure and these callbacks are coming from JAVA, there
    % is no guarantee on the order of these events. Therefore, don't error, just igonre.
    %    error('MATLAB:colormapeditor:CmeditorExpected', 'expected cmeditor to still be there')
    return;
end

if eventData.getOperation()==MLQue.CURRENT_FIGURE_UPDATE
    cme = eventData.getEditor;
end
fig = handle(cme.getFigure); % Remove java wrapper

funcode    = eventData.getOperation();
args       = eventData.getArguments();
resultSize = eventData.getResultSize;
source     = eventData.getSource;

if ~isequal(cme,cme_)
    error('MATLAB:colormapeditor:ExpectedCmeditor', 'expected cmeditor to still be there')
end

import com.mathworks.page.cmapeditor.MLQue

switch(funcode)
 case MLQue.CMAP_UPDATE
  cmap_update(fig,args);
 case MLQue.CLIM_UPDATE
  clim_update(fig,args);
 case MLQue.CMAP_STD
  source.finished(funcode, stdcmap(args, resultSize), cme);
 case MLQue.CMAP_EDITOR_OFF
  kill_listeners(fig);
 case MLQue.CHOOSE_COLOR
  source.finished(funcode, choosecolor(args), cme);
 case MLQue.CURRENT_FIGURE_UPDATE
  oldfig = handle(eventData.getEditor.getFigure);
  drawnow
  fig = get(0,'CurrentFigure');
  if ~isequal(oldfig,fig)
      oldax = [];
      if ~isempty(oldfig) && ishghandle(oldfig)
          oldax = get(oldfig,'CurrentAxes');
      end
      set_current_figure(fig,oldfig,oldax);
  end
end

%----------------------------------------------------------------------%
function cmap_update(fig,map)

%if ~ishandle_valid(fig)
if ~any(ishandle_valid(fig))
    return;
end

cmap_listen_enable(fig,'off');
set(fig,'Colormap',map);
cmap_listen_enable(fig,'on');

handles=guidata(fig);
index=DPABI_VIEW('HeaderIndex', handles);
OverlayHeader=handles.OverlayHeaders{index};
OverlayHeader.ColorMap=colormap;
OverlayHeader.cbarstring='0';
OverlayHeader=DPABI_VIEW('RedrawOverlay', OverlayHeader);

handles.OverlayHeaders{index}=OverlayHeader;
guidata(fig, handles);


%----------------------------------------------------------------------%
function clim_update(fig,lims)

%if ~ishandle_valid(fig)
if ~any(ishandle_valid(fig))
    return;
end
ax = get(fig,'CurrentAxes');
%if ~ishandle_valid(ax)
if ~any(ishandle_valid(ax))
    return;
end

cmap_listen_enable(fig,'off');
set(ax,'clim',lims);
cmap_listen_enable(fig,'on');

%----------------------------------------------------------------------%
function map=choosecolor(vals)

r = vals(1);
g = vals(2);
b = vals(3);
map=uisetcolor([r,g,b],xlate('Select Marker Color'));

%----------------------------------------------------------------------%
function map=stdcmap(maptype, mapsize)

import com.mathworks.page.cmapeditor.MLQue

switch maptype
 case MLQue.AUTUMN
  map = autumn(mapsize);
 case MLQue.BONE
  map = bone(mapsize);
 case MLQue.COLORCUBE
  map = colorcube(mapsize);
 case MLQue.COOL
  map = cool(mapsize);
 case MLQue.COPPER
  map = copper(mapsize);
 case MLQue.FLAG
  map = flag(mapsize);
 case MLQue.GRAY
  map = gray(mapsize);
 case MLQue.HOT
  map = hot(mapsize);
 case MLQue.HSV
  map = hsv(mapsize);
 case MLQue.JET
  map = jet(mapsize);
 case MLQue.LINES
  map = lines(mapsize);
 case MLQue.PINK
  map = pink(mapsize);
 case MLQue.PRISM
  map = prism(mapsize);
 case MLQue.SPRING
  map = spring(mapsize);
 case MLQue.SUMMER
  map = summer(mapsize);
 case MLQue.VGA
  map = vga;  % special case takes no size
 case MLQue.WHITE
  map = white(mapsize);
 case MLQue.WINTER
  map = winter(mapsize);
end

%----------------------------------------------------------------------%
% function cmeditor_off(fig)
% destroy any remaining listeners and remove the only one


%----------------------------------------------------------------------%
%   MATLAB listener callbacks
%----------------------------------------------------------------------%
function currentFigureChanged(hProp, eventData, oldfig, oldax) %#ok<INUSL>
% hProp is not used
if feature('HGUsingMATLABClasses')
    fig = eventData.AffectedObject.CurrentFigure;
else
    fig = eventData.NewValue;
end
get(0, 'CurrentFigure');
set_current_figure(fig,oldfig,oldax);

%----------------------------------------------------------------------%
%   Figure listener callbacks
%----------------------------------------------------------------------%
function cmapChanged(hProp, eventData, fig) %#ok<INUSL>
% hProp is not used
try
    update_colormap(get(fig,'Colormap'))
catch err
    warning(err.identifier,'%s',err.message);
end

%----------------------------------------------------------------------%
function currentAxesChanged(hProp, eventData, oldfig, oldax) %#ok<INUSL>

if feature('HGUsingMATLABClasses')
   ax = get(eventData.AffectedObject,'CurrentAxes');
else
   ax = eventData.NewValue;
end
set_current_axes(ax,oldfig,oldax);

%----------------------------------------------------------------------%
function figureDestroyed(hProp,eventData,oldfig,oldax) %#ok<INUSL>


nfigs = length(findobj(0,'type','figure','handlevisibility','on'));
% We need to check that get_cmapeditor is not empty here because when
% the test point tcolormapeditor lvlTwo_Listeners is run for
% HGUsingMATLABClasses, the call to close all closes the figure
% linked to the ColorMapEditor after the unlinked figure, so nfigs==1 %
% then this callback fires. In this case kill_listeners expects 
% that a getappdata(0,'CMEditor') is not empty, which it normally would not
% be but in the testpoint appdata(0,'CMEditor') was cleared.
if nfigs<=1 && ~isempty(get_cmapeditor)% the one being destroyed
    destroy_matlab_listeners;
    destroy_figure_listeners(oldfig);
    destroy_axes_listeners(oldax);
    kill_listeners(oldfig);
else 
    fig=get(0,'currentfigure');
    set_current_figure(fig,oldfig,oldax);
end

%----------------------------------------------------------------------%
%   Axes Listener Callbacks
%----------------------------------------------------------------------%
function climChanged(hProp, eventData, ax) %#ok<INUSL>

cme = get_cmapeditor();
if isempty(cme)
    return
end
clim = get(ax,'Clim');
cme.getModel.setColorLimits(clim,0);

%----------------------------------------------------------------------%
function axesDestroyed(hProp, eventData, oldfig, oldax) %#ok<INUSL>

cme = get_cmapeditor();
if isempty(cme)
    return;
end

fig = handle(cme.getFigure); % Remove java wrapper
if ~any(ishandle_valid(fig))
    return;
end
ax = get(fig,'currentaxes');
set_current_axes(ax,oldfig,oldax);

%----------------------------------------------------------------------%
%   Helpers
%----------------------------------------------------------------------%
function set_current_figure(fig,oldfig,oldax)

if ~any(ishandle_valid(fig)) || isequal(fig,oldfig)
    return;
end

if strncmpi (get(handle(fig),'Tag'), 'Msgbox', 6) || ...
    strcmpi (get(handle(fig),'Tag'), 'Exit') || ...
    strcmpi (get(handle(fig),'WindowStyle'), 'Modal')
    return;
end

cme = get_cmapeditor();
if isempty(cme)
    return;
end

ax = get(fig,'CurrentAxes');
% get rid of old figure listeners
destroy_figure_listeners(oldfig);
% get rid of old axes listeners
destroy_axes_listeners(oldax);
cme.setFigure (java(handle(fig)));
create_matlab_listeners(fig,ax);
update_colormap(get(fig,'Colormap'))
create_figure_listeners(fig,ax);

handle_axes_change(fig,ax,true);

%----------------------------------------------------------------------%
function set_current_axes(ax,oldfig,oldax)

if ~any(ishandle_valid(ax)) || isequal(ax,oldax)
    return;
end

fig = ancestor(ax,'figure');

% get rid of old axes listeners
destroy_axes_listeners(oldax);

% if the new axes is invalid, get out now
if ~any(ishandle_valid(ax))
    kill_listeners(oldfig);
    return;
end

create_matlab_listeners(fig,ax);
create_figure_listeners(fig,ax);

handle_axes_change(fig, ax, true);

%----------------------------------------------------------------------%
function cmap_listen_enable(fig,onoff)

% figure listeners
if ~any(ishandle_valid(fig))
    return;
end
% just cmap
if isappdata(fig,'CMEditFigListeners')
    fl = getappdata(fig,'CMEditFigListeners');
    if isobject(fl.cmapchanged)
        fl.cmapchanged.Enabled = strcmpi(onoff,'on');
    else
        set(fl.cmapchanged,'Enabled',onoff);
    end
    setappdata(fig,'CMEditFigListeners',fl);
end

% axes listeners
ax = get(fig,'CurrentAxes');
if any(ishandle_valid(ax,'CMEditAxListeners'))
    al = getappdata(ax,'CMEditAxListeners');
    if isobject(al.climchanged)
        al.climchanged.Enabled = strcmpi(onoff,'on');
    else
        set(al.climchanged,'Enabled',onoff);
    end
    setappdata(ax,'CMEditAxListeners',al);
end

%----------------------------------------------------------------------%
function start_listeners(fig,ax)

create_matlab_listeners(fig,ax);
create_figure_listeners(fig,ax);

handle_axes_change(fig,ax,true);

%----------------------------------------------------------------------%
function kill_listeners(fig)

% make sure the colormap editor is gone
cme = get_cmapeditor();
if isempty(cme)
    error('MATLAB:colormapeditor:ColormapeditorAppdataExpected',...
        'expected colormapeditor appdata to still be there')
end
cme.close;

% we need to kill these now, otherwise we'll leak the listeners and
% they will continue to fire after this colormap editor is gone
destroy_matlab_listeners

if any(ishandle_valid(fig))
    destroy_figure_listeners(fig);

    % axes
    ax = get(fig,'CurrentAxes');

    % return if no current axes or it is being destroyed
    if any(ishandle_valid(ax))
        destroy_axes_listeners(ax);
    end
end

% now flush out the cmap editor handle
rm_cmapeditor();

%----------------------------------------------------------------------%
function create_matlab_listeners(fig,ax)

if feature('HGUsingMATLABClasses')
   rt = handle(0);
   ml.cfigchanged = event.proplistener(rt,rt.findprop('CurrentFigure'), ...
        'PostSet',@(es,ed) currentFigureChanged(es,ed,fig,ax));
else
    cls = classhandle(handle(0));
    ml.cfigchanged = handle.listener(0, cls.findprop('CurrentFigure'), ...
        'PropertyPostSet', {@currentFigureChanged, fig, ax});
end
setappdata(0,'CMEditMATLABListeners',ml);

%----------------------------------------------------------------------%
function destroy_matlab_listeners


if isappdata(0,'CMEditMATLABListeners');
    % we actually need to delete these handles or they
    % will continue to fire
    ld = getappdata(0,'CMEditMATLABListeners');
    fn = fields(ld);
    for i = 1:length(fn)
        l = ld.(fn{i});
        if ishghandle(l)
            delete(l);
        end
    end
    rmappdata(0,'CMEditMATLABListeners');
end

%----------------------------------------------------------------------%
function create_figure_listeners(fig,ax)

if any(ishandle_valid(fig))
    
    fig = handle(fig);
    if feature('HGUsingMATLABClasses')
        fl.deleting = event.listener(fig, ...
                  'ObjectBeingDestroyed', @(es,ed) figureDestroyed(es,ed,fig, ax));
        fl.cmapchanged = event.proplistener(fig,fig.findprop('Colormap'), ...
                  'PostSet',@(es,ed) cmapChanged(es,ed,fig));
        fl.caxchanged = event.proplistener(fig, fig.findprop('CurrentAxes'), ...
                  'PostSet',@(es,ed) currentAxesChanged(es,ed,fig,ax));
    else     
        cls = classhandle(handle(fig));
        fl.deleting = handle.listener(fig, ...
                  'ObjectBeingDestroyed', {@figureDestroyed,fig, ax});
        fl.cmapchanged = handle.listener(fig, cls.findprop('Colormap'), ...
                  'PropertyPostSet', {@cmapChanged, fig});
        fl.caxchanged = handle.listener(fig, cls.findprop('CurrentAxes'), ...
                  'PropertyPostSet', {@currentAxesChanged, fig, ax});
    end
    setappdata(fig,'CMEditFigListeners',fl);
end

%----------------------------------------------------------------------%
function enable_figure_listeners(fig,onoff)

if any(ishandle_valid(fig, 'CMEditFigListeners'))
    fl = getappdata(fig,'CMEditFigListeners');
    if isobject(fl.cmapchanged)
        fl.cmapchanged.Enabled = strcmpi(onoff,'on');
    else
        set(fl.cmapchanged,'Enabled',onoff);
    end
    if isobject(fl.caxchanged)
        fl.caxchanged.Enabled = strcmpi(onoff,'on');
    else
        set(fl.caxchanged,'Enabled',onoff);
    end
    if isobject(fl.deleting)
        fl.deleting.Enabled = strcmpi(onoff,'on');
    else
        set(fl.deleting,'Enabled',onoff);
    end
    setappdata(fig,'CMEditFigListeners',fl);
end

%----------------------------------------------------------------------%
function destroy_figure_listeners(fig)

enable_figure_listeners(fig,'off');
if any(ishandle_valid(fig, 'CMEditFigListeners'))
    rmappdata(fig,'CMEditFigListeners');
end

%----------------------------------------------------------------------%
function create_axes_listeners(fig,ax)

if any(ishandle_valid(ax))
    if feature('HGUsingMATLABClasses')
        al.deleting = event.listener(ax, ...
                  'ObjectBeingDestroyed',@(es,ed) axesDestroyed(es,ed,fig,ax));
        al.climchanged = event.proplistener(ax,ax.findprop('Clim'), ...
                  'PostSet', @(es,ed) climChanged(es,ed,ax));
    else
        cls = classhandle(handle(ax));
        ax = handle(ax);
        al.deleting = handle.listener(ax, ...
                  'ObjectBeingDestroyed',{@axesDestroyed,fig,ax});
        al.climchanged = handle.listener(ax, cls.findprop('Clim'), ...
                  'PropertyPostSet', {@climChanged, ax});
    end
    setappdata(ax,'CMEditAxListeners',al);
end

%----------------------------------------------------------------------%
function enable_axes_listeners(ax,onoff)

if any(ishandle_valid(ax, 'CMEditAxListeners'))
    al = getappdata(ax,'CMEditAxListeners');
    if isobject(al.climchanged)
        al.climchanged.Enabled = strcmpi(onoff,'on');
    else
        set(al.climchanged,'Enabled',onoff);
    end
    if isobject(al.deleting)
        al.deleting.Enabled = strcmpi(onoff,'on');
    else
        set(al.deleting,'Enabled',onoff);
    end
    setappdata(ax,'CMEditAxListeners',al);
end

%----------------------------------------------------------------------%
function destroy_axes_listeners(ax)

enable_axes_listeners(ax,'off');
if any(ishandle_valid(ax, 'CMEditAxListeners'))
    rmappdata(ax,'CMEditAxListeners');
end

%----------------------------------------------------------------------%
function update_colormap(cmap)
check_colormap(cmap);
cme = get_cmapeditor();
if ~isempty(cme) && ~isempty(cme.getModel) 
    % cme.getModel.setColorMapModel(cmap);
    cme.getModel.setBestColorMapModel(cmap);
end

%----------------------------------------------------------------------%
function yesno = ishandle_valid(h,appdata_field)
error(nargchk(1,2,nargin,'struct'));

if nargin == 1
    appdata_field = [];
end
yesno = any(ishghandle(h)) && ~strcmpi('on',get(h,'BeingDeleted'));
if yesno && ~isempty(appdata_field)
    yesno = yesno && isappdata(h,appdata_field);
end        

%----------------------------------------------------------------------%
function handle_axes_change(fig,ax,create_listeners)
cme = get_cmapeditor();
if isempty(cme)
    return;
end
if isempty(cme.getFrame) || isempty(cme.getModel)
    return;
end

if ~any(ishandle_valid(ax))
    cme.getFrame.setColorLimitsEnabled(0);
else
    clim = get(ax,'Clim');
    cme.getFrame.setColorLimitsEnabled(1);
    cme.getModel.setColorLimits(clim,0);
    if (create_listeners)
        create_axes_listeners(fig,ax);
    end
end

%----------------------------------------------------------------------%
function check_colormap(cmap)
if isempty(cmap)
    error('MATLAB:colormapeditor:ColormapEmpty', 'Empty colormap');
end

%----------------------------------------------------------------------%
function cme = get_cmapeditor
cme = getappdata(0,'CMEditor');

%----------------------------------------------------------------------%
function set_cmapeditor(cme)
setappdata(0,'CMEditor',cme);

%----------------------------------------------------------------------%
function rm_cmapeditor
rmappdata(0,'CMEditor');


    