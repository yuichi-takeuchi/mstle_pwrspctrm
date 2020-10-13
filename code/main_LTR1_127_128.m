%% mstle_pwrspctrm preprocessing
% Copyright © 2020 Yuichi Takeuchi
%% initialization

clear; clc
%% path
%%
addpath(genpath('helper'))
addpath(genpath('lib'))
%% metainfo
%%
ID = 'LTR1_127_128';
closed = 1; % 0 and 1 for open-loop and closed-loop control
metainfo = {
    'AP', 200814, 3, 3, [127 128];
    'AP', 200814, 3, 4, [127 128];
    'AP', 200814, 3, 5, [127 128];
    'AP', 200815, 2, 1, [127 128];
    'AP', 200816, 2, 1, [127 128];
    'AP', 200816, 2, 2, [127 128];
    'AP', 200818, 2, 1, [127 128];
    };
%% Downsampling and channel reorganization
%%
for i = 1:size(metainfo,1)
    ds_Takeuchi3dual_2A1D_500_to_500(metainfo{i,1}, metainfo{i,2}, metainfo{i,3}, metainfo{i,4})
end
clear i
%% Get timestamps of seizure induction (digital channel bit 0)
%%
% get timestamps of seizure induction, detections of rat 1, rat 2
[RecInfo,DataStruct] = getTspSeizureInduction2(metainfo, ID, closed)
%% Manual curation of timestamp
%%
load(['tmp/' ID '_' num2str(closed) '_RecInfo.mat' ], 'RecInfo')
load(['tmp/' ID '_' num2str(closed) '_DataStruct.mat'], 'DataStruct')
cidx = {
    1, 1, [], repmat([0 1],1,2); % record num of metainfo, rat No, rejection trial no, trues for trials to be analyzed
    1, 2, [], repmat([1 0],1,2);
    2, 1, [], repmat([0 1],1,1); % record num of metainfo, rat No, rejection trial no, trues for trials to be analyzed
    2, 2, [1 2], [];
    3, 1, [], repmat([0 1],1,3); % record num of metainfo, rat No, rejection trial no, trues for trials to be analyzed
    3, 2, [], repmat([1 0],1,3);
    4, 1, [1 2], repmat([0 1],1,5); % record num of metainfo, rat No, rejection trial no, trues for trials to be analyzed
    4, 2, [3:12], repmat([1 0],1,1);
    5, 1, [1:9], []; % record num of metainfo, rat No, rejection trial no, trues for trials to be analyzed
    5, 2, [3:9], repmat([1 0],1,1);
    6, 1, [1:4], []; % record num of metainfo, rat No, rejection trial no, trues for trials to be analyzed
    6, 2, [], repmat([1 0],1,2);
    7, 1, [1:12], []; % record num of metainfo, rat No, rejection trial no, trues for trials to be analyzed
    7, 2, [9:12], repmat([1 0],1,4);
    };
for i = 1:size(cidx, 1)
    DataStruct{1,cidx{i,1}}(cidx{i,2}).Timestamp{1, 1}(cidx{i,3},:) = [];
    DataStruct{1,cidx{i,1}}(cidx{i,2}).TimestampMin(cidx{i,3},:) = [];
    DataStruct{1,cidx{i,1}}(cidx{i,2}).idxslct = cidx{i,4};
end
save(['tmp/' ID '_' num2str(closed) '_DataStruct_curated.mat'], 'DataStruct')
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