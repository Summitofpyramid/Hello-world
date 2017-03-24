function [data, header] = ebm2mat(filepath)

%	=======================================
%	Convert Embla data files to Matlab
%	=======================================
%
%	Version 3.0
%	Based on ebmread.m version 1.10 by Rognvaldur J. Saemundsson
%	Modified by Joris Coppens, 071014, TSD Netherlands institute for Neuroscience
%   Modified by Stuart Fogel, 2014-03-20, The Brain & Mind Institute, Western University
%
%    USAGE:
%
%      [ data header ] = ebm2mat( fileName );
%
%      fileName  : Filename, including path. If omitted a standard get file dialog will appear.
%
%      Select each *.ebm file that corresponds to each individual channel (e.g., Fz, Cz, Pz, etc...) per recording.
%
%      data : Matrix holding the data (in volts)
%
%      header: Struct containing
%			header.fileversion		( should be 4 )
%			header.channelname      ( cell array for channel names )
%			header.subjectinfo
%			header.channel			( cell array for channel number )
%			header.samplingrate		( samples per second )
%			header.unitgain			( cell array for multiplier for calibration of raw data in volts )
%			header.starttime		( number that gives the startdate in internal Matlab units )
%			header.startdate    	( string with readable start date of the recording )
%           header.starttimeclock   ( string with readable start time of the recording )
%
%   Tested using Embla data files (*.ebm) recorded using RemLogic 3.3.2
%   from Embla Titanium amplifiers
%
%   Modified to handle multiple channels per recording, and save all data and header info to one .mat file.

%   Version 2.0 comments:
%	=======================================
%	Embla file reader for Matlab
%	=======================================
%
%	Version 2.0
%	Based on ebmread.m version 1.10 by Rognvaldur J. Saemundsson
%	Modified by Joris Coppens, 071014, TSD Netherlands institute for Neuroscience
%
%    USAGE:
%
%      [ data header ] = ebm2mat( fileName );
%
%      fileName  : Filename, including path. If omitted a standard get file dialog will appear.
%
%      data : Matrix holding the data (in volts)
%
%      header: Struct containing
%			header.fileversion		( should be 4 )
%			header.channelname
%			header.subjectinfo
%			header.channel			( channel number )
%			header.samplingrate		( samples per second )
%			header.unitgain			( multiplier for calibration of raw data in volts)
%			header.starttime		( number that gives the startdate in internal Matlab units)
%			header.starttimedescr	( string with readable start time of the recording)
%
%	Multiple recordings in one embla file are supported. Missing data is filled with zeros.
%	Embla files with large gaps between recordings will result in errors due to lack of memory
%   for the zeros.

%	The original comments:
%    ======================================
%    Embla File Format - EBM Developers Kit
%    ======================================
%
%    Flaga hf. Medical Devices
%    Copyright (c) 1996-1997.
%    All Rights Reserved.
%
%    FILE:         EbmRead.m
%    AUTHOR:       Rognvaldur J. Saemundsson
%
%    VERSION:      1.12
%    MODIFIED:     Joris Coppens
%    Modified line 198 to give an error, where the fseek operation could fail in V1.10.
%    It was failing on non-integer offsets, now it is explicitly turned into an integer.
%    Furthermore, error checking was added.
%
%    Return header structure with more information than just the samplerate
%
%    OVERVIEW
%    ========
%    This software reads EBM files from Embla into a Matlab matrix.
%
%    Technical questions should be directed to:
%
%    	support@flaga.is
%
%    USAGE:
%
%      [ data samplingRate ] = EbmRead( fileName, start, noSamples, scaled );
%
%      fileName  : Filename, including path. If [] a standard get file dialog will appear.
%      start     : Starting index of samples to be read (first sample in file is 0)
%      noSamples : Number of samples to be read. If 'ALL' it reads from start to the end of the file.
%      scaled    : If 1 the data is scaled according to unit gain in the file (default is 1)
%                  Scaling should only be used if the unit of the data file is V.
%
%      data : Matrix holding the data (noSamples x 1)
%      samplingRate : Sampling rate of the data (Hz)
%

%      Definitions

EBM_RAWDATA_HEADER = 'Embla data file';
EBM_RESULTS_HEADER = 'Embla results file';

