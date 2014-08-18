function ret = w_spm_ov_reorient(varargin)
% Reorient tool - plugin for y_spm_orthviews
%
% This tool provides the capabilities of the reorientation widget in SPMs
% "DISPLAY" for any image displayed within y_spm_orthviews. The control fields
% are drawn in the SPM interactive window and work as described in the
% Display routine.
% The advantage of using this tool within CheckReg is that it allows to
% reorient images while comparing their position to reference images
% simultaneously.
%
% This routine is a plugin to y_spm_orthviews for SPM8. For general help about
% y_spm_orthviews and plugins type
%             help y_spm_orthviews
% at the matlab prompt.
%_____________________________________________________________________________
% $Id: spm_ov_reorient.m 4380 2011-07-05 11:27:12Z volkmar $
%
% Revised by Wang Xin-di for Multi-viewer, 20130723
% National Key Laboratory of Cognitive Neuroscience and Learning, Beijing
% Normal University, Beijing, China

rev = '$Revision: 4380 $';

global st;

if nargin<2
    curfig=GetCurFig;
else
    curfig=GetCurFig(varargin{2});
end

if isempty(st{curfig})
    error('reorient: This routine can only be called as a plugin for y_spm_orthviews!');
end;

if nargin < 2
    error('reorient: Wrong number of arguments. Usage: y_spm_orthviews(''reorient'', cmd, volhandle, varargin)');
end;

