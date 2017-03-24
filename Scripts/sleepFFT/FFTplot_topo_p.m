% code to plot p-maps from ANOVA FFT results

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plots include: 
% 1) topographic p-maps per frequency band, per sleep stage
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
allpvals = zeros(length(allSubjectsData.channel),allSubjectsData.nbins,length(allSubjectsData.stage)); % create an empty channel by fbin by stage matrix
for nstage = 1:length(allSubjectsData.stage) % each stage
    for nbin = 1:allSubjectsData.nbins % each frequency bin
        for nsite = 1:length(allSubjectsData.channel) % each site
            p = allResults{nsite,nbin,nstage}{1,5}; % get p-value from tables
            pmap(nsite,nbin,nstage) = p;
        end
    end
end
psig = pmap <= 0.05;
stage = 3; % sleep stage
fbin = 1; % frequency bin
data = pmap(:,fbin,stage);
figure; topoplot(data, FFT.chanlocs, 'maplimits',[0 0.05], 'whitebk','on');
colormap(flipud(colormap)) % flip colormap
title('NREM2 - 0.2Hz','fontSize',12,'fontweight','bold') % figure title
set(gcf,'color','w'); % change figure background to white
cbar('vert',0,[0 0.05]);
colormap(jet)
title('p') % cbar title