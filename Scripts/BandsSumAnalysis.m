%bands power sum analysis


inputPath = '/Users/stuartfogel/Documents/DrowsyDriving/FFTsOfMergedEEGs/';
outputPath = '/Users/stuartfogel/Documents/DrowsyDriving/BandsPowerSum/';

filenames = dir([inputPath '*.mat']);

BandNames = {'28-32Hz(beta4)';
    '24-28Hz(beta3)';
    '20-24Hz(beta2)';
    '16-20Hz(beta1)';
    '12-16Hz(sigma)';
    '8 -12Hz(alpha)';
    '4 - 8Hz(theta)';
    '0 - 4Hz(delta)'};

channels = {'channel1';'channel2';'channel3';'channel4';'channel5';'channel6';'channel7';'channel8';'channel9';'channel10';'channel11';'channel12';'channel13';'channel14'};

for i = 1:length(filenames)
    FFT = importdata([inputPath filenames(i).name]);
    spectra = FFT.FFT.spectra;
    BandsSumPow =zeros(size(spectra,1),8,size(spectra,3));
    BandsSumPowCell = struct;
    for j = 1:8
        low = (j-1)*4/0.2-5; % the low and higher bound inclusive
        if low<0
            low = 1;
        end
        high = j*4/0.2;
        current = spectra(:,low:high,:);
        BandsSumPow(:,j,:) = sum(current,2)*0.2; % 0.2 is the frequency resolution
    end
    
    for k = 1:size(spectra,1)
        BandsSumPowCell.(channels{k}) = array2table(flip(squeeze(BandsSumPow(k,:,:))),'RowNames',BandNames);
    end
    
    loca = find(filenames(i).name=='.');
    save([outputPath filenames(i).name(1:loca-1) '_BandPowerSum'],'BandsSumPowCell')
end



