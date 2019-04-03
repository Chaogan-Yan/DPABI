%[AxesObj, Fcn]=w_RenderSurf('fsaverage_lh_inflated.gii');
%Fcn.SetDisplayTextureFlag(true);
%Fcn.SetBorder('fsaverage_lh_Yeo2011_7Networks_N1000_Contour.gii', 'Off');
%Fcn.SetBorder('fsaverage_lh_Yeo2011_7Networks_N1000_Contour.gii', 'On');

[AxesObj, Fcn]=w_RenderSurf('SurfTemplates/fsaverage5_rh_white.surf.gii');

Fcn.SetOverlayThres(1, 0, 0, 0.5, 1);
Fcn.SetOverlayColorMap(1, colormap('jet(64)'), '+')
Fcn.SetOverlayThresPN_Flag(1, '-');
CSizeOpt=Fcn.GetOverlayClusterSizeOption(1);
CSizeOpt.Thres=100;
Fcn.SetOverlayClusterSizeOption(1, CSizeOpt);

[AxesObj, Fcn]=w_RenderSurf('lh.inflated.gii');
Fcn.SetDisplayTextureFlag(false);
Fcn.AddOverlay('T2.gii');
Fcn.SetOverlayThres(1, 0, 0, 0.5, 1);

%[AxesObj, Fcn]=w_RenderSurf('glasser.white.surf.gii');
%Fcn.SetDisplayTextureFlag(true);
%Fcn.SetBorder('untitled.gii', 'On');
