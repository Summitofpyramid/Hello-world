%time shift the 'W' and 'N*' events so that they are aligned with the 'H'
%event

function EEG = timeShift(EEG)

events = {EEG.event.type}';

uniEvents = unique(events);
diff = [];
indices = [];
for i = 1:length(events)-1
    if (strncmp(string(events(i)),'H',1) && (strcmp(string(events(i+1)),'W') || strncmp(string(events(i+1)),'N',1)))...
            && EEG.event(i).latency~=EEG.event(i+1).latency
        diff = [diff;EEG.event(i+1).latency-EEG.event(i).latency];
        indices = [indices i+1];
    end
end

%uniDiff = unique(diff);

for i = 1:length(indices)
    EEG.event(indices(i)).latency = EEG.event(indices(i)).latency - diff(i);
end
