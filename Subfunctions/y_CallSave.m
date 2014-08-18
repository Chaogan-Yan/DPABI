function y_CallSave(FileName,Data,Option)
% function y_CallSave(FileName,Data,Option)
% Call save for parfor usage. ('save' is not suitable for 'parfor')
% Input:
% 	FileName	 -   The output File name. 
%   Data         -   The data want to be saved.
% 	Option       -   The option for calling save. Could be:
%                    e.g., ' ''-ASCII'', ''-DOUBLE'',''-TABS'''
% Output:
%	             -   The saved data.
%-----------------------------------------------------------
% Written by YAN Chao-Gan 140805.
% The Nathan Kline Institute for Psychiatric Research, 140 Old Orangeburg Road, Orangeburg, NY 10962, USA
% The Phyllis Green and Randolph Cowen Institute for Pediatric Neuroscience, New York University Child Study Center, New York, NY 10016, USA
% ycg.yan@gmail.com

if isempty(Option)
    eval(['save(''',FileName,''',''Data'')']);
else
    eval(['save(''',FileName,''',''Data'',',Option,')']);
end


