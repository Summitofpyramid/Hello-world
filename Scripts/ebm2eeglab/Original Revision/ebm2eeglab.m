function ebm2eeglab()

% Initialize an EEG dataset structure with default values.
EEG = eeg_emptyset;

% get the data and header from EBM format
[data,header] = ebm2mat();

%% Import basic EEGlab info
% get the data, recording length and # of channels, sampling rate, etc...
EEG.data = data;
EEG.epoch = [];
EEG.trials = 1;
EEG.pnts = length(data);
EEG.srate = header.samplingrate;
EEG.xmin = 0;
EEG.xmax = (EEG.pnts-1)/EEG.srate;
EEG.nbchan = length(header.channelname);
EEG.filepath = header.filepath;
EEG.setname = header.subjectinfo;
EEG.filename = strcat(EEG.setname,'_eeglab');
EEG.etc = 'This file was created using the ebm2eeglab.m script. Stuart Fogel, Brain & Mind Institute, Western University';

% put the start date and time into EEGlab comments
EEG.comments.date = char(header.startdate);
EEG.comments.time = char(header.starttimeclock);

%% Import the channel info
% put the channel labels from EMB header into EEGlab format
for nch = 1:length(header.channelname)
    EEG.chanlocs(nch).labels = char(header.channelname(nch));
    EEG.chanlocs(nch).theta = [];
    EEG.chanlocs(nch).radius = [];
    EEG.chanlocs(nch).X = [];
    EEG.chanlocs(nch).Y = [];
    EEG.chanlocs(nch).Z = [];
    EEG.chanlocs(nch).sph_theta = [];
    EEG.chanlocs(nch).sph_phi = [];
    EEG.chanlocs(nch).sph_radius = [];
    % figure out the channel type (n.b., must be EOG, EMG, LEG, ECG, or else it will assume type = EEG)
    if strfind(EEG.chanlocs(nch).labels, 'EOG')
        EEG.chanlocs(nch).type = 'EOG';
    elseif strfind(EEG.chanlocs(nch).labels, 'EMG')
        EEG.chanlocs(nch).type = 'EMG';
        EMGch = cell2mat(header.channel(nch));
    elseif strfind(EEG.chanlocs(nch).labels, 'LEG')
        EEG.chanlocs(nch).type = 'LEG';
    elseif strfind(EEG.chanlocs(nch).labels, 'ECG')
        EEG.chanlocs(nch).type = 'ECG';
    else
        EEG.chanlocs(nch).type = 'EEG';
    end
    EEG.chanlocs(nch).urchan = [];
end

% append an empty channel for the recording reference, e.g., 'Fpz' (n.b., modify label, if different)
EEG.chaninfo.nodatchans.labels = 'Fpz';
EEG.chaninfo.nodatchans.theta = [];
EEG.chaninfo.nodatchans.radius = [];
EEG.chaninfo.nodatchans.X = [];
EEG.chaninfo.nodatchans.Y = [];
EEG.chaninfo.nodatchans.Z = [];
EEG.chaninfo.nodatchans.sph_theta = [];
EEG.chaninfo.nodatchans.sph_phi = [];
EEG.chaninfo.nodatchans.sph_radius = [];
EEG.chaninfo.nodatchans.type = 'EEG';
EEG.chaninfo.nodatchans.urchan = [];
eeglabpath = which('eeglab');
eeglabpath = eeglabpath(1:end-8);
EEG.chaninfo.filename = strcat(eeglabpath,'plugins/dipfit2.2/standard_BESA/standard-10-5-cap385.elp');

% look up channel locations
% EEG.chanlocs = pop_chanedit(EEG.chanlocs); % uncomment this line, and comment the next lines to use pop-up dialogue instead
eeglabpath = which('eeglab');
eeglabpath = eeglabpath(1:end-8);
EEG = pop_chanedit(EEG, 'lookup',strcat(eeglabpath,'plugins/dipfit2.2/standard_BESA/standard-10-5-cap385.elp'));

% set the original chanlocs info
EEG.urchanlocs = EEG.chanlocs;

% re-reference (optional)
% uncomment these lines to use pop-up dialogue to re-reference
% EEGOUT = pop_reref(EEG); 
% EEG = EEGOUT;
% clear EEGOUT

% uncomment these lines to use script
EEG = pop_reref( EEG, [1 2] ,'refloc',struct('labels',{'Fpz'},'type',{'EEG'},'theta',{0},'radius',{0.50669},'X',{84.9812},'Y',{0},'Z',{-1.786},'sph_theta',{0},'sph_phi',{-1.204},'sph_radius',{85},'urchan',{22},'ref',{''},'datachan',{0}),'exclude',EMGch,'keepref','on');

%% Import events into EEGlab format
% get the Embla exported stage scoring and other events
[events] = ebmevents2mat;

% create the first event as the recording start
nevt = 1;
EEG.event(nevt).type = 'Recording Start';
EEG.event(nevt).channel = '';
EEG.event(nevt).latency = 0;
EEG.event(nevt).peak = [];
EEG.event(nevt).duration = 0;
EEG.event(nevt).amplitude = [];
EEG.event(nevt).frequency = [];
EEG.event(nevt).urevent = [];