EBM_R_VERSION=hex2dec('80');
EBM_R_SUBJECT_INFO=hex2dec('d0');
EBM_R_HEADER=hex2dec('81');
EBM_R_TIME = hex2dec('84');
EBM_R_CHANNEL=hex2dec('85');
EBM_R_SAMPLING_RATE = hex2dec( '86' );
EBM_R_UNIT_GAIN = hex2dec( '87' );
EBM_R_CHANNEL_NAME=hex2dec('90');
EBM_R_DATA =	hex2dec( '20' );
EBM_UNKNOWN_DATASIZE = hex2dec( 'FFFFFFFF' );
EBM_END_OF_SIGNATURE = hex2dec( '1A' );
EBM_MAX_SIGNATURE_SIZE = 80;
EBM_MAC_ENDIAN = hex2dec( 'FF' );
EBM_INTEL_ENDIAN = hex2dec( '00' );

ERROR_UNKNOWN_SIGNATURE = 'This is not a Embla data file';
ERROR_FILE_NOT_FOUND = 'Could not open data file';
ERROR_UNKNOWN = 'Failure in reading the file';
ERROR_CANCEL = 'Operation was canceled';

DW_SIZE = 4;   % Size of double word
W_SIZE = 2;    % Size of word
BYTE_SIZE = 1; % Size of byte

endian = 'ieee-be';  % Big endian by default (Mac endian)
reopen = 0;          % Determines if we have to reopen the file after detecting the endian format

data = [];
fileName = {};
datapoints=0; % how many entries will there be in the matrix?

% Open the file in the default endian format

if nargin<1
    [ filename, filepath ] = uigetfile('*.ebm', 'Select EBM data files corresponding to each channel, from one recording:','MultiSelect', 'on');
    if ( filename{1,1} == 0 )
        error( ERROR_CANCEL );
    end;
else
    % get the EBM data file names
    filenames = dir(fullfile([filepath '*.ebm']));
    filename = {filenames(:).name};
end;

% find out how many measurements there are in each channel file
[datapoints, ~]=getEBMsize(strcat(filepath, filename(1,1)));

% preallocate data matrix accordingly (1 row per channel, 1 column per measurement)
data=nan(length(filename), datapoints);

