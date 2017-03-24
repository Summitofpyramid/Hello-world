function FFTposthoc()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% CALCULATE POST-HOC STATS ON FFT RESULTS
%
% Aug-12-2015 - SF, orginal code
%
% Written for "Tower Expertise" study
%
% Copyright Stuart Fogel, Brain & Mind Institute, Western University
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% SPECIFY VARIABLES TO TEST [site fbin stage]
comparisons = {[2 1 3], ... [C4 0.2Hz NREM2]
               [10 66 3], ... [Pz 13.2Hz NREM2]
               [1 1 4], ... [C3 0.2Hz SWS]
               [5 3 5] ... [F4 0.6Hz REM]
               };

%% SPECIFY FILENAME(S) - OPTIONAL
% you can manually specify filenames here, or leave empty for pop-up
pathname = '';
filename = {'',...
    ''
    };

% Specify output directory, or leave empty to use pop-up
resultDir = '';

if isempty(pathname)
    [filename,pathname] = loadEEGlab();
end

%% SELECT OUTPUT DIRECTORY
if isempty(resultDir)
    disp('Please select a directory in which to save the results.');
    resultDir = uigetdir('', 'Select the directory in which to save the results');
end

tic

% process each file
for nfile = 1:length(filename)
    
    % load file & update filename and path info
    load([pathname char(filename(nfile))]);
    disp(strcat('File ',{' '},filename{1,nfile},{' '},'loaded'))
    OutputPath = [resultDir,filesep];
    OutputFile = char(filename(nfile));
    
    IDs = str2num(char(strrep(allSubjectsData.ID,'S',''))); % numeric subject IDs
    
    for ncomp = 1:length(comparisons)
        
        nsite = comparisons{1,ncomp}(1,1);
        nbin = comparisons{1,ncomp}(1,2);
        nstage = comparisons{1,ncomp}(1,3);
        
        night{1} = reshape(allSubjectsData.mspectra(nsite,nbin,nstage,1,:),length(allSubjectsData.ID),1); % control
        night{2} = reshape(allSubjectsData.mspectra(nsite,nbin,nstage,2,:),length(allSubjectsData.ID),1); % novice
        night{3} = reshape(allSubjectsData.mspectra(nsite,nbin,nstage,3,:),length(allSubjectsData.ID),1); % expert
        night{4} = reshape(allSubjectsData.mspectra(nsite,nbin,nstage,4,:),length(allSubjectsData.ID),1); % retest
        
        % run paired t-tests for all possible comparisons
        header = {'Night1' 'Night2' 'Mean1' 'Mean2' 'MDiff' 'SDDiff' 'tValue' 'pValue'};
        counter = 1;
        for n1 = 1:length(night)
            for n2 = 1:length(night)
                if n1 == n2
                    % skip
                else
                    night1{counter} = n1;
                    night2{counter} = n2;
                    mean1{counter} = mean(night{n1});
                    mean2{counter} = mean(night{n2});
                    mDiff{counter} = mean1{counter}-mean2{counter};
                    time1 = night{n1};
                    time2 = night{n2};
                    [h,p,ci,stats] = ttest(time1,time2);
                    sdDiff{counter} = stats.sd;
                    tValue{counter} = stats.tstat;
                    pValue{counter} = p;
                    counter = counter + 1;
                end
            end
        end
        T = table([night1{:}]',[night2{:}]',[mean1{:}]',[mean2{:}]',[mDiff{:}]',[sdDiff{:}]',[tValue{:}]',[pValue{:}]','VariableNames',header);
        tResults{ncomp} = T;
    end
end

%% SAVE RESULTS
save([OutputPath 't-statsFFT.mat'],'tResults','comparisons')

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