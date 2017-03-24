function ebm2eeglab()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% PIPELINE TO CONVERT EMBLA DATA FILES TO EEGLAB
% Copyright Stuart Fogel, Brain & Mind Institute, Western University
% sfogel@uwo.ca
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% SPECIFY DIRECTORIES CONTAINING EMBLA DATA FILES
rootpath = '/Users/JohnsonJohnson/Desktop/DrowsyDriving/Data/';

% ALL TOGETHER NOW!
% filepaths = {...
%     [rootpath 'DD_S03_NS' filesep], ...
%     [rootpath 'DD_S03_SR' filesep], ...
%     [rootpath 'DD_S04_NS' filesep], ...
%     [rootpath 'DD_S04_SR' filesep], ...
%     [rootpath 'DD_S05_NS' filesep], ...
%     [rootpath 'DD_S05_SR' filesep], ...
%     [rootpath 'DD_S07_NS' filesep], ...
%     [rootpath 'DD_S07_SR' filesep], ...
%     [rootpath 'DD_S08_NS' filesep], ...
%     [rootpath 'DD_S08_SR' filesep], ...
%     [rootpath 'DD_S09_NS' filesep], ...
%     [rootpath 'DD_S09_SR' filesep], ...
%     [rootpath 'DD_S10_NS' filesep], ...
%     [rootpath 'DD_S10_SR' filesep], ...
%     [rootpath 'DD_S11_NS' filesep], ...
%     [rootpath 'DD_S11_SR' filesep], ...
%     [rootpath 'DD_S12_NS' filesep], ...
%     [rootpath 'DD_S12_SR' filesep], ...
%     [rootpath 'DD_S13_NS' filesep], ...
%     [rootpath 'DD_S13_SR' filesep], ...
%     [rootpath 'DD_S14_NS' filesep], ...
%     [rootpath 'DD_S14_SR' filesep], ...
%     [rootpath 'DD_S15_NS' filesep], ...
%     [rootpath 'DD_S15_SR' filesep], ...
%     [rootpath 'DD_S16_NS' filesep], ...
%     [rootpath 'DD_S16_SR' filesep], ...
%     [rootpath 'DD_S18_NS' filesep], ...
%     [rootpath 'DD_S18_SR' filesep], ...
%     [rootpath 'DD_S19_NS' filesep], ...
%     [rootpath 'DD_S19_SR' filesep], ...
%     [rootpath 'DD_S20_NS' filesep], ...
%     [rootpath 'DD_S20_SR' filesep], ...
%     [rootpath 'DD_S21_NS' filesep], ...
%     [rootpath 'DD_S21_SR' filesep], ...
%     [rootpath 'DD_S22_NS' filesep], ...
%     [rootpath 'DD_S22_SR' filesep], ...
%     [rootpath 'DD_S24_NS' filesep], ...
%     [rootpath 'DD_S24_SR' filesep], ...
%     [rootpath 'DD_S25_NS' filesep], ...
%     [rootpath 'DD_S25_SR' filesep], ...
%     [rootpath 'DD_S26_NS' filesep], ...
%     [rootpath 'DD_S26_SR' filesep], ...
%     [rootpath 'DD_S28_NS' filesep], ...
%     [rootpath 'DD_S28_SR' filesep], ...
%     [rootpath 'DD_S39_NS' filesep], ...
%     [rootpath 'DD_S39_SR' filesep], ...
%     [rootpath 'DD_S41_NS' filesep], ...
%     [rootpath 'DD_S41_SR' filesep], ...
%     [rootpath 'DD_S42_NS' filesep], ...
%     [rootpath 'DD_S42_SR' filesep], ...
%     [rootpath 'DD_S43_NS' filesep], ...
%     [rootpath 'DD_S43_SR' filesep], ...
%     [rootpath 'DD_S50_NS' filesep], ...
%     [rootpath 'DD_S50_SR' filesep], ...
%     };

% STILL NEED TO RUN ON S16...
% filepaths = {...
%     [rootpath 'DD_S16_NS' filesep], ...
%     [rootpath 'DD_S16_SR' filesep], ...
%    };

