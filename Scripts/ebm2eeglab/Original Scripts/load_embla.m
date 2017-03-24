## Copyright (C) 1996-1997 Flaga hf. Medical Devices (authored by Rognvaldur J. Saemundsson)
## Modified by Joris Coppens, 071014, TSD Netherlands institute for Neuroscience
## Copyright (C) 2013 Carnë Draug <carandraug@octave.org>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## Documentation:
##
##  This script will ask to select files with ebm extension, load all of them
##  into a struct array with a signal (the actual data) and header (metadata)
##  fields.  This code was based on the function ebmread downloaded on
##  July 9th, 2013 from https://github.com/gpiantoni/hgse_private which
##  claims the code to also be under GPLv3+.
##
## NOTE:
##
##  This code has been tested with Octave 3.6.2 and requires no package to
##  be installed.

1; # one is the loneliest number

function [data, header] = ebmread (filename)

  %      data : Matrix holding the data (in volts)
  %
  %       header: Struct containing
  %       header.fileversion    ( should be 4 )
  %       header.channelname
  %       header.subjectinfo
  %       header.channel        ( channel number )
  %       header.samplingrate   ( samples per second )
  %       header.unitgain       ( multiplier for calibration of raw data in volts)
  %       header.starttime      ( number that gives the startdate in internal Matlab units)
  %       header.starttimedescr ( string with readable start time of the recording)
  %
  %   Multiple recordings in one embla file are supported. Missing data is filled with zeros.
  %   Embla files with large gaps between recordings will result in errors due to lack of memory 
  %   for the zeros.

  ##      Definitions
  EBM_R_VERSION           = hex2dec ("80");
  EBM_R_SUBJECT_INFO      = hex2dec ("d0");
  EBM_R_HEADER            = hex2dec ("81");
  EBM_R_TIME              = hex2dec ("84");
  EBM_R_CHANNEL           = hex2dec ("85");
  EBM_R_SAMPLING_RATE     = hex2dec ("86");
  EBM_R_UNIT_GAIN         = hex2dec ("87");
  EBM_R_CHANNEL_NAME      = hex2dec ("90");
  EBM_R_DATA              = hex2dec ("20");
  EBM_UNKNOWN_DATASIZE    = hex2dec ("FFFFFFFF");
  EBM_END_OF_SIGNATURE    = hex2dec ("1A");
  EBM_MAX_SIGNATURE_SIZE  = 80;
  EBM_MAC_ENDIAN          = hex2dec ("FF");
  EBM_INTEL_ENDIAN        = hex2dec ("00");

  initial_endian = "ieee-be";

  [fp, msg] = fopen (filename, "rb", initial_endian);
  if (fp == -1)
    error ("unable to fopen %s: %s", filename, msg);
  endif

  signature = zeros (1, EBM_MAX_SIGNATURE_SIZE);
  idx = 0;
  do
    idx++;
    signature(idx) = fread (fp, 1, "char=>char");
  until (double (signature(idx)) == EBM_END_OF_SIGNATURE || idx > EBM_MAX_SIGNATURE_SIZE)

  signature(idx:end) = []; # remove the end of signature signal

  if (idx > EBM_MAX_SIGNATURE_SIZE ||
      ! any (strcmp (char (signature), {"Embla data file", "Embla results file"})))
    error ("this is not a Embla data or results file");
  endif

  ## Read the endian format and reopen file if we used the wrong one
  ch = fread (fp, 1, "uchar");
  if (ch == EBM_MAC_ENDIAN)
    correct_endian = "ieee-be";
  elseif (ch == EBM_INTEL_ENDIAN)
    correct_endian = "ieee-le";
  else
    error ("unable to identify correct file architecture interpretation");
  endif

  if (! strcmp (initial_endian, correct_endian))
    pos = ftell (fp);
    fclose (fp);
    [fp, msg] = fopen (filename, "rb", correct_endian);
    if (fp == -1)
      error ("unable to fopen %s: %s", filename, msg);
    endif
    fseek (fp, pos, "bof");
  endif

  ## check if the ID fields is wide (ulong), or short (uchar)
  ID_precision = "uchar";
  ## Store the position of the start of the block structure
  ## If this is not a file with 8 bit block IDs then we will change
  ## this again.
  block_offset = ftell (fp);
  ## If the file has wide Id's we will get 5 bytes of 0xFF
  ## 8 bit interprets this as an invalid block for the rest of the file.
  if (fread (fp, 1, "uchar") == hex2dec ("FF") && fread (fp, 1, "uint32") == hex2dec ("FFFFFFFF"))
    ## We have 32 bit block IDs so we skip the rest of the
    ## 32 byte header and store the position of the block
    ## structure which should start right after.
    block_offset += 31;
    ID_precision  = "uint32"; # we have wide IDs
  endif

  ## Finally start reading the data
  rec     = 0;
  recnum  = 0;

  do
    fseek (fp, block_offset, "bof");
    rec     = fread (fp, 1, ID_precision);
    recSize = fread (fp, 1, "int32");
    recPos  = ftell (fp);
    block_offset = recPos + recSize;

    switch (rec)
      case EBM_R_DATA,
        newdata = fread (fp, recSize/2, "int16");
        if (recnum == 1)
          data  = newdata;
          prlen = length (data);
        else
          prev        = starttime(recnum-1);
          prevend     = prev+prlen / (header.samplingrate * 60 * 60 * 24);
          current     = starttime(recnum);
          fill        = current - prevend;
          fillsamples = round (max (0, fill * 60 *60 * 24 * header.samplingrate));
          filldata    = zeros (fillsamples, 1);
          data        = [data; filldata; newdata];
          prlen       = length ([filldata; newdata]);
        endif

      case EBM_R_TIME,
        recnum++;
        year    = fread (fp, 1, "int16");
        month   = fread (fp, 1, "int8");
        day     = fread (fp, 1, "int8");
        hour    = fread (fp, 1, "int8");
        minute  = fread (fp, 1, "int8");
        second  = fread (fp, 1, "int8");
        hsec    = fread (fp, 1, "int8");
        starttime(recnum) = datenum (year, month, day, hour, minute, second+ 0.01*hsec);
        if (recnum == 1)
          header.starttime      = starttime(1);
          header.starttimedescr = datestr (header.starttime, 0);
        endif

      case  EBM_R_VERSION,
        minor = fread (fp, 1, "int8");
        major = fread (fp, 1, "int8");
        header.fileversion = major + 0.01*minor;

      case EBM_R_SUBJECT_INFO,
        header.subjectinfo = deblank (char (fread (fp, recSize, "int8")'));

      case EBM_R_HEADER,
        header.extra=deblank(char (fread (fp, recSize, "int8")'));

      case EBM_R_CHANNEL,
        header.channel = fread (fp, 1, "int16");

      case EBM_R_SAMPLING_RATE,
        ## The sampling rate is in mHz
        header.samplingrate = fread (fp, 1, "int32") / 1000;

      case EBM_R_UNIT_GAIN,
        ## unit gain is in nV/bit. Change it to V/bit
        header.unitgain = fread (fp, 1, "int32") * 1e-9;

      case EBM_R_CHANNEL_NAME,
        header.channelname = deblank (char (fread (fp, recSize, "int8")'));

      otherwise
        ## do nothing. Possibly just an unrecognized metadata field
    endswitch
  until (feof (fp))

  fclose (fp);
  data = data * header.unitgain;
endfunction

[fnames, fpath] = uigetfile ("*.ebm", "MultiSelect", "on");
if (isnumeric (fnames) && ! fnames)
  display ("No file selected. Exiting...");
  return
endif

if (ischar (fnames))
  ## uigetfile() returns different things whether a single of multiple files
  ## are selected.  This looks weird and may be an actual bug in Octave or
  ## some weird behaviour Octave needs to replicate for Matlab compatibility
  fnames = {fnames};
endif

data = struct ();
for idx = 1:numel (fnames)
  data(idx).filename = [fpath fnames{idx}];
  [data(idx).signal, data(idx).header] = ebmread (data(idx).filename);
endfor
