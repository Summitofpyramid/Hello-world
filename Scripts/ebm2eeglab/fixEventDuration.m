function fixEventDuration()

%% LOAD THE EEGlab MAT FILE
EEG = pop_loadset();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% TO RUN: 
% 1) type fixEventDuration at Matlab Command prompt
% 2) sleect eeglab *.set file to correct sleep stage duration
% 3) take note of the directory that it was saved to
% 
% If no such directory, specify a custom path below (e.g., replace EEG.filepath with 'C:\newdata'):

outputpath=EEG.filepath;

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% CHANGE THE EVENT DURATIONS TO THE RIGHT UNITS
for nevt = 1:length(EEG.event)
    if strfind(EEG.event(nevt).type,'W');
        EEG.event(nevt).duration = EEG.event(nevt).duration*256;
    elseif strfind(EEG.event(nevt).type,'N1');
        EEG.event(nevt).duration = EEG.event(nevt).duration*256;
    elseif strfind(EEG.event(nevt).type,'N2');
        EEG.event(nevt).duration = EEG.event(nevt).duration*256;
    elseif strfind(EEG.event(nevt).type,'N3');
        EEG.event(nevt).duration = EEG.event(nevt).duration*256;
    elseif strfind(EEG.event(nevt).type,'N4');
        EEG.event(nevt).duration = EEG.event(nevt).duration*256;
    elseif strfind(EEG.event(nevt).type,'R');
        EEG.event(nevt).duration = EEG.event(nevt).duration*256;
    elseif strfind(EEG.event(nevt).type,'Unscored');
        EEG.event(nevt).duration = EEG.event(nevt).duration*256;
    elseif strfind(EEG.event(nevt).type,'Movement');
        EEG.event(nevt).duration = EEG.event(nevt).duration*256;
    end
end

%% CHECK THE EEG STRUCTURE AND SAVE
EEG = eeg_checkset( EEG );
% outputname=strcat(EEG.filename(1:end-4),'_fixeddur'); % use this if you don't want to write over files
outputname=EEG.filename(1:end-4); % use this if you do want to overwrite orginals
EEG = pop_saveset( EEG, 'filename',outputname,'filepath',outputpath);
disp(char(strcat({'Saved EEGlab file to: '},{outputpath},{outputname},{'.set'})));

end