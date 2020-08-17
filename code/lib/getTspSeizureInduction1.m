function [RecInfo,DataStruct] = getTspSeizureInduction1(metainfo, ID, closed)
% get timestamps of seizure induction, detections of rat 1
% Copyright (c) Yuichi Takeuchi

RecInfo = cell(1, size(metainfo,1));
DataStruct = cell(1, size(metainfo,1));
for i = 1:size(metainfo,1)
    [tmpRecInfo] = getRecInfo(metainfo{i,1}, metainfo{i,2}, metainfo{i,3}, metainfo{i,4}, metainfo{i,5}, 500);
    [tmpDataStruct] = getDataStruct(tmpRecInfo);
    RecInfo{i} = tmpRecInfo;
    DataStruct{i}(1) = tmpDataStruct;
%     DataStruct{i}(2) = tmpDataStruct; % duplication
end
save(['tmp/' ID '_' num2str(closed) '_RecInfo.mat' ], 'RecInfo')
save(['tmp/' ID '_' num2str(closed) '_DataStruct.mat'], 'DataStruct')

end
