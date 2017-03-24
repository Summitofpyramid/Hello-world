function FFTstats()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% CALCULATE STATS ON FFT RESULTS
%
% Aug-12-2015 - SF, orginal code
%
% Written for "Tower Expertise" study
%
% Copyright Stuart Fogel, Brain & Mind Institute, Western University
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Defualt FFT Parameters:
% PARAM = struct(...
%     'epoch', 30, ... length in seconds of sleep stage epoch {default: 30}
%     'stages', {{'W','N1','N2','N3','R'}}, ... labels of sleep stage epoch, {default: {{'W','N1','N2','N3','R,}}}
%     'baddata', {{'Movement'}}, ... label for bad data, {default: {{'Movement'}}}
%     'winsize', 5, ... size of FFT window in seconds {default: 5}. Use default for 6 windows per 30 sec sleep stage and a freq resolution of 0.2Hz.
%     'freqrange', [0 32], ... range of frequencies {default: [0 32]}
%     'plotchans', [3:5 7:9 11:14], ... vector of channel indices to include in FFT {default: [3:5 7:9 11:14]}
%     'plot', 'off' ... ['on'|'off'], plot result, {default: 'off'}
%     );
PARAM = struct(...
    'epoch', 5, ... length in seconds of sleep stage epoch {default: 30}
    'stages', {{'H0','H1','H2','H3','H4','H5','H6','H7','H8','H9'}}, ... labels of sleep stage epoch, {default: {{'W','N1','N2','N3','R,}}}
    'baddata', {{'Movement'}}, ... label for bad data, {default: {{'Movement'}}}
    'winsize', 1, ... size of FFT window in seconds {default: 5}. Use default for 6 windows per 30 sec sleep stage and a freq resolution of 0.2Hz.
    'freqrange', [0 32], ... range of frequencies {default: [0 32]}
    'plotchans', [3:5 8:12 14:18 20], ... vector of channel indices to include in FFT {default: [3:5 7:9 11:14]; i.e., C3,C4,Cz,F3,F4,Fz,Oz,P3,P4,Pz}
    'plot', 'off' ... ['on'|'off'], plot result, {default: 'off'}
    );

%% SPECIFY FILENAME(S) - OPTIONAL
%% SPECIFY FILENAME(S) - OPTIONAL
% you can manually specify filenames here, or leave empty for pop-up
    pathname = '/Users/JohnsonJohnson/Desktop/DrowsyDriving/';
%   filename = {'Merged.mat',...
%                 ''
%                 };
    filename = {'DD_S11_NS_FFT.mat'};
                

    % Specify output directory, or leave empty to use pop-up
    resultDir = '/Users/JohnsonJohnson/Desktop/DrowsyDriving/';

if isempty(pathname)
    [filename,pathname] = loadEEGlab();
end

%% SELECT OUTPUT DIRECTORY
if isempty(resultDir)
    disp('Please select a directory in which to save the results.');
    resultDir = uigetdir('', 'Select the directory in which to save the results');
end

%% PROCESS EACH FILE

tic

prompt = 'Do you to export in 1Hz bins (YES) or orginal frequency bins (NO)? Y/N: ';
str = input(prompt,'s');

% count number of unique nights (ignoring TN2)
for nfile = 1:length(filename)
    fileparts = strsplit(filename{1,nfile},'_');
    nights(nfile) = fileparts(1);
end
nNights = length(unique(strrep(nights, 'TN2', 'TN3')));

% count number of unique IDs
for nfile = 1:length(filename)
    fileparts = strsplit(filename{1,nfile},'_');
    IDs(nfile) = fileparts(1);
end
nIDs = length(unique(IDs));

% create an empty array of correct size and make sure Y/N response entered
% load the first file to get dimentions and parameters
load([pathname char(filename(1))]);

% enter data infos only the first time from the PARAM (should always be the same for all data)
if ~exist('allSubjectsData','var')
    allSubjectsData.variableNames = {'channel','nbins','fbin','stage','night','ID'};
    allSubjectsData.channel = PARAM.plotchans;
    allSubjectsData.stage = PARAM.stages;
    allSubjectsData.night = {'control','novice','expert','retest'};
    allSubjectsData.ID = unique(IDs);
end

if isempty(str)
    error('WHOOPS! Please enter "Y" for YES, or "N" for NO.')
elseif strcmp(str,'N')
    allSubjectsData.mspectra = zeros(size(FFT.mspectra.data,1),size(FFT.mspectra.data,2),length(PARAM.stages),nNights,nIDs); % create empty array
elseif strcmp(str,'Y')
    allSubjectsData.mspectra = zeros(size(FFT.mspectra.data,1),size(FFT.mspectra.data,2)/PARAM.winsize,length(PARAM.stages),nNights,nIDs); % create empty array
else
    error('WHOOPS! Please enter "Y" for YES, or "N" for NO.')
end

clear FFT PARAM

disp('STEP 1: FORMATTING DATA FOR STATS')

% process each file
for nfile = 1:length(filename)
    
    % load file & update filename and path info
    load([pathname char(filename(nfile))]);
    disp(strcat('File ',{' '},filename{1,nfile},{' '},'loaded'))
    OutputPath = [resultDir,filesep];
    OutputFile = char(filename(nfile));
    
    % get subject ID and night info from file name
    fileparts = strsplit(filename{1,nfile},'_');
    
    ID = fileparts(1);
    iID = strmatch(ID,unique(IDs));
    
    if strcmp(fileparts(2),'CTN')
        night = 1; % 'control'
    elseif strcmp(fileparts(2),'TN1')
        night = 2; % 'novice'
    elseif strcmp(fileparts(2),'TN2')
        night = 3; % 'expert'
    elseif strcmp(fileparts(2),'TN3')
        night = 3; % 'expert'
    elseif strcmp(fileparts(2),'RT')
        night = 4; % 'retest';
    end
    
    % process for each stage
    for nstage = 1:length(PARAM.stages)
        if strcmp(str,'N')
            allSubjectsData.mspectra(:,:,nstage,night,iID) = FFT.mspectra.data(:,:,nstage);
            allSubjectsData.nbins = length(FFT.mspectra.data(:,:,nstage)); % number of frequency bins
            allSubjectsData.fbin = 1/PARAM.winsize; % bin size in Hz
        elseif strcmp(str,'Y')
            % calculate means in 1Hz bins
            oneHzbins = 1; % counter for each column (i.e., frequency bin)
            for nbin = 1:PARAM.winsize:length(FFT.mspectra.data(:,:,nstage))
                allSubjectsData.mspectra(:,oneHzbins,nstage,night,iID) = nanmean(FFT.mspectra.data(:,nbin:nbin+PARAM.winsize-1,nstage),2);
                oneHzbins = oneHzbins+1;
            end
            allSubjectsData.nbins = length(FFT.mspectra.data(:,:,nstage))/PARAM.winsize; % number of frequency bins
            allSubjectsData.fbin = 1/PARAM.winsize*PARAM.winsize; % bin size in Hz
        end
    end
    disp(strcat('File',{' '},num2str(nfile),{' '},'of',{' '},num2str(length(filename)),{' '},'files:',{' '},filename{1,nfile},{' '},'processed'))
end
allSubjectsData.GMspectra = mean(allSubjectsData.mspectra,5); % calculate the group mean for each stage on each night
allSubjectsData.GSTDspectra = std(allSubjectsData.mspectra,1,5); % calculate the group SD for each stage on each night

%% STATS

disp('STEP 2: STATISTICAL ANALYSIS')

% compute stats
% create a table with the data
IDs = str2num(char(strrep(allSubjectsData.ID,'S',''))); % numeric subject IDs
% need to loop for each stage, bin and site
allResults{length(allSubjectsData.channel),allSubjectsData.nbins,length(allSubjectsData.stage)} = []; % create an empty channel by fbin by stage matrix
for nstage = 1:length(allSubjectsData.stage) % each stage
    for nbin = 1:allSubjectsData.nbins % each frequency bin
        for nsite = 1:length(allSubjectsData.channel) % each site
            control = reshape(allSubjectsData.mspectra(nsite,nbin,nstage,1,:),length(allSubjectsData.ID),1);
            novice = reshape(allSubjectsData.mspectra(nsite,nbin,nstage,2,:),length(allSubjectsData.ID),1);
            expert = reshape(allSubjectsData.mspectra(nsite,nbin,nstage,3,:),length(allSubjectsData.ID),1);
            retest = reshape(allSubjectsData.mspectra(nsite,nbin,nstage,4,:),length(allSubjectsData.ID),1);
            t = table(IDs,control,novice,expert,retest,'VariableNames',{'ID','control','novice','expert','retest'});
            rm = fitrm(t,'control-retest~1');
            ranovatbl = ranova(rm,'WithinModel','separatemeans');
            allResults{nsite,nbin,nstage} = ranovatbl;
        end
    end
end

%% SAVE RESULTS
if strcmp(str,'N')
    save([OutputPath 'AllSubjectsResultsFFT.mat'],'allSubjectsData','PARAM','allResults')
elseif strcmp(str,'Y')
    save([OutputPath 'AllSubjectsResultsFFT_1Hzbin.mat'],'allSubjectsData','PARAM','allResults')
end
disp(strcat('Completed processing',{' '},num2str(nfile),{' '},'of',{' '},num2str(length(filename)),{' '},'files!'))

toc
end

%% LOAD EEGLAB FILES
function [filename,pathname] = loadEEGlab()

[filename,pathname] = uigetfile2(    {'*.mat', 'eeglab mat file (*.MAT)'; ...
    '*.set', 'eeglab dataset (*.SET)'; ...
    '*.*', 'All Files (*.*)'}, ...
    'Choose files to process', ...
    'Multiselect', 'on');

% Check the filename(s)
if isequal(filename,0) % no files were selected
    disp('User selected Cancel')
    return;
else
    if ischar(filename) % only one file was selected
        filename = cellstr(filename); % put the filename in the same cell structure as multiselect
    end
end

end