% MOST RECENT BATCH RUN (FOR ACS):
filepaths = {...
    [rootpath 'DD_S11_NS' filesep], ...
    [rootpath 'DD_S11_SR' filesep], ...
    [rootpath 'DD_S12_NS' filesep], ...
    [rootpath 'DD_S12_SR' filesep], ...
    [rootpath 'DD_S15_NS' filesep], ...
    [rootpath 'DD_S15_SR' filesep], ...
    [rootpath 'DD_S18_NS' filesep], ...
    [rootpath 'DD_S18_SR' filesep], ...
    [rootpath 'DD_S19_NS' filesep], ...
    [rootpath 'DD_S19_SR' filesep], ...
    [rootpath 'DD_S22_NS' filesep], ...
    [rootpath 'DD_S22_SR' filesep], ...
    [rootpath 'DD_S24_NS' filesep], ...
    [rootpath 'DD_S24_SR' filesep], ...
    [rootpath 'DD_S25_NS' filesep], ...
    [rootpath 'DD_S25_SR' filesep], ...
    [rootpath 'DD_S28_NS' filesep], ...
    [rootpath 'DD_S28_SR' filesep], ...
    [rootpath 'DD_S39_NS' filesep], ...
    [rootpath 'DD_S39_SR' filesep], ...
    [rootpath 'DD_S41_NS' filesep], ...
    [rootpath 'DD_S41_SR' filesep], ...
    [rootpath 'DD_S42_NS' filesep], ...
    [rootpath 'DD_S42_SR' filesep], ...
    [rootpath 'DD_S43_NS' filesep], ...
    [rootpath 'DD_S43_SR' filesep], ...
    [rootpath 'DD_S50_NS' filesep], ...
    [rootpath 'DD_S50_SR' filesep], ...
    };

