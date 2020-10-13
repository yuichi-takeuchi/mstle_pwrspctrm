%% mstle_pwrspctrm preprocessing
% Copyright © 2020 Yuichi Takeuchi
%% initialization

clear; clc
%% metainfo
%%
ID = 'LTR1_80';
metainfo = {
    'AP', 180613, 1, 3, [80];
    'AP', 180614, 1, 2, [80];
    'AP', 180616, 1, 1, [80];
    'AP', 180619, 1, 1, [80];
    'AP', 180620, 1, 1, [80];
    'AP', 180623, 1, 3, [80];
    };
%% path
%%
addpath(genpath('helper'))
addpath(genpath('lib'))
%% Downsampling and channel reorganization
%%
for i = 1:size(metainfo,1)
    ds_Takeuchi3_1A1D_500_to_500(metainfo{i,1}, metainfo{i,2}, metainfo{i,3}, metainfo{i,4})
end
clear i
%% Get timestamps of seizure induction
%%
RecInfo = cell(1, size(metainfo,1));
DataStruct = cell(1, size(metainfo,1));
for i = 1:size(metainfo,1)
    [tmpRecInfo] = getRecInfo(metainfo{i,1}, metainfo{i,2}, metainfo{i,3}, metainfo{i,4}, metainfo{i,5}, 500);
    [tmpDataStruct] = getDataStruct(tmpRecInfo);
    RecInfo{i} = tmpRecInfo;
    DataStruct{i} = tmpDataStruct;
end
save(['tmp/' ID '_RecInfo.mat' ], 'RecInfo')
save(['tmp/' ID '_DataStruct.mat'], 'DataStruct')
clear i tmpRecInfo tmpDataStruct
%% Manual curation of timestamp (optional)
%%
cidx = {
    1, 1, [1 2 10 11];
    2, 1, [1:14 16 18 19];
    3, 1, [];
    4, 1, [2 11];
    5, 1, [9:13 16:19];
    6, 1, [1 4:6 8]
    };
for i = 1:size(cidx, 1)
    DataStruct{1,cidx{i,1}}(cidx{i,2}).Timestamp{1, 1}(cidx{i,3},:) = [];
    DataStruct{1,cidx{i,1}}(cidx{i,2}).TimestampMin(cidx{i,3},:) = [];
end
save(['tmp/' ID '_DataStruct_curated.mat'], 'DataStruct')
clear cidx i
%% Trial file extraction
%%
for i = 1:size(metainfo,1)
    [flag] = cut_preInductionTime_Takeuchi3(RecInfo{i}, DataStruct{i});
end
clear i flag
%% Data labeling
%%
% data
orgTb = readtable('../notes/Figure3_supraTbTh.csv');
for i = 1:size(metainfo,1)
    for ii = 1:length(metainfo{i,5}) % LTR
        [flag] = sort_DatFiles(metainfo{i,1}, metainfo{i,2}, metainfo{i,3}, metainfo{i,4}, metainfo{i,5}, ii, orgTb)
    end 
end
clear i ii flag