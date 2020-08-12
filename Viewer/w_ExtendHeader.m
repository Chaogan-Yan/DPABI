function OverlayHeader=w_ExtendHeader(OverlayHeader)

OverlayHeader=w_ReadDF(OverlayHeader);
OverlayHeader=w_ReadFWHM(OverlayHeader);
OverlayHeader.CSize=0;
OverlayHeader.RMM=18;
OverlayHeader.IsSelected=0;
OverlayHeader.ThrdIndex='';
OverlayHeader.MaskFile='';
OverlayHeader.Mask=true(OverlayHeader.dim);
OverlayHeader.Percentage=0.05; %YAN Chao-Gan 161210. Changed from 100 to 0.05 for applying p mask.
OverlayHeader.AMaskFile='';
OverlayHeader.AMask=true(OverlayHeader.dim);
