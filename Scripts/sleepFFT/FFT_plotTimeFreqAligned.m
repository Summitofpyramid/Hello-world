% code to plot FFT results

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plots include: 
% 1) whole night time-frequency spectrogram per channel
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Defualt Parameters:
% PARAM = struct(...
%     'epoch', 30, ... length in seconds of sleep stage epoch {default: 30}
%     'stages', {{'W','N1','N2','N3','R'}}, ... labels of sleep stage epoch, {default: {{'W','N1','N2','N3','R,}}}
%     'baddata', {{'Movement'}}, ... label for bad data, {default: {{'Movement'}}}
%     'winsize', 5, ... size of FFT window in seconds {default: 5}. Use default for 6 windows per 30 sec sleep stage and a freq resolution of 0.2Hz.
%     'freqrange', [0 32], ... range of frequencies {default: [0 32]}
%     'plotchans', [3:5 7:9 11:14], ... vector of channel indices to include in FFT {default: [3:5 7:9 11:14]}
%     'plot', 'off' ... ['on'|'off'], plot result, {default: 'off'}
%     );

function FFT_plotTimeFreqAligned(FFT,saveName,SubjectName)
PARAM = struct(...
    'epoch', 5, ... length in seconds of sleep stage epoch {default: 30}
    'stages', {{'H0','H1','H2','H3','H4','H5','H6','H7','H8','H9'}}, ... labels of sleep stage epoch, {default: {{'W','N1','N2','N3','R,}}}
    'baddata', {{'Movement'}}, ... label for bad data, {default: {{'Movement'}}}
    'winsize', 5, ... size of FFT window in seconds {default: 5}. Use default for 6 windows per 30 sec sleep stage and a freq resolution of 0.2Hz.
    'freqrange', [0 32], ... range of frequencies {default: [0 32]}
    'plotchans', [3:5 8:12 14:18 20], ... vector of channel indices to include in FFT {default: [3:5 7:9 11:14]; i.e., C3,C4,Cz,F3,F4,Fz,Oz,P3,P4,Pz}
    'plot', 'off' ... ['on'|'off'], plot result, {default: 'off'}
    );

%% extend the FFT
FFT = extendSpectra(FFT);

%% hypnogram & time-frequency plot

%% hyponogram
% find stages to epoch
stages = {FFT.event.type};
%%
Keys = {'H0','H1','H2','H3','H4','H5','H6','H7','H8','H9'};
Values = [1,2,3,4,5,6,7,8,9,10];
mapObj = containers.Map(Keys,Values);

magnitudes = NaN(1,ceil(FFT.event(end).latency/1280));

for i = 1:length(stages)
    correspondingIndex = ceil(FFT.event(i).latency/1280);
    magnitudes(correspondingIndex) = mapObj(char(stages(i)));
end
%%
% plot the sleep stage data
figure; subplot(2,1,1);
plot(1:length(magnitudes),magnitudes, 'color',[0 0 0], 'LineWidth',2)
% axes
ylim([0 10]) % upper and lower limits of y-axis
xlim([0 length(magnitudes)]) % upper and lower limits of x-axis
set(gca,'YTickLabel',[' ',PARAM.stages,' ']) % need to customize depending on above axis scales
% labels

SubjectName = strrep(SubjectName,'_','\_');
title(['Time domain of ' SubjectName]) % figure title
xlabel('Time') % x-axis label
ylabel('Events') % y-axis label

%% time-frequency plot
% e.g., plot up to 20 Hz (winsize * freq), 5 * 20 = 100
% e.g., for channel 3 = Cz
ch = 1; % e.g., Cz

% axis scales:
% e.g., plotted to 1 20Hz and min/max
loHz = 1;
hiHz = 32;
% rescale
flo = loHz;
fhi = PARAM.winsize*hiHz;

% plot the time-frequency spectrogram
subplot(2,1,2);
image(squeeze(FFT.spectra(ch,flo:fhi,:)),'CDataMapping','scaled')

% axes
set(gca,'YDir','normal')
ylim([flo fhi]) % upper and lower limits of y-axis
xlim([0 length(magnitudes)]) % upper and lower limits of x-axis
set(gca,'YTickLabel',[4 8 12 16 20 24 28 32]) % need to customize depending on above axis scales

% colors 
set(gcf,'color','w'); % change figure background to white

% labels
title('Spectrogram') % figure title
xlabel('Time') % x-axis label
ylabel('Frequency') % y-axis label

% color bar
cbar('vert',0,[-1 1].*round(nanmax(nanmax(abs(squeeze(FFT.spectra(ch,flo:fhi,:)))))))
title('µV^2') % figure title

savefig(saveName)

%clearvars -except FFT PARAM