function [events] = ebmevents2mat()

% Open interface to select *.csv file
[filename,pathname] = uigetfile(    {   '*.txt', 'Text (*.txt)'; ...
                                        '*.*','All Files (*.*)'}, ...
                                        'Choose Embla event txt file to import, or click cancel for none', ...
                                        'Multiselect', 'off');


if filename == 0
    events = [];
else
    % open the file
    fullpath = strcat(pathname, filename);
    fid = fopen(fullpath);
    tline = fgetl(fid);
    while ~feof(fid)
            if ~isempty(tline)
                if strfind(tline,'[s]')
                % get the onsets (Time [hh:mm:ss.xxx]), Event, Duration[s])
                events = textscan(fid, '%s%s%f', 'Delimiter', '\t');
                else
                tline = fgetl(fid);
                end
            else
            tline = fgetl(fid);
            end
    end
    fclose(fid);
    [path,name] = fileparts(filename);
    matName = strcat(pathname,name);
    disp(char(strcat({'Saving event file to: '},{matName},{'.mat file...'})));
    save(matName,'events');
end
end