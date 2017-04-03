% code those 'Hi' events to numeric vectors


inputPath = '/Users/stuartfogel/Documents/DrowsyDriving/FFTsOfMergedEEGs/';

outputPath = '/Users/stuartfogel/Documents/DrowsyDriving/CodedVectors/';

filenames = dir([inputPath '*.mat']);

for i = 1:length(filenames)
    current = importdata([inputPath filenames(i).name]);
    numericVec = encodingEvents(current.FFT);
    splitPosition = find(filenames(i).name=='.');
    NumericCodes = cell(size(numericVec,1),2);
    NumericCodes(:,1) = {current.FFT.event.type}';
    NumericCodes(:,2) = num2cell(numericVec);
    save([outputPath filenames(i).name(1:splitPosition-1) '_Encoded.mat'],'NumericCodes');
end