for nch = 1:length(filename)
    
    
    fileName{nch,1} = strcat(filepath, filename(1,nch));
    fp = fopen( char(fileName{nch,1}), 'rb', endian );
    
    if ( fp == - 1 )
        error( ERROR_FILE_NOT_FOUND );
    end;
    
    % Read the signature of the file
    
    signature = zeros( 1, EBM_MAX_SIGNATURE_SIZE );
    i = 1;
    signature( i ) = fread( fp, 1, 'char' );
    
    while  ( signature( i ) ~= EBM_END_OF_SIGNATURE & i < EBM_MAX_SIGNATURE_SIZE )
        i=i+1;
        signature( i ) = fread( fp, 1, 'char' );
    end;
    
    if ( i == EBM_MAX_SIGNATURE_SIZE )
        error( ERROR_UNKNOWN_SIGNATURE );
    end;
    
    if ( findstr( signature, EBM_RAWDATA_HEADER ) ~= 1 )
        if ( findstr( signature, EBM_RESULTS_HEADER ) ~= 1 )
            error( ERROR_UNKNOWN_SIGNATURE );
        end;
    end;
    
    % Read the endian format
    
    ch = fread( fp, 1, 'uchar' );
    
    if ( ch == EBM_MAC_ENDIAN )
        endian = 'ieee-be';
    elseif ( ch == EBM_INTEL_ENDIAN )
        endian = 'ieee-le';
        reopen = 1;
        pos = ftell( fp );
        fclose( fp );
        fopen( char(fileName{nch,1}), 'rb', endian );
        if ( fp == -1 )
            error( ERROR_UNKNOWN );
        end;
        fseek( fp, pos, 'bof' );
    else
        error( ERROR_UNKNOWN );
    end;
    
    wideId = 1;
    
    % Store the position of the start of the block structure
    % If this is not a file with 8 bit block IDs then we will change
    % this again.
    
    firstBlockOffset = ftell( fp );
    
    % If the file has wide Id's we will get 5 bytes of 0xFF
    % 8 bit interprets this as an invalid block for the rest of the file.
    
    ch = fread( fp, 1, 'uchar' );
    
    if( ch == hex2dec( 'FF' ) )
        ch = fread( fp, 1, 'ulong' );
        if ( ch == hex2dec( 'FFFFFFFF' ) )
            % We have 32 bit block IDs so we skip the rest of the
            % 32 byte header and store the position of the block
            % structure which should start right after.
            
            firstBlockOffset = firstBlockOffset + 31;
            wideId = 1;
        end;
    end;
    
    % Seek back to the start of the block structure
    fseek( fp, firstBlockOffset, 'bof' );
    
    
    % Find the data block
    rec = 0;
    recnum=0;
    while 1
        
        if( wideId ~= 0 )
            rec = fread( fp, 1, 'ulong' );
        else
            rec = fread( fp, 1, 'uchar' );
        end;
        
        recSize = fread( fp, 1, 'long' );
        recPos = ftell( fp );
        
        
        if ( rec == EBM_R_VERSION)
            minor=fread(fp, 1, 'int8');
            major=fread(fp, 1, 'int8');
            header.fileversion=major+0.01*minor;
        end
        
        if (rec == EBM_R_SUBJECT_INFO)
            tmp=fread(fp, recSize, 'int8');
            header.subjectinfo=deblank(char(tmp'));
        end
        
        if (rec == EBM_R_HEADER)
            tmp=fread(fp, recSize, 'int8');
            header.extra=deblank(char(tmp'));
        end
        
        if (rec == EBM_R_TIME)
            year=fread(fp, 1, 'int16');
            month=fread(fp, 1, 'int8');
            day=fread(fp, 1, 'int8');
            hour=fread(fp, 1, 'int8');
            minute=fread(fp, 1, 'int8');
            second=fread(fp, 1, 'int8');
            hsec=fread(fp, 1, 'int8');
            recnum=recnum+1;
            if recnum==1
                header.starttime=datenum(year, month, day, hour, minute, second+ 0.01*hsec);
                header.startdate=datestr(header.starttime, 'dd-mmm-yyyy', 0);
                header.starttimeclock=datestr(header.starttime, 'HH:MM:SS.FFF', 0);
            end
            starttime(recnum)=datenum(year, month, day, hour, minute, second+ 0.01*hsec);
        end
        
        if (rec == EBM_R_CHANNEL)
            header.channel{nch,1}=fread(fp, 1, 'int16');
        end
        
        % Check if we have the sampling rate
        
        if ( rec == EBM_R_SAMPLING_RATE )
            % The sampling rate is in mHz
            header.samplingrate = fread( fp, 1, 'long' ) / 1000;
        end;
        
        if ( rec == EBM_R_UNIT_GAIN )
            header.unitgain{nch,1} = fread( fp, 1, 'long' ) * 1e-9; % unit gain is in nV/bit. Change it to V/bit
        end;
        
        if (rec == EBM_R_CHANNEL_NAME)
            tmp=fread(fp, recSize, 'int8');
            header.channelname{nch,1}=deblank(char(tmp'));
        end
        
        if ( rec == EBM_R_DATA )
            newdata = fread( fp, recSize/2, 'short' );
            if recnum==1
                dataTemp=nan(datapoints,1);
                dataTemp(1:length(newdata))=newdata;
                prlen=length(newdata);
            else	% We have more than one record
                prev=starttime(recnum-1);
                prevend=prev+prlen/(header.samplingrate*60*60*24);
                current=starttime(recnum);
                fill=current-prevend;
                fillsamples=round(max(0, fill*60*60*24*header.samplingrate));
                filldata=zeros(fillsamples, 1);
                nextindex=find(isnan(dataTemp),1,'first');%find the next open slot in the measurement vector (the first occurence of NaN)
                filldata=[filldata;newdata];%merge the filler zeros with the new data
                %append the next chunk of data at the next open slot in the measurement vector
                dataTemp(nextindex:nextindex+length(filldata)-1)=filldata(:);
                prlen=length(filldata);
                clear filldata;
            end
        end;
        
        if feof(fp)
            break
        end
        fseek( fp, recPos + recSize, 'bof' );
    end
    
    
    fclose( fp );
    
    disp(strcat('Exporting data for channel', {' '}, char(header.channelname(nch)), '...'));
    dataTrans = transpose(dataTemp * header.unitgain{nch,1});
    
    data(nch,:) = dataTrans(:);%copy the vector to the data array
    clear dataTrans dataTemp
    
    % Commented out, because my lack-luster Matlab skills prevent me from understanding what this is really for.
    %     if nargout==2
    %         varargout(1)={header};
    %     end
    
end

% change to double precision for compatibility
data = double(data);

% change from Volts to microvolts
data = data*1000000;

% save header and data to .mat file
header.filepath = filepath;
% matName = strcat(filepath,header.subjectinfo);
% disp(char(strcat({'Saving Embla export to: '},{matName},{'.mat file...'})));
% save(matName,'header','data');