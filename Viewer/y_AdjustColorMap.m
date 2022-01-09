function NewColorMap = y_AdjustColorMap(OriginalColorMap,NullColor,NMax,NMin,PMin,PMax, PN_Flag)
% Adjust the colormap to leave blank to values under threshold, the orginal color map with be set into [NMax NMin] and [PMin PMax].
% Input: OriginalColorMap - the original color map
%        NullColor - The values between NMin and PMin will be set to this color (leave blank)
%        NMax, NMin, PMin, PMax - set the axis of colorbar (the orginal color map with be set into [NMax NMin] and [PMin PMax])
% Output: NewColorMap - the generated color map, a 100000 by 3 matrix.
%___________________________________________________________________________
% Written by YAN Chao-Gan 111023.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% Child Mind Institute, 445 Park Avenue, New York, NY 10022, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com

NewColorMap = repmat(NullColor,[100000 1]);
ColorLen=size(OriginalColorMap,1);

%Add Full Colormap for Positive or Negative Value  
if exist('PN_Flag', 'var')==1
    if ~isempty(PN_Flag)
        if strcmpi(PN_Flag, '+')
            if PMax==PMin
                PMin=PMin-realmin;
            end
            PositiveColorSegment = ceil(100000*(PMax-PMin)/(PMax-NMax)/(ColorLen));
            for iColor=ColorLen:-1:1
                Segment=PositiveColorSegment;
                Begin=100000-(ColorLen-iColor+1)*PositiveColorSegment+1;
                if Begin < 1
                    Segment=Segment-(1-Begin);
                    Begin=1;        
                end
                End=100000-(ColorLen-iColor)*PositiveColorSegment;
                if End > 100000
                    Segment=Segment-(End-100000);
                    End=100000;
                end
                NewColorMap(Begin:End,:) = repmat(OriginalColorMap(iColor,:),[Segment 1]);
            end            
        elseif strcmpi(PN_Flag, '-')
            NegativeColorSegment = ceil(100000*(NMin-NMax)/(PMax-NMax)/(ColorLen));
            for iColor=1:ColorLen
                Segment=NegativeColorSegment;
                Begin=(iColor-1)*NegativeColorSegment+1;
                if Begin < 1
                    Segment=Segment-(1-Begin);
                    Begin=1;
                end
                End=(iColor)*NegativeColorSegment;
                if End > 100000
                    Segment=Segment-(End-100000);
                    End=100000;
                end
                NewColorMap(Begin:End,:) = repmat(OriginalColorMap(iColor,:),[Segment 1]);
            end
        end
        
        return
    end
end

NegativeColorSegment = ceil(100000*(NMin-NMax)/(PMax-NMax)/(ColorLen/2));
for iColor=1:fix(ColorLen/2)
    Segment=NegativeColorSegment;
    Begin=(iColor-1)*NegativeColorSegment+1;
    if Begin < 1
        Segment=Segment-(1-Begin);
        Begin=1;
    end
    End=(iColor)*NegativeColorSegment;
    if End > 100000
        Segment=Segment-(End-100000);
        End=100000;
    end
    NewColorMap(Begin:End,:) = repmat(OriginalColorMap(iColor,:),[Segment 1]);
end

if PMax==PMin
    PMin=PMin-(PMax/10000); %YAN Chao-Gan, 220109. PMin=PMin-realmin;
end
PositiveColorSegment = ceil(100000*(PMax-PMin)/(PMax-NMax)/(ColorLen/2));
for iColor=ColorLen:-1:ceil(ColorLen/2+1)
    Segment=PositiveColorSegment;
    Begin=100000-(ColorLen-iColor+1)*PositiveColorSegment+1;
    if Begin < 1
        Segment=Segment-(1-Begin);
        Begin=1;        
    end
    End=100000-(ColorLen-iColor)*PositiveColorSegment;
    if End > 100000
        Segment=Segment-(End-100000);
        End=100000;
    end
    NewColorMap(Begin:End,:) = repmat(OriginalColorMap(iColor,:),[Segment 1]);
end