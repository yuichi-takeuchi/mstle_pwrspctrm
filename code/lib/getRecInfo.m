function [RecInfo] = getRecInfo(expnum1, expnum2, date, LTR, srLFP)
% datString: String vector, e.g. [ "AP_180815_exp01_01"
%       "AP_180815_exp01_02"    "AP_180815_exp02_01"]
% Copyright (C) 2018–2020 Yuichi Takeuchi

%% organize rec info
datfilenamebase = ['AP_' num2str(date) '_exp'];
RecInfo = struct(...
    'expnum1', expnum1,... % num of experiment
    'expnum2', expnum2,... % number of session
    'datfilenamebase', datfilenamebase,...
    'LTR', LTR,...
    'date', date,...
    'srLFP', srLFP...
    );
count = 1:numel(expnum1)*numel(expnum2); % only 
for k = expnum1
    for l = expnum2
        RecInfo.datString(count) = string([datfilenamebase num2str(k) '_' num2str(l)]);
    end
end

end
