function [Y,f]= mtspectrumc_cell(C,params,nChannels,width)
%Multi-taper spectrum to a cell .mat file
%Input: 
%  cell data, every cell is an epoch matrix:timelength(row)*channels(column)
%  width: unit seconds
%Output:
%   Y{1,1} abs value; Y{2,1} Whitening power
%   where matrix is window*frequency*channel
% 50% overlapping
%(c) Chengguang Zheng, Qun LI 2017

num = length(C);
Y = cell(2,num);
width = width*params.Fs;

for i = 1:num
    for k = 1:nChannels
        X1 = C{i,1}(:,k);
        X1 = X1-mean(X1); 
        len = length(X1);
        winnum = floor(len/(width/2)-1);
        for j = 1:winnum
            [S,S1,f0,~] = mtspectrumc_whiten(X1((j-1)*(width/2)+1:(j+1)*(width/2),1),params);
            Y{1,i}(j,:,k)=S;% window*vaule*channel
            Y{2,i}(j,:,k)=S1;%(Whitening power) window*vaule*channel
        end
    end
    f=f0';
end