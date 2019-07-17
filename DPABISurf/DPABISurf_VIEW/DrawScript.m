% [AxesObj, Fcn]=w_RenderSurf('/Users/ycg/Dropbox/ITraAllOnline/ITraAll/ITraDropBox/GoogleDrive/ITraActive/Programs/DPABI/Github/DPABI/DPABISurf/SurfTemplates/fsaverage5_lh_inflated.surf.gii');
% Fcn.AddOverlay('T2.gii'); % Your Overlay Gifti;
% Fcn.SetOverlayThres(1, -3, -1, 1, 3);
% Fcn.SetOverlayColorMap(1, colormap('jet(64)'), '');
% OneFig=Fcn.SaveMontage('L', 'Test_L.tif');
% 
% [AxesObj, Fcn]=w_RenderSurf('/Users/ycg/Dropbox/ITraAllOnline/ITraAll/ITraDropBox/GoogleDrive/ITraActive/Programs/DPABI/Github/DPABI/DPABISurf/SurfTemplates/fsaverage5_rh_inflated.surf.gii');
% Fcn.AddOverlay('T2.gii'); % Your Overlay Gifti;
% Fcn.SetOverlayThres(1, -3, -1, 1, 3);
% Fcn.SetOverlayColorMap(1, colormap('jet(64)'), '');
% OneFig=Fcn.SaveMontage('R', 'Test_R.tif');
% 
% figure, montage({'Test_L.tif', 'Test_R.tif'})

[AxesObj, Fcn]=w_RenderSurf('../SurfTemplates/fsaverage5_lh_inflated.surf.gii');
Fcn.SetYokedFlag(1);
%Fcn.MoveDataCursor([-32.6368 54.6919 21.3212]);
%Fcn.UpdateAllYokedViewer();