cmd = lower(varargin{1});
volhandle = varargin{2};
switch cmd
    %-------------------------------------------------------------------------
    % Context menu and callbacks
    case 'context_menu'
        item0 = uimenu(varargin{3}, 'Label', 'Reorient image(s)',...
            'Tag', ['REORIENT_M_', num2str(volhandle)]);
        item1 = uimenu(item0, 'Label', 'All images', 'Callback', ...
            ['y_spm_orthviews(''reorient'',''context_init'', 0);'],...
            'Tag', ['REORIENT_0_', num2str(volhandle)]);
        item2 = uimenu(item0, 'Label', 'Current image', 'Callback', ...
            ['y_spm_orthviews(''reorient'',''context_init'', ', ...
            num2str(volhandle), ');'],...
            'Tag', ['REORIENT_0_', num2str(volhandle)]);
        item3 = uimenu(item0, 'Label', 'Set origin to Xhairs', 'Callback', ...
            ['y_spm_orthviews(''reorient'',''context_origin'', ', ...
            num2str(volhandle), ');'],...
            'Tag', ['REORIENT_0_', num2str(volhandle)]);
        item4 = uimenu(item0, 'Label', 'Quit Reorient image', ...
            'Tag', ['REORIENT_1_', num2str(volhandle)], ...
            'Visible', 'off');
        item5 = uimenu(item0, 'Label', 'Help', 'Callback', ...
            sprintf('spm_help(''%s'');', mfilename));
        ret = item0;

    case 'context_init'
        Finter = spm_figure('GetWin', 'Interactive');
        Fgraph = spm_figure('GetWin', 'Graphics');
        figure(Finter);
        spm_input('!DeleteInputObj',Finter);
        handles = y_spm_orthviews('valid_handles');
        labels = {'right  {mm}', 'forward  {mm}', 'up  {mm}',...
            'pitch  {rad}', 'roll  {rad}', 'yaw  {rad}',...
            'resize  {x}', 'resize  {y}', 'resize {z}'};
        tooltips = {'translate', 'translate', 'translate', ...
            'rotate', 'rotate', 'rotate', ...
            'zoom', 'zoom', 'zoom', ...
            '# of contour lines to draw on other images'};
        hpos = 270:-20:90;
        if volhandle == 0
            % Reorient all images
            volhandle = handles;
            prms(7:9) = 1;
        else
            % get initial parameter values from st{curfig}.vols{volhandle}.premul
            prms = spm_imatrix(st{curfig}.vols{volhandle}.premul);
            prms(10) = 3; % default #contour lines
            labels{end+1} = '#contour lines';
        end;
        st{curfig}.vols{volhandle(1)}.reorient.order = uicontrol(...
            Finter, 'Style','PopupMenu', 'Position', [75 60 250 025], ...
            'String',{'Translation(1) Rotation(2) Zoom(3)', ...
            'Zoom(1) Translation(2) Rotation(3)', ...
            'Zoom(1) Rotation(2) Translation(3)'},...
            'Callback',['y_spm_orthviews(''reorient'',''reorient'',[',...
            num2str(volhandle),']);']);
        st{curfig}.vols{volhandle(1)}.reorient.b(1) = uicontrol(...
            Finter, 'Style','PushButton', 'Position',[75 30 165 025], ...
            'String','Apply to image(s)', ...
            'Callback',['y_spm_orthviews(''reorient'',''apply'',',...
            num2str(volhandle(1)), ');']);
        for k = handles
            % Find context menu handles
            obj = findobj(Fgraph, 'Tag',  ['REORIENT_M_', num2str(k)]);
            if any(k == volhandle)
                % Show 'Quit Reorient' for images being reoriented
                objh = findobj(obj, 'Tag', ['REORIENT_0_', num2str(k)]);
                objs = findobj(obj, 'Tag', ['REORIENT_1_', num2str(k)]);
                set(objh,'Visible','off');
                set(objs, 'Callback', ...
                    ['y_spm_orthviews(''reorient'',''context_quit'', [', ...
                    num2str(volhandle), ']);'],'Visible','on');
                st{curfig}.vols{k}.reorient.oldpremul = st{curfig}.vols{k}.premul;
            else
                % Do not show 'Reorient Images' context menu in other images
                set(obj, 'Visible', 'off');
            end;
        end;
        for k = 1:numel(labels)
            st{curfig}.vols{volhandle(1)}.reorient.l(k)=uicontrol(...
                Finter, 'Style','Text', ...
                'Position',[75 hpos(k) 100 016], 'String',labels{k});
            st{curfig}.vols{volhandle(1)}.reorient.e(k) = uicontrol(...
                Finter, 'Style','edit', ...
                'Callback',['y_spm_orthviews(''reorient'',''reorient'',[',...
                num2str(volhandle),'])'], ...
                'Position',[175 hpos(k) 065 020], 'String',num2str(prms(k)), ...
                'ToolTipString',tooltips{k});
        end;
        y_spm_orthviews('redraw');

    case 'context_quit'
        Finter = spm_figure('FindWin', 'Interactive');
        Fgraph = spm_figure('FindWin', 'Graphics');
        try
            delete(st{curfig}.vols{volhandle(1)}.reorient.e);
            delete(st{curfig}.vols{volhandle(1)}.reorient.l);
            delete(st{curfig}.vols{volhandle(1)}.reorient.b);
            delete(st{curfig}.vols{volhandle(1)}.reorient.order);
        catch
        end;
        if isfield(st{curfig}.vols{volhandle(1)}.reorient,'lh')
            if ~isempty(st{curfig}.vols{volhandle(1)}.reorient.lh)
                delete(cat(1,st{curfig}.vols{volhandle(1)}.reorient.lh{:}));
            end;
        end;

        for k = y_spm_orthviews('valid_handles')
            try
                st{curfig}.vols{k}.premul = st{curfig}.vols{k}.reorient.oldpremul;
                st{curfig}.vols{k} = rmfield(st{curfig}.vols{k},'reorient');
            catch
            end;
            obj = findobj(Fgraph, 'Tag',  ['REORIENT_M_', num2str(k)]);
            if any(k == volhandle)
                objh = findobj(obj, 'Tag', ['REORIENT_1_', num2str(k)]);
                set(objh, 'Visible', 'off', 'Callback','');
                objs = findobj(obj, 'Tag', ['REORIENT_0_', num2str(k)]);
                set(objs, 'Visible', 'on');
            else
                set(obj, 'Visible', 'on');
            end;
        end;
        y_spm_orthviews('redraw');

    case 'context_origin'
        pos = y_spm_orthviews('pos');
        P = {st{curfig}.vols{volhandle}.fname};
        qu = questdlg({'If you have other images coregistered to this image, you may shift their origin by the same amount.', ...
            'Do you want to do this?'},'Select other images', ...
            'This image only','Add other images','Cancel','This image only');
        if isempty(qu) || strcmpi(qu, 'cancel')
            disp('''Set origin to Xhairs'' cancelled.');
            return;
        end            
        if strcmpi(qu, 'add other images')
            [p n e v] = spm_fileparts(st{curfig}.vols{volhandle}.fname);
            P = cellstr(spm_select(Inf, 'image', {'Image(s) to reorient'}, P, p));
            if isempty(P) || isempty(P{1})
                disp('''Set origin to Xhairs'' cancelled.');
                return;
            end
        end
        st{curfig}.vols{volhandle}.premul = spm_matrix(-pos');
        spm_jobman('serial','','spm.util.reorient',P,st{curfig}.vols{volhandle}.premul);
        sv = questdlg('Do you want to save the reorientation matrix for future reference?','Save Matrix','Yes','No','Yes');
        if strcmpi(sv, 'yes')
            [p n] = spm_fileparts(st{curfig}.vols{volhandle}.fname);
            [f,p] = uiputfile(fullfile(p, [n '_reorient.mat']));
            if ~isequal(f,0)
                M = st{curfig}.vols{volhandle}.premul;
                save(fullfile(p,f),'M');
            end
        end
        qu = questdlg({'Image positions are changed!', ...
            'To make sure images are displayed correctly, it is recommended to quit and restart y_spm_orthviews now.', ...
            'Do you want to quit?'},'Reorient done','Yes','No','Yes');
        if strcmpi(qu, 'yes')
            y_spm_orthviews('reset');
            return;
        end;


        %-------------------------------------------------------------------------
        % Interaction callbacks

    case 'apply'
        [p n e v] = spm_fileparts(st{curfig}.vols{volhandle}.fname);
        P = cellstr(spm_select(Inf, 'image', {'Image(s) to reorient'}, '', p));
        if ~isempty(P) && ~isempty(P{1})
            spm_jobman('serial','','spm.util.reorient',P,st{curfig}.vols{volhandle}.premul);
            st{curfig}.vols{volhandle}.reorient.oldpremul = eye(4);
            sv = questdlg('Do you want to save the reorientation matrix for future reference?','Save Matrix','Yes','No','Yes');
            if strcmpi(sv, 'yes')
                [p n] = spm_fileparts(st{curfig}.vols{volhandle}.fname);
                [f,p] = uiputfile(fullfile(p, [n '_reorient.mat']));
                if ~isequal(f,0)
                    M = st{curfig}.vols{volhandle}.premul;
                    save(fullfile(p,f),'M');
                end
            end
            qu=questdlg({'Image positions are changed!', ...
                'To make sure images are displayed correctly, it is recommended to quit and restart y_spm_orthviews now.', ...
                'Do you want to quit?'},'Reorient done','Yes','No','Yes');
            if strcmpi(qu, 'yes')
                y_spm_orthviews('reset');
                return;
            end;
        end;
        y_spm_orthviews('reorient','context_quit', volhandle);

    case 'reorient'
        prms=zeros(1,12);
        for k=1:9
            prms(k) = evalin('base',[get(st{curfig}.vols{volhandle(1)}.reorient.e(k),'string') ';']);
        end;
        switch get(st{curfig}.vols{volhandle(1)}.reorient.order, 'value')
            case 1,
                order = 'Z*S*R*T';
            case 2,
                order = 'R*T*Z*S';
            case 3,
                order = 'T*R*Z*S';
        end;
        for k = volhandle
            st{curfig}.vols{k}.premul = spm_matrix(prms,order)* ...
                st{curfig}.vols{k}.reorient.oldpremul;
        end;
        y_spm_orthviews('redraw');

    case 'redraw'
        if isfield(st{curfig}.vols{volhandle}.reorient, 'e') && numel(st{curfig}.vols{volhandle}.reorient.e)==10
            if isfield(st{curfig}.vols{volhandle}.reorient,'lh')
                if ~isempty(st{curfig}.vols{volhandle}.reorient.lh)
                    delete(cat(1,st{curfig}.vols{volhandle}.reorient.lh{:}));
                end;
            end;
            st{curfig}.vols{volhandle}.reorient.lh = {};
            ncl = str2double(get(st{curfig}.vols{volhandle}.reorient.e(10),'string'));
            if ncl > 0
                todraw=y_spm_orthviews('valid_handles');
                for d = 1:3
                    CData = sqrt(sum(get(st{curfig}.vols{volhandle}.ax{d}.d,'CData').^2, 3));
                    CData(isinf(CData)) = NaN;
                    for h = todraw
                        if h ~= volhandle
                            axes(st{curfig}.vols{h}.ax{d}.ax);
                            hold on;
                            [C st{curfig}.vols{volhandle}.reorient.lh{end+1}]=contour(CData,ncl,'r-');
                        end;
                    end;
                end;
                set(cat(1,st{curfig}.vols{volhandle}.reorient.lh{:}),'HitTest','off');
            end;
        end;
    otherwise
        fprintf('y_spm_orthviews(''reorient'', ...): Unknown action %s', cmd);
end;

function fig = GetCurFig(h)

fig=gcf;
if isempty(fig)
    fig=get(0, 'CurrentFigure');
    if rem(fig,1)
        fig=h;
        set(0,'CurrentFigure',h);
        return;
    end
    
    if isempty(fig)
        fig=0;
    end
end