% add the events to the EEGlab structure
if ~isempty(events)
    for nevt = 1:length(events{1})
        % convert weirdo Embla date format to Matlab serial date number
        latency = strread(char(strcat({header.startdate},{' '},{events{1,1}{nevt,1}})),'%s','delimiter', ' ');
        latencymat = datenum(strcat(latency{1,1},{' '},latency{2,1},{latency{3,1}(3:end)}),'dd-mmm-yyyy HH:MM:SS');    
        % find out if time stamp is PM, and if so, convert to 24-hr clock
        if strfind(events{1,1}{nevt,1},'PM')
            latencymat = addtodate(latencymat, 12, 'hour');
        end
        % convert latency relative to start time, and convert to data points
        t1 = datevec(header.starttime);
        t2 = datevec(latencymat);
        % ensure that the recording is < 24 hours, otherwise this method does not work!!!!!
        if length(data)/EEG.srate/60/60 > 24
            error('Events cannot be exported for recordings longer than 24 hours')
        % if event time occurs earlier than recording start, add a day (re; recording spans midnight).    
        elseif etime(t2,t1) < 0
            t2(1,3) = t1(1,3) + 1;
        end
        % convert to elapsed time in seconds, and then convert to points (from onset time = 0 data point)
        EEG.event(nevt+1).latency = 1+(etime(t2,t1))*EEG.srate;
        % Fill in the event type (e.g., stage scoring, light off/on, event markers, etc...)
        EEG.event(nevt+1).type = events{1,2}{nevt,1};
        % Fill in the rest of the info for the event structure
        EEG.event(nevt+1).channel = '';
        EEG.event(nevt+1).peak = [];
        EEG.event(nevt+1).duration = events{1,3}(nevt,1);
        EEG.event(nevt+1).amplitude = [];
        EEG.event(nevt+1).frequency = [];
        EEG.event(nevt+1).urevent = [];
    end
end
clear nevt

% set the original event info
EEG.urevent = EEG.event;

%% This section creates a 'stageData' structure that is compatible with sleepSMG
% This only works if file is sleep scored from the start of the file.
% SleepSMG considers the first sage scoring label = first epoch of data.
% 
% % sampling rate
% stageData.srate = EEG.srate;
% 
% % grab the duration of the first epoch marked 'W', or 'N1', or 'N2'
% stop = [];
% for nevt = 1:length(EEG.event)
%     if isempty(stop)
%         if strcmp(EEG.event(nevt).type, 'W')
%             stageData.win = EEG.event(nevt).duration;
%             stop = 1;
%         elseif strcmp(EEG.event(nevt).type, 'N1')
%             stageData.win = EEG.event(nevt).duration;
%             stop = 1;
%         elseif strcmp(EEG.event(nevt).type, 'N2')
%             stageData.win = EEG.event(nevt).duration;
%             stop = 1;
%         end
%     end
% end
% clear nevt
% 
% % get the recording start time
% stageData.recStart = header.starttime;
% % set the lights on tag to the EOF
% stageData.lightsON = addtodate(stageData.recStart,round(EEG.xmax*1000),'millisecond');
% 
% % move the labels into the sleepSMG stageData structure and convert the format
% stageData.stages = [];
% for nevt = 1:length(EEG.event)
%     if strcmp(EEG.event(nevt).type, 'Lights Off')
%         stageData.lightsOFF = addtodate(stageData.recStart,round((EEG.event(1,nevt).latency - 1)/EEG.srate*1000),'millisecond');
%     elseif strcmp(EEG.event(nevt).type, 'W')
%         stageData.stages{nevt} = 0;
%         stageData.onsets{nevt} = EEG.event(1,nevt).latency;
%     elseif strcmp(EEG.event(nevt).type, 'N1')
%         stageData.stages{nevt} = 1;
%         stageData.onsets{nevt} = EEG.event(1,nevt).latency;
%     elseif strcmp(EEG.event(nevt).type, 'N2')
%         stageData.stages{nevt} = 2;
%         stageData.onsets{nevt} = EEG.event(1,nevt).latency;
%     elseif strcmp(EEG.event(nevt).type, 'N3')
%         stageData.stages{nevt} = 3;
%         stageData.onsets{nevt} = EEG.event(1,nevt).latency;
%     elseif strcmp(EEG.event(nevt).type, 'N4')
%         stageData.stages{nevt} = 4;
%         stageData.onsets{nevt} = EEG.event(1,nevt).latency;
%     elseif strcmp(EEG.event(nevt).type, 'R')
%         stageData.stages{nevt} = 5;
%         stageData.onsets{nevt} = EEG.event(1,nevt).latency;
% %     else
% %         stageData.stages{nevt} = 7;
% %         stageData.onsets{nevt} = EEG.event(1,nevt).latency;
%     end
% end
% 
% stageData.stages = stageData.stages';
% stageData.onsets = stageData.onsets';
% stageData.stages = cell2mat(stageData.stages);
% stageData.onsets = cell2mat(stageData.onsets);
% stageData.stageTime = ((stageData.onsets -1)/EEG.srate)/60;

%% Save the output

% save the sleepSMG data structure to a .mat
% matName = char(strcat(EEG.filepath,EEG.setname,'_sleepSMG'));
% disp(char(strcat({'Saving EEGlab file to: '},{matName},{'.mat file...'})));
% save(matName,'stageData');

% save the EEG data structure to a .mat
matName = char(strcat(EEG.filepath,EEG.filename));
disp(char(strcat({'Saving EEGlab file to: '},{matName},{'.mat file...'})));
save(matName,'EEG');
             
% save the EEG data structure to an EEGlab dataset
setName = strcat(EEG.filepath,EEG.filename);
disp(char(strcat({'Saving EEGlab dataset file to: '},{setName},{'.set file...'})));
% Uncomment next line to use a pop-up dialogue instead
% pop_saveset(EEG);
EEG = pop_saveset( EEG,  'filename', [EEG.filename, '.set'], 'filepath', EEG.filepath);
clear all
end