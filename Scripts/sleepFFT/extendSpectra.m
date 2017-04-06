%% extend the spectrogram by filling missed epoches with blank area

function extendedFFT = extendSpectra(FFT)
extendedFFT = FFT;

endTime = FFT.event(end).latency;

totalEpoches = ceil(endTime/1280);

extendedSpectra = zeros(size(FFT.spectra,1),size(FFT.spectra,2),totalEpoches);

for i = 1:length(FFT.event)
    matched = ceil(FFT.event(i).latency/1280);
    extendedSpectra(:,:,matched) = FFT.spectra(:,:,i);
end
extendedFFT.spectra = extendedSpectra;