function ds_Takeuchi3dual_2A1D_500_to_500(prefix, date, expNo, sessionNo)
%   ytake 2020

%% meta infomation
metaInfo = struct(...
    'expNo', expNo,...
    'sessionNo', sessionNo,...
    'datFileNameBase', [prefix '_' num2str(date) '_exp' ],...
    'nChannels', 63,...
    'sr', 500,...
    'srLFP', 500 ...
    );
%% path
addpath(genpath('helper'))
addpath(genpath('lib'))

%% dat file preparations
% move to data folder
currentFolder = pwd;
cd('../data/')

% processing
disp('dat file preparations...');tic
datFileNameBase = [metaInfo.datFileNameBase num2str(metaInfo.expNo) '_' num2str(metaInfo.sessionNo) ];
if(exist([datFileNameBase '.dat'],'file'))
disp(['processing ' datFileNameBase '.dat'])
[ flag ] = lfpprepf_Takeuchi3_dual_with2A1D_500Hz( datFileNameBase, metaInfo.srLFP, metaInfo.nChannels);
fprintf('flag = %d\n', flag)
end
disp('processing done'); toc

% move files to results folder
movefile([datFileNameBase '_LFP_reorg_1.dat'], ['../code/tmp/' datFileNameBase '_LFP500_1.dat']);
movefile([datFileNameBase '_LFP_reorg_2.dat'], ['../code/tmp/' datFileNameBase '_LFP500_2.dat']);
movefile([datFileNameBase '_adc_1.dat'], ['../code/tmp/' datFileNameBase '_adc_1.dat']);
movefile([datFileNameBase '_adc_2.dat'], ['../code/tmp/' datFileNameBase '_adc_2.dat']);
movefile([datFileNameBase '_dig.dat'], ['../code/tmp/' datFileNameBase '_dig.dat']);

% come back to current folder
cd(currentFolder)

end

