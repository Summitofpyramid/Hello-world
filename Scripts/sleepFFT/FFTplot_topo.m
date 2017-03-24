% code to plot FFT results

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plots include: 
% 1) topographic plots per frequency band, per sleep stage
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
PARAM = struct(...
    'epoch', 5, ... length in seconds of sleep stage epoch {default: 30}
    'stages', {{'H0','H1','H2','H3','H4','H5','H6','H7','H8','H9'}}, ... labels of sleep stage epoch, {default: {{'W','N1','N2','N3','R,}}}
    'baddata', {{'Movement'}}, ... label for bad data, {default: {{'Movement'}}}
    'winsize', 1, ... size of FFT window in seconds {default: 5}. Use default for 6 windows per 30 sec sleep stage and a freq resolution of 0.2Hz.
    'freqrange', [0 32], ... range of frequencies {default: [0 32]}
    'plotchans', [3:5 8:12 14:18 20], ... vector of channel indices to include in FFT {default: [3:5 7:9 11:14]; i.e., C3,C4,Cz,F3,F4,Fz,Oz,P3,P4,Pz}
    'plot', 'off' ... ['on'|'off'], plot result, {default: 'off'}
    );


%% topographic plots
% e.g., plot at 13-16 Hz (winsize * freq), lofreq = 5 * 13 = 65, bandwidth = 5 * 5
lofreq = 11; % lower edge of frequency band
bandwidth = 5; % enter bandwidth in Hz; if using single point, enter 0
% rescale
lofreq = PARAM.winsize*lofreq;
bandwidth = bandwidth*PARAM.winsize;
% for freq band
lof = lofreq;
hif = lofreq + bandwidth;
lof = round(lof); % used as index in frequency range, needs to be nerest integer
hif = round(hif); % used as index in frequency range, needs to be nerest integer
% get min & max values for scaling
lo = round(nanmin(nanmin(mean(FFT.mspectra.data(:,lof:hif,:),2))));
hi = round(nanmax(nanmax(mean(FFT.mspectra.data(:,lof:hif,:),2))));

% Stage W
W = 1; % modify depending on PARAM.stages
figure; if ~isnan(FFT.mspectra.data(:,lof:hif,W))
            data = mean(FFT.mspectra.data(:,lof:hif,W),2);
            topoplot(data, FFT.chanlocs, 'maplimits',[lo hi], 'whitebk','on');
        end
title('Figure title goes here') % figure title
set(gcf,'color','w'); % change figure background to white
cbar('vert',0,[lo hi]);

% Stage N1
N1 = 2; % modify depending on PARAM.stages
figure; if ~isnan(FFT.mspectra.data(:,lof:hif,N1))
            data = mean(FFT.mspectra.data(:,lof:hif,N1),2);
            topoplot(data, FFT.chanlocs, 'maplimits',[lo hi], 'whitebk','on');
        end 
title('Figure title goes here') % figure title
set(gcf,'color','w'); % change figure background to white
cbar('vert',0,[lo hi]);

% Stage N2
N2 = 3; % modify depending on PARAM.stages
figure; if ~isnan(FFT.mspectra.data(:,lof:hif,N2))
            data = mean(FFT.mspectra.data(:,lof:hif,N2),2);
            topoplot(data, FFT.chanlocs, 'maplimits',[lo hi], 'whitebk','on');
        end
title('Figure title goes here') % figure title
set(gcf,'color','w'); % change figure background to white
cbar('vert',0,[lo hi]);

% Stage N3
N3 = 4; % modify depending on PARAM.stages
figure; if ~isnan(FFT.mspectra.data(:,lof:hif,N3))
            data = mean(FFT.mspectra.data(:,lof:hif,N3),2);
            topoplot(data, FFT.chanlocs, 'maplimits',[lo hi], 'whitebk','on');
        end
title('Figure title goes here') % figure title
set(gcf,'color','w'); % change figure background to white
cbar('vert',0,[lo hi]);

% Stage R
R = 5; % modify depending on PARAM.stages
figure; if ~isnan(FFT.mspectra.data(:,lof:hif,R))
            data = mean(FFT.mspectra.data(:,lof:hif,R),2);
            topoplot(data, FFT.chanlocs, 'maplimits',[lo hi], 'whitebk','on');
        end
title('Figure title goes here') % figure title
set(gcf,'color','w'); % change figure background to white
cbar('vert',0,[lo hi]);

clearvars -except FFT PARAM