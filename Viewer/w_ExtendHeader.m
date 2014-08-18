function OverlayHeader=w_ExtendHeader(OverlayHeader)

OverlayHeader=w_ReadDF(OverlayHeader);
OverlayHeader=w_ReadDLH(OverlayHeader);
OverlayHeader.CSize=0;
OverlayHeader.RMM=18;
OverlayHeader.IsSelected=0;
OverlayHeader.ThrdIndex='';
OverlayHeader.MaskFile='';
OverlayHeader.Mask=true(OverlayHeader.dim);
OverlayHeader.Percentage=100;