%this script is to replace old .txt files in the subject folders with new .txt files in 
% DD_HoriScoringEventsFiles folers
%By Qiangsen He, on Mar.9th 2017
close all;clear,clc
rootpath = '/Users/JohnsonJohnson/Desktop/DrowsyDriving/';
Subjects = dir([rootpath 'Data']);
Subjects(1:3)=[]; % remove '.','..' and 'DS_STORE' folders

newTxtFiles = dir([rootpath 'DD_HoriScoringEventsFiles/*.txt']);

%% Delete old txt files and copy new txt files to corresponding directory
for i = 1:length(Subjects)
    current = [rootpath 'Data/' Subjects(i).name '/'];
    
    oldtxtName = dir([current '*.txt']);
    if(~isempty(oldtxtName))
        oldtxtPath = ([current oldtxtName.name]);
        delete(oldtxtPath);
    end
    % match the corresponding txt file and path
    for j=1:length(newTxtFiles)
        if strncmp(newTxtFiles(j).name,Subjects(i).name,8)
            source = [rootpath 'DD_HoriScoringEventsFiles/' newTxtFiles(j).name];
            dest = [rootpath 'Data/' Subjects(i).name '/'];
            copyfile(source,dest);      
        end
    end
end














