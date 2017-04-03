function FFTsleep(EEG)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FFT PIPELINE FOR PSG DATA
%
% Jul-20-2015 - SF, orginal code
%
% Copyright Stuart Fogel, Brain & Mind Institute, Western University
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% STUDY-SPECIFIC PARAMETERS

PARAM = struct(...
    'epoch', 5, ... length in seconds of sleep stage epoch {default: 30}
    'stages', {{'H0','H1','H2','H3','H4','H5','H6','H7','H8','H9'}}, ... labels of sleep stage epoch, {default: {{'W','N1','N2','N3','R,}}}
    'baddata', {{'Movement'}}, ... label for bad data, {default: {{'Movement'}}}
    'winsize', 5, ... size of FFT window in seconds {default: 5}. Use default for 6 windows per 30 sec sleep stage and a freq resolution of 0.2Hz.
    'freqrange', [0 32], ... range of frequencies {default: [0 32]}
    'plotchans', [3:5 8:12 14:18 20], ... vector of channel indices to include in FFT {default: [3:5 7:9 11:14]; i.e., C3,C4,Cz,F3,F4,Fz,Oz,P3,P4,Pz}
    'plot', 'off' ... ['on'|'off'], plot result, {default: 'off'}
    );

%% SPECIFY FILENAME(S) - OPTIONAL
% you can manually specify filenames here, or leave empty for pop-up
    pathname = '/Users/stuartfogel/Documents/DrowsyDriving/MergedEEGs/';
%   filename = {'Merged.mat',...
%                 ''
%                 };
    mergedEEGs = dir('/Users/stuartfogel/Documents/DrowsyDriving/MergedEEGs/*.mat');
    
    filename = {mergedEEGs.name};
                

    % Specify output directory, or leave empty to use pop-up
    resultDir = '/Users/stuartfogel/Documents/DrowsyDriving/FFTsOfMergedEEGsRevised/';
    
%% SELECT EEGLAB FILES(S)
if nargin < 1
    EEG = [];
end

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

for nfile = 1:1
    if(nfile==21) % DD_S41_NS_merged_EEG can not be runned due to the 'movement' validation
        continue;
    end 
    % start with a fresh FFT structure
    FFT = [];
    
    % load file & update filename and path info
    EEG = pop_loadset('filename',filename{1,nfile},'filepath',pathname);
    EEG = eeg_checkset(EEG);
    disp(strcat('File ',{' '},filename{1,nfile},{' '},'loaded'))
    
    % find stages to epoch
    stageIndex = find(ismember({EEG.event.type},PARAM.stages));
    
    % find bad data
    badIndex = find(ismember({EEG.event.type},PARAM.baddata));
    
    ndel = 1;
    todelete = [];
    for nbad = 1:length(badIndex)
        for nstage = 1:length(stageIndex)
            % find stage events that start during bad data
            if EEG.event(stageIndex(nstage)).latency > EEG.event(badIndex(nbad)).latency && EEG.event(stageIndex(nstage)).latency < (EEG.event(badIndex(nbad)).latency + EEG.event(badIndex(nbad)).duration)
                todelete(ndel) = stageIndex(nstage);
                ndel = ndel + 1;
            end
            % find stage events that end during bad data
            if (EEG.event(stageIndex(nstage)).latency + EEG.event(stageIndex(nstage)).duration) > EEG.event(badIndex(nbad)).latency && EEG.event(stageIndex(nstage)).latency < (EEG.event(badIndex(nbad)).latency + EEG.event(badIndex(nbad)).duration)
                todelete(ndel) = stageIndex(nstage);
                ndel = ndel + 1;
            end
            % find stage events that have bad data during
            if ~isequal(EEG.event(badIndex(nbad)),EEG.event(1)) % if it's not the first event in the original structure
                if EEG.event(badIndex(nbad)).latency > EEG.event(stageIndex(nstage)).latency && EEG.event(badIndex(nbad)).latency < EEG.event(stageIndex(nstage)).latency + EEG.event(stageIndex(nstage)).duration
                    todelete(ndel) = stageIndex(nstage);
                    ndel = ndel + 1;
                end
            end
        end
    end
    
    % housekeeping
    clear ndel nbad nstage
    
    % delete stages during bad data
    goodepochs = stageIndex;
    todelete = unique(todelete); % get unique indices, re; can be duplicates from above
    todelete = find(ismember(stageIndex, todelete));
   % goodepochs(todelete) = []; % delete the stages from stageIndex
    
    % housekeeping
    clear todelete stageIndex badIndex
    
    % get good event and channel info from original EEG structure
    type = {EEG.event(goodepochs).type};
    latency = {EEG.event(goodepochs).latency};
    duration = {EEG.event(goodepochs).duration};
    urevent = {EEG.event(goodepochs).urevent};
    FFT.event = struct('type',type, ...
                       'latency',latency, ...
                       'duration',duration, ...
                       'urevent',urevent ...
                       );
    FFT.chanlocs = EEG.chanlocs(PARAM.plotchans);
    
    % housekeeping
    clear type latency duration urevent
    
    % epoch only good data (moevment-free) according to sleep stage
    EEG = pop_epoch(EEG, PARAM.stages, [0  PARAM.epoch], 'newname',[EEG.setname '_FFT'], 'eventindices',goodepochs, 'epochinfo','yes');
    EEG = eeg_checkset(EEG);
    
    % housekeeping
    clear goodepochs
    
    % run spectral analysis on each sleep stage epoch
    datasize = size(EEG.data);
    spectra = zeros(length(PARAM.plotchans),PARAM.freqrange(2)*PARAM.winsize,datasize(3));
    for nepoch = 1:datasize(3)
    %    if all(all(EEG.data(:,:,nepoch))) % if all elements are non-zero
    %    COMMENTED to test on Mar.23 2017
            nspectra = spectopo(EEG.data(:,:,nepoch), 0, EEG.srate, 'nfft',PARAM.winsize*EEG.srate, 'winsize',PARAM.winsize*EEG.srate, 'freqrange',PARAM.freqrange, 'plotchans',PARAM.plotchans, 'plot', PARAM.plot);
            nspectra = nspectra(:,1:PARAM.freqrange(2)*PARAM.winsize);
            spectra(:,:,nepoch) = nspectra;
%         else % some epochs can contain zeroed data (if amp is disconnected, or reset during acquisition). Do not run spectopo, insert zeros.
%             nspectra = zeros(length(PARAM.plotchans),PARAM.freqrange(2)*PARAM.winsize);
%             spectra(:,:,nepoch) = nspectra;
%         end
    end
    
    FFT.spectra = spectra;
    
    % housekeeping
    clear datasize nepoch spectra nspectra
    
    %% SUMMARIZE THE FFT RESULTS
    datasize = size(FFT.spectra);
    mspectra = zeros(datasize(1),datasize(2),length(PARAM.stages));
    for nstage = 1:length(PARAM.stages)
        stageIndex = find(ismember({FFT.event.type},PARAM.stages(nstage)));
        mspectra(:,:,nstage) = mean(FFT.spectra(:,:,stageIndex),3);
    end
    
    FFT.mspectra.data = mspectra;
    FFT.mspectra.stage = PARAM.stages;
    
    % housekeeping
    clear datasize mspectra nstage stageIndex
    
    %% SAVE THE FFT RESULTS
    OutputPath = [resultDir,filesep];
    OutputFile = char(filename(nfile));
    save([OutputPath [OutputFile(1:end-4) '_FFT'] '.mat'], 'FFT', 'PARAM');
end

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