function [events] = ebmevents2mat(filepath)

% % Open interface to select *.csv file
% [filename,pathname] = uigetfile(    {   '*.txt', 'Text (*.txt)'; ...
%                                         '*.*','All Files (*.*)'}, ...
%                                         'Choose Embla event txt file to import, or click cancel for no event file', ...
%                                         'Multiselect', 'off');
 
% if filename == 0
if nargin < 1
    events = [];
    error('Ebmla event file required to get lights on and lights off markers')
else
    % open the file
    % fullpath = strcat(pathname, filename);
    workingdir = pwd;
    fullpath = ls(fullfile([filepath '*.txt']));
    [filepath filename] = fileparts(fullpath);
    cd(filepath);
    filename = [filename '.txt'];
    fid = fopen(filename);
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
    cd(workingdir);
%     [path,name] = fileparts(filename);
%     matName = strcat(pathname,name);
%     disp(char(strcat({'Saving event file to: '},{matName},{'.mat file...'})));
%     save(matName,'events');
end
end