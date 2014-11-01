function y_ChangeImgPrefix(InputDir,CurrentPrefix,WantedPrefix)
% y_ChangeImgPrefix(InputDir,CurrentPrefix,WantedPrefix)
% Change the prefix of images in the sub-directories.
%   InputDir - where the data stores
%   CurrentPrefix - the current prefix of the images.
%   WantedPrefix - The wanted prefix.
%   Example: y_RenameImgPrefix('L:\T1Img','','co')
%         - Add prefix 'co' to each image in sub-directories of L:\T1Img to let DPARSF use them.
%___________________________________________________________________________
% Written by YAN Chao-Gan 091127.
% State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University, China, 100875
% ycg.yan@gmail.com

OldDir=pwd;
SubDir=dir([InputDir,filesep,'*']);
if strcmpi(SubDir(3).name,'.DS_Store')  %110908 YAN Chao-Gan, for MAC OS compatablie
    StartIndex=4;
else
    StartIndex=3;
end
for i=StartIndex:length(SubDir)
    cd ([InputDir,filesep,SubDir(i).name]);
    FileList=dir([CurrentPrefix,'*.img']);
    for j=1:length(FileList)
        NewFilename=FileList(j).name;
        NewFilename=[WantedPrefix,NewFilename(length(CurrentPrefix)+1:end)];
        movefile(FileList(j).name,NewFilename);
    end
    FileList=dir([CurrentPrefix,'*.hdr']);
    for j=1:length(FileList)
        NewFilename=FileList(j).name;
        NewFilename=[WantedPrefix,NewFilename(length(CurrentPrefix)+1:end)];
        movefile(FileList(j).name,NewFilename);
    end
end

cd(OldDir);