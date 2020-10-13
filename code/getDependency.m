%% get dependency files for mstle_pwrspctrm preprocessing
% Copyright © 2017–2020 Yuichi Takeuchi
%% initialization

clear; clc
%% metainfo
%%
filename = 'main_LTR1_80';
%% path
%%
addpath(genpath('helper'))
addpath(genpath('lib'))
%% Process
%%
[fList,pList] = matlab.codetools.requiredFilesAndProducts(filename);
for i = 1:length(fList)
    disp(fList(i))
end

% Copy dependencies to dep sub folder made in current folder
mkdir dep
for i=1:length(fList)
    C = strsplit(fList{i},'\');
    system(['copy ' fList{i} ' ' pwd '\dep\' C{length(C)}]);
end

clear C i fList pList