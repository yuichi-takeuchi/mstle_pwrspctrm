function [DataStruct] = getDataStruct(RecInfo)
% Copyright (C) 2018–2020 Yuichi Takeuchi

% Get timestamps from a digital channel and build a data structure

% Get timestamp cell vector from each digital channel .dat file
[ TSCellVector ] = digchf_dig2TimestampCellVector2( RecInfo.datString, 0.1, RecInfo.srLFP);

% Build a data structure (DatFile x RatNo x Trial timwstamps)
i = 1:numel(RecInfo.datString);
DataStruct(i).datafilenamebase = RecInfo.datString{i}; 
FldrInfoLFP = dir(['tmp/' RecInfo.datString{i} '_LFP*.dat']);
DataStruct(i).datfilename = string({FldrInfoLFP.name});
DataStruct(i).Timestamp = TSCellVector{i};
DataStruct(i).TimestampMin = double(TSCellVector{i}{1,1})/(RecInfo.srLFP*60);

end
