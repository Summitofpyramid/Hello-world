% plot and save the spectrogram of FFT

FFTsPath = '/Users/stuartfogel/Documents/DrowsyDriving/FFTsOfMergedEEGsAligned/';

figurePath = '/Users/stuartfogel/Documents/DrowsyDriving/savedSpectrogramsAligned/';

FFTs = dir([FFTsPath '*.mat']);

for i =21:length(FFTs)
    saveName = FFTs(i).name;
    
    FFT = importdata([FFTsPath FFTs(i).name]);
    FFT_plotTimeFreqAligned(FFT.FFT,[figurePath saveName(1:end-4) '.fig'],FFTs(i).name);
    close all;
 
end