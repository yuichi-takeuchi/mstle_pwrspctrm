function [flag] = sort_DatFiles(prefix, date, expNo, sessionNo, LTR, ratNo, orgTb)
% Copyright (c) 2020 Yuichi Takeuchi

flag = 0;

% move to data folder
currentFolder = pwd;
cd('tmp/')

idx = orgTb.LTR == LTR(ratNo) & orgTb.Date == date & orgTb.expNo1 == expNo & orgTb.expNo2 == sessionNo;
Tb = orgTb(idx, :);

datnamebase = [prefix '_' num2str(date) '_exp' num2str(expNo) '_' num2str(sessionNo)];
FldrInfo = dir([datnamebase '_LFP500_' num2str(ratNo) '_trial*.dat']);

% move files to results folder
% control
for i = 1:size(FldrInfo,1)
    if Tb.MSEstm(i)
        if Tb.Thresholded(i)
            copyfile(FldrInfo(i).name, [FldrInfo(i).name(1:end-4) '_sccss.dat']);
        else
            copyfile(FldrInfo(i).name, [FldrInfo(i).name(1:end-4) '_nonsccss.dat']);
        end
    else
        copyfile(FldrInfo(i).name, [FldrInfo(i).name(1:end-4) '_ctrl.dat']);
    end
end

% come back to current folder
cd(currentFolder)
flag = 1;
disp('done')

end

