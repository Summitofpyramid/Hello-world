
% this file is to generate the stageData automatically
clear,clc
stageDate = struct;

rootPath = '/Users/stuartfogel/Documents/sleepsmg-code/Data/';

subjectsFolder = dir(rootPath);
subjectsFolder = subjectsFolder(4:end);

targetPath = '/Users/stuartfogel/Documents/sleepsmg-code/stageDatas';

if ~exist(targetPath,'dir')
    mkdir(targetPath)
end

windowSize = 20;
%1:length(subjectsFolder)
for i = 30:length(subjectsFolder)
    current = subjectsFolder(i).name;
    if exist([rootPath current '/' current '.mat'],'file')
        EEGinfo = dir([rootPath current '/' current '.mat']);
    else 
        continue;
    end
    EEG = pop_loadset('filename',EEGinfo.name,'filepath',EEGinfo.folder);
    EEG = eeg_checkset(EEG);
    [data,header] = ebm2mat([rootPath current '/']);
    [originalEvents] = ebmevents2mat([EEGinfo.folder '/']);
    
    events = string(originalEvents{1,2});
    
    lightsOnIndex = find(events=='Lights On');
    lightsOffIndex = find(events=='Lights Off');
    % set the stageData fields
    stageData.srate = EEG.srate;
    stageData.recStart = header.starttime;
    stageData.win = windowSize;
    stageData.Notes  = 'Notes:';
    % set the lightsON and lightsOFF datenums
    
    temp2 = originalEvents{1,1}{lightsOffIndex(end),1};
    
    
    for j=1:length(lightsOnIndex)
        temp1 = originalEvents{1,1}{lightsOnIndex(j),1};
        if (etime(datevec(temp1),datevec(temp2)))>0
            break;
        end
    end
    
    
    temp1 = datestr(datenum(temp1,'HH:MM:SS AM.FFF'),'HH:MM:SS.FFF');
    temp2 = datestr(datenum(temp2,'HH:MM:SS AM.FFF'),'HH:MM:SS.FFF');
   
    stageData.lightsON = datenum([header.startdate ' '  temp1]);
    stageData.lightsOFF =datenum([header.startdate ' '  temp2]);
    stageData.onsets = (0*ones(1,ceil(EEG.pnts/EEG.srate/windowSize)))';
    stageData.stages = (7*ones(1,ceil(EEG.pnts/EEG.srate/windowSize)))';
    stageData.stageTime = 0:windowSize/60:EEG.pnts/EEG.srate/60;
    %stageData.onset
    
    save([targetPath '/' current '_stageData.mat'],'stageData');
    clearvars -except rootPath subjectsFolder targetPath windowSize
end 
