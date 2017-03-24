% code to plot FFT results

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plots include: 
% 1) mean whole night frequency per channel, per sleep stage
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

%% mean frequency plot
% e.g., for channel 3 = Cz
% e.g., plot up to 20 Hz (winsize * freq), 5 * 20 = 100

% axis scales:
% e.g., plotted to 1 20Hz and min/max
ch = 3; % e.g., Cz
loHz = 1;
hiHz = 20;
% rescale
xlo = PARAM.winsize*loHz;
xhi = PARAM.winsize*hiHz;
% get min & max
ylo = round(nanmin(nanmin(FFT.mspectra.data(ch,:,:))));
yhi = round(nanmax(nanmax(FFT.mspectra.data(ch,:,:))));
stage = 1; % Wake; modify depending on PARAM.stages
figure; plot(FFT.mspectra.data(ch,:,stage)', 'color',[75/255 75/255 75/255], 'LineWidth',2) % for stage W
hold on
stage = 2; % NREM1; modify depending on PARAM.stages
plot(FFT.mspectra.data(ch,:,stage)', 'color',[155/255 155/255 0], 'LineWidth',2) % for stage N1
stage = 3; % NREM2; modify depending on PARAM.stages
plot(FFT.mspectra.data(ch,:,stage)', 'color',[0 75/255 155/255], 'LineWidth',2) % for stage N2
stage = 4; % SWS; modify depending on PARAM.stages
plot(FFT.mspectra.data(ch,:,stage)', 'color',[75/255 155/255 0], 'LineWidth',2) % for stage N3
stage = 5; % REM; modify depending on PARAM.stages
plot(FFT.mspectra.data(ch,:,stage)', 'color',[155/255 0 0], 'LineWidth',2) % for stage R
axis([xlo xhi ylo yhi])
hold off
% additional options:
title('Figure title goes here') % figure title
xlabel('x-axis label goes here') % x-axis label
ylabel('y-axis label goes here') % y-axis label
legend(PARAM.stages)
set(gca,'XTickLabel',[2 4 6 8 10 12 14 16 18 20]) % need to customize depending on above axis scales
set(gcf,'color','w'); % change figure background to white

clearvars -except FFT PARAM