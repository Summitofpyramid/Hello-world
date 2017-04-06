%time shift 

events = {EEG.event.type}';
diff = [];
for i = 1:length(events)-1
    if strncmp(string(events(i)),'HO',1) && strcmp(string(events(i+1)),'W')
        diff = [diff;EEG.event(i+1).latency-EEG.event(i).latency];
    end
end