function IndividualROI = y_CheckIndividualROI(ROIDef, iSub, Flags)
% function IndividualROI = y_CheckIndividualROI(ROIDef, iSub, Flags)
% Check and get Individual ROI
%   Input:
%     ROIDef - ROIDef, any .txt definition would be checked
%     Flags - can be: 'Seed_Time_Course_List:'; 'Seed_ROI_List:'; 'Covariables_List:'
%   Output:
%     IndividualROI - the Individual ROI for iSub
%___________________________________________________________________________
% Written by YAN Chao-Gan 210415.
% Key Laboratory of Behavioral Science and Magnetic Resonance Imaging Research Center, Institute of Psychology, Chinese Academy of Sciences, Beijing, China
% ycg.yan@gmail.com

if ~exist('Flags','var') || isempty(Flags)
    Flags={'Seed_Time_Course_List:'; 'Seed_ROI_List:'; 'Covariables_List:'};
end

IndividualROI=ROIDef;

for iROI=1:length(ROIDef)
    if (ischar(ROIDef{iROI})) && (exist(ROIDef{iROI},'file')==2)
        [pathstr, name, ext] = fileparts(ROIDef{iROI});
        if (strcmpi(ext, '.txt'))
            fid = fopen(ROIDef{iROI});
            SeedTimeCourseList=textscan(fid,'%s\n');
            fclose(fid);
            
            IsIndividualROI = 0;
            for iFlag=1:length(Flags)
                if strcmpi(SeedTimeCourseList{1}{1},Flags{iFlag})
                    IsIndividualROI=1;
                end
            end
            
            if IsIndividualROI
                IndividualROI{iROI}=SeedTimeCourseList{1}{iSub+1};
            end
        end
    end
    
end