%% PROCESS EACH FILE
for nfile = 1:length(filepaths)
    
    % Initialize an EEG dataset structure with default values.
    EEG = eeg_emptyset;
    
    % get the data and header from EBM format for the current directory of files
    filepath = filepaths{1,nfile};
    [data,header] = ebm2mat(filepath);
    
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
    EEG.comments = char(strcat(header.startdate,{' '},header.starttimeclock));
    
    %% Import the channel info
    % put the channel labels from EMB header into EEGlab format
    chidx = 0;
    rmch = 0;
    for nch = 1:length(header.channelname)
        EEG.chanlocs(nch).labels = char(header.channelname(nch));
        % for locs filetype
        % EEG.chanlocs(nch).angle = [];
        % EEG.chanlocs(nch).radius = [];
        % for ced filetype
        EEG.chanlocs(nch).theta = [];
        EEG.chanlocs(nch).radius = [];
        EEG.chanlocs(nch).X = [];
        EEG.chanlocs(nch).Y = [];
        EEG.chanlocs(nch).Z = [];
        EEG.chanlocs(nch).sph_theta = [];
        EEG.chanlocs(nch).sph_phi = [];
        EEG.chanlocs(nch).sph_radius = [];
        EEG.chanlocs(nch).urchan = [];
        % figure out the channel type (n.b., must be specified below or else it will assume type = EEG)
        if strfind(EEG.chanlocs(nch).labels, 'EOG')
            EEG.chanlocs(nch).type = 'EOG';
            chidx = chidx + 1;
            keep(chidx) = nch;
        elseif strfind(EEG.chanlocs(nch).labels, 'EMG')
            EEG.chanlocs(nch).type = 'EMG';
            chidx = chidx + 1;
            keep(chidx) = nch;
        elseif strfind(EEG.chanlocs(nch).labels, 'LEG')
            EEG.chanlocs(nch).type = 'LEG';
            chidx = chidx + 1;
            keep(chidx) = nch;
        elseif strfind(EEG.chanlocs(nch).labels, 'ECG')
            EEG.chanlocs(nch).type = 'ECG';
            chidx = chidx + 1;
            keep(chidx) = nch;
        elseif strfind(EEG.chanlocs(nch).labels, 'DC')
            EEG.chanlocs(nch).type = 'DC';
            chidx = chidx + 1;
            keep(chidx) = nch;
        elseif strfind(EEG.chanlocs(nch).labels, 'Plethysmogram')
            % remove data channel
            EEG.nbchan = EEG.nbchan - 1;
            EEG.data(nch-rmch,:) = [];
            rmch = rmch + 1; % adjust index to account for missing channel
        elseif strfind(EEG.chanlocs(nch).labels, 'Pulse')
            % remove data channel
            EEG.nbchan = EEG.nbchan - 1;
            EEG.data(nch-rmch,:) = [];
            rmch = rmch + 1; % adjust index to account for missing channel
        elseif strfind(EEG.chanlocs(nch).labels, 'Sp02')
            % remove data channel
            EEG.nbchan = EEG.nbchan - 1;
            EEG.data(nch-rmch,:) = [];
            rmch = rmch + 1; % adjust index to account for missing channel
        else
            EEG.chanlocs(nch).type = 'EEG'; % assumes that if not one of the above channel types, it must be EEG.
            chidx = chidx + 1;
            keep(chidx) = nch;
        end
    end
    
    EEG.chanlocs = EEG.chanlocs(keep);
    
    % find the electrode location file
    if ~isempty(which('Standard-10-20-DD-PSG.ced'));
        EEG.chaninfo.filename = which('Standard-10-20-DD-PSG.ced'); % this may need modifying depending on name / location / matlab path!
        locsfile = EEG.chaninfo.filename;
    else % warn and select manually
        warning('Cannot find Standard-10-20-DD-PSG.ced file')
        
        [filename,pathname] = uigetfile2(   {'*.ced', 'Electrode location file (*.ced)'; ...
            '*.*', 'All Files (*.*)'}, ...
            'Select electrode location file (*.ced)', ...
            'Multiselect', 'off');
        
        if ~isempty(filename) % no files were selected
            locsfile = [pathname filename];
        elseif isequal(filename,0) % no files were selected
            error('Cannot find electrode location file')
        end
    end
    
    % look up channel locations
    disp(['Reading electrode locations from file: ' locsfile])
    EEG = pop_chanedit(EEG, 'lookup', locsfile); % NOTE: ced file must contain 'type' field in last column - see help readlocs
    
    % append an empty channel for the recording reference, e.g., 'Fpz' (n.b., modify label, if different)
    EEG.chaninfo.nodatchans.labels = 'Fpz';
    EEG.chaninfo.nodatchans.type = 'EEG';
    EEG.chaninfo.nodatchans.urchan = [];
    EEG.chaninfo.nodatchans.theta = 0;
    EEG.chaninfo.nodatchans.radius = 0.5;
    EEG.chaninfo.nodatchans.X = 1;
    EEG.chaninfo.nodatchans.Y = 0;
    EEG.chaninfo.nodatchans.Z = 0.5;
    EEG.chaninfo.nodatchans.sph_theta = 0;
    EEG.chaninfo.nodatchans.sph_phi = -2;
    EEG.chaninfo.nodatchans.sph_radius = 1;
    
    % set the original chanlocs info
    EEG.urchanlocs = EEG.chanlocs;
    
    % check updated dataset
    EEG = eeg_checkset(EEG);
    
    %% Import events into EEGlab format
    % get the Embla exported stage scoring and other events
    [events] = ebmevents2mat(filepath);
    
    % create the first event at the start of the recording (time = 1)
    nevt = 1;
    EEG.event(nevt).type = EEG.comments;
    EEG.event(nevt).channel = '';
    EEG.event(nevt).latency = 1; % this was originally set to = 0, but that caused some bugs in event processing
    EEG.event(nevt).peak = [];
    EEG.event(nevt).duration = 0;
    EEG.event(nevt).amplitude = [];
    EEG.event(nevt).frequency = [];
    EEG.event(nevt).urevent = [];
    
    % Create the actual start date and time date number and vector used to then calculate elapsed time of events from start
    startdatetime = datenum(EEG.comments,'dd-mmm-yyyy HH:MM:SS.FFF');
    t1=datevec(startdatetime);
    
    % strplit function used below is kinda new, so we'll check version first before using it
    checkversion = which('strsplit');
    if isempty(checkversion)
        error('WHOOPS! Time to update Matlab! strsplit funtion requires MATLAB 8.1 (R2013a) or newer!');
    else
    end
    
    % First check file length. if longer than 24-hours, event import does not work.
    totaltime = EEG.pnts/EEG.srate;
    if ~isempty(events)
        if totaltime < 86400
            for nevt = 1:length(events{1})
                % Convert the crazy Embla date format to something we can work with, and add the start date
                latencytemp{1} = strsplit(events{1,1}{nevt,1},{' ','.'},'CollapseDelimiters',true);
                events{1,1}{nevt,1} = datevec(strcat(header.startdate,{' '},latencytemp{1,1}{1,1},'.',latencytemp{1,1}{1,3},{' '},latencytemp{1,1}{1,2}));
                t2 = events{1,1}{nevt,1};
                % if all the latencies are positive, the recording does not need to have the date corrected
                if etime(t2,t1) > 0
                    latency = etime(t2,t1);
                    % if event time occurs earlier than recording start (re; recording spans midnight), add a day.
                elseif (etime(t2,t1) < 0) && (etime(t2,t1) > -86400) % n.b., 86400 = 24 hours, in seconds
                    latencymat = addtodate(datenum(t2), 1, 'day');
                    t2=datevec(latencymat); % update the latency with the new date
                    latency = etime(t2,t1);
                else
                end
                % Convert to elapsed time into points from sec
                % if the event time is the same as the recording start, (e.g., first event) give it a real value = 1.
                % n.b., this could be wrong, when events are precisely 12 hours apart, but highly unlikely.
                if etime(t2,t1) == 0
                    latency=(etime(t2,t1)*EEG.srate) + 1;
                    % if they are not the same, convert.
                else
                    latency=etime(t2,t1)*EEG.srate;
                end
                % Fill in the event latencies after the recording start marker
                EEG.event(nevt+1).latency = latency;
                % Fill in the event type (e.g., stage scoring, light off/on, event markers, etc...)
                EEG.event(nevt+1).type = events{1,2}{nevt,1};
                % Fill in the rest of the info for the event structure
                EEG.event(nevt+1).channel = '';
                EEG.event(nevt+1).peak = [];
                EEG.event(nevt+1).duration = (events{1,3}(nevt,1))*256; % EEGlab uses samples, not seconds for duration
                EEG.event(nevt+1).amplitude = [];
                EEG.event(nevt+1).frequency = [];
                EEG.event(nevt+1).urevent = [];
            end
        elseif totaltime > 86400
            disp('Cannot import Embla events for files > 24 hours!');
        else
            error('File length error. Cannot import Embla events');
        end
    end
    
    clear nevt latency latencymat latencytemp t1 t2 checkversion totaltime
    
    % set the original event info
    EEG.urevent = EEG.event;
    
    % check updated dataset
    EEG = eeg_checkset(EEG);
    
    %% Save the output
    
    % save the eeglab EEG data structure to a .mat
    matName = char(strcat(EEG.filepath,EEG.setname));
    disp(char(strcat({'Saving generic Matlab file to: '},{matName},{'.mat file...'})));
    save(matName,'EEG');
    
    % save the EEG data structure to an EEGlab dataset
    % setName = strcat(EEG.filepath,EEG.filename);
    % disp(char(strcat({'Saving EEGlab dataset file to: '},{setName},{'.set file...'})));
    % Uncomment next line to use a pop-up dialogue instead
    % pop_saveset(EEG);
    % EEG = pop_saveset( EEG,  'filename', [EEG.filename, '.set'], 'filepath', EEG.filepath);
    
    clearvars -except rootpath filepaths nfile
    
end

disp('Done!')

end