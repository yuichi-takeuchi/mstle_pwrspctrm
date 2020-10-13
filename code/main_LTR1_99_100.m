%% mstle_pwrspctrm preprocessing
% Copyright © 2020 Yuichi Takeuchi
%% initialization

clear; clc
%% metainfo
%%
ID = 'LTR1_99_100';
metainfo = {
    'AP', 181108, 1, 1, [99 100];
    'AP', 181108, 1, 2, [99 100];
    'AP', 181109, 1, 1, [99 100];
    'AP', 181110, 1, 1, [99 100];
    'AP', 181110, 1, 2, [99 100];
    'AP', 181110, 1, 3, [99 100];
    'AP', 181111, 1, 1, [99 100];
    };
%% path
%%
addpath(genpath('helper'))
addpath(genpath('lib'))
%% Downsampling and channel reorganization
%%
for i = 1:size(metainfo,1)
    ds_Takeuchi3dual_2A1D_500_to_500(metainfo{i,1}, metainfo{i,2}, metainfo{i,3}, metainfo{i,4})
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
    DataStruct{i}(1) = tmpDataStruct;
    DataStruct{i}(2) = tmpDataStruct;
end
save(['tmp/' ID '_RecInfo.mat' ], 'RecInfo')
% for i = 1:size(metainfo, 1)
%     DataStruct{1,i}(2) = DataStruct{1,i}(1);
% end
save(['tmp/' ID '_DataStruct.mat'], 'DataStruct')
clear i tmpRecInfo tmpDataStruct
%% Manual curation of timestamp1 (optional)
%%
cidx = {
    1, 1, [3 6];
    1, 2, [3 6];
    2, 1, [1];
    2, 2, [1:3];
    3, 1, [3:8];
    3, 2, [1:6];
    4, 1, [];
    4, 2, [];
    5, 1, [1:6];
    5, 2, [3:6];
    6, 1, [1:6];
    6, 2, [3:6];
    7, 1, [7 10:13 16 17];
    7, 2, [3 4 7];
    };
load(['tmp/' ID '_DataStruct.mat'], 'DataStruct')
for i = 1:size(cidx, 1)
    DataStruct{1,cidx{i,1}}(cidx{i,2}).Timestamp{1, 1}(cidx{i,3},:) = [];
    DataStruct{1,cidx{i,1}}(cidx{i,2}).TimestampMin(cidx{i,3},:) = [];
end
save(['tmp/' ID '_DataStruct_curated.mat'], 'DataStruct')
clear cidx i
%% Trial file extraction
%%
for i = 1:size(metainfo,1)
    [flag] = cut_preInductionTime_Takeuchi3_dual(RecInfo{i}, DataStruct{i});
end
clear i flag
%% Data labeling
%%
% data
orgTb = readtable('../notes/Figure3_supraTbTh.csv');
for i = 1:size(metainfo,1)
    for ii = 1:length(metainfo{i,5}) % LTR
        [flag] = sort_DatFiles(metainfo{i,1}, metainfo{i,2}, metainfo{i,3}, metainfo{i,4}, metainfo{i,5}, ii, orgTb);
    end 
end
clear i ii flag