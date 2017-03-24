function FFTexport()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% EXPORT FFT RESULTS TO CSV
%
% Jul-24-2015 - SF, orginal code
%
% Copyright Stuart Fogel, Brain & Mind Institute, Western University
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% SPECIFY FILENAME(S) - OPTIONAL
% you can manually specify filenames here, or leave empty for pop-up
    pathname = '';
    filename = {'',...
                ''
                };

    % Specify output directory, or leave empty to use pop-up
    resultDir = '';
    
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

prompt = 'Do you to export in orginal frequency bins (YES) or 1Hz bins (NO)? Y/N: ';
str = input(prompt,'s');


for nfile = 1:length(filename)
    
    % load file & update filename and path info
    load([pathname char(filename(nfile))]);
    disp(strcat('File ',{' '},filename{1,nfile},{' '},'loaded'))
      
    % write to CSV
    OutputPath = [resultDir,filesep];
    OutputFile = char(filename(nfile));
    datasize = size(FFT.mspectra.data);
    if isempty(str)
        error('WHOOPS! Please enter "Y" for YES, or "N" for NO.')
    elseif strcmp(str,'Y')
        for nstage = 1:length(PARAM.stages)
            csvwrite([OutputPath OutputFile(1:end-4) '_' char(PARAM.stages(nstage)) '.csv'], FFT.mspectra.data(:,:,nstage)); % to write out data in original frequency bins
        end
    elseif strcmp(str,'N')
        oneHzbinspectra = zeros(datasize(1),datasize(2)/PARAM.winsize,length(PARAM.stages)); % create empty array
    for nstage = 1:length(PARAM.stages)
        % calculate means in 1Hz bins
        oneHzbins = 1; % counter for each column (i.e., frequency bin)
        for nbin = 1:PARAM.winsize:length(FFT.mspectra.data(:,:,nstage))
            oneHzbinspectra(:,oneHzbins,nstage) = nanmean(FFT.mspectra.data(:,nbin:nbin+PARAM.winsize-1,nstage),2);
            oneHzbins = oneHzbins+1;
            csvwrite([OutputPath OutputFile(1:end-4) '_' char(PARAM.stages(nstage)) '.csv'], oneHzbinspectra(:,:,nstage));
        end
    end
    else
        error('WHOOPS! Please enter "Y" for YES, or "N" for NO.')
    end
    disp(strcat('File',{' '},num2str(nfile),{' '},'of',{' '},num2str(length(filename)),{' '},'files:',{' '},filename{1,nfile},{' '},'exported to *.csv'))
end
disp(strcat('Completed export',{' '},num2str(nfile),{' '},'of',{' '},num2str(length(filename)),{' '},'files!'))
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