%% Powerspectrum calculation for successful trials and unsuccessful trials
% (C) LI QUN 2020
% combined 7 rats
%% ============================== Part1: trial calculation =================
%% Load data
% loadcate pwrspctrm first
clc
clear
DataFolder = 'code\tmp\';
sucT = dir([DataFolder '*_sccss.dat']);
unsucT = dir([DataFolder '*_nonsccss.dat']);
nch = 30;%channel number
lenS = length(sucT);
lenUS = length(unsucT);
%% Prepare data
cd(DataFolder)
DataS = cell(lenS,1);
DataUS = cell(lenUS,1);
for i = 1:lenS
    n = sucT(i).name;
    m = memmapfile(n, 'format','int16');
    m1 = m.data;
    data = reshape(m1, nch, []);
    data = data';%recording points*channels
    DataS{i} = double(data);    
end
for i = 1:lenUS
    n = unsucT(i).name;
    m = memmapfile(n, 'format','int16');
    m1 = m.data;
    data = reshape(m1, nch, []);
    data = data';%recording points*channels
    DataUS{i} = double(data);    
end
clear i n m m1 data sucT unsucT
%% Notch 50 Hz
Fs = 500;
d = designfilt('bandstopiir','FilterOrder',2, ...
               'HalfPowerFrequency1',49,'HalfPowerFrequency2',51, ...
               'DesignMethod','butter','SampleRate',Fs);
DataS1 = DataS;
DataUS1 = DataUS;           
for i = 1:lenS
    for j = 1:nch
        DataS1{i}(:,j) = filtfilt(d,DataS{i}(:,j));
    end
end
for i = 1:lenUS
    for j = 1:nch
        DataUS1{i}(:,j) = filtfilt(d,DataUS{i}(:,j));
    end
end 
clear d i j 
%% calculate each trial power spectrum
params.tapers = [3,5];
params.pad = 0;
params.Fs = 500; %sample frequency
params.err = [1,0.05];
params.trialave = 0;
params.fpass = [0.5,150];
width = 1;% in s 
[power1,f]= mtspectrumc_cell(DataS1,params,nch,width);% suc trials power
[power2,~]= mtspectrumc_cell(DataUS1,params,nch,width);% unsuc trials power
%% Average the window 
disp ('average the window in each piece  ...')
[Powermean1,Powerstd1] = deal(cell(max(lenS,lenUS),2));
% the first column is suc, the second column is unsuc
% ============================ Suc trials=================================
for i = 1:lenS%suc trial       
    A = power1{2,i};% whiten correction
    [A1,A2] = deal(zeros(length(f),nch));          
        for p = 1:nch
            for q = 1:length(f)
                X = A(:,q,p);
                %==============Mean and Std====================
                Tempmean(1)= mean(X,1);
                Tempmean(2)= std(X,0,1);% caculating std
                Xoutlier = X-ones(length(X),1)*Tempmean(1)'...
                    -2.58.*ones(length(X),1)*Tempmean(2)'>0; 
                index = Xoutlier == 1;
                X1 = X;
                X1(index)=[]; 

                Xfrac = prctile(X1,90);
                X1 = X1.*(X1<Xfrac);
                X1 (X1 == 0) = [];

                Xfrac = prctile(X1,10);
                X1 = X1.*(X1>Xfrac);
                X1 (X1 == 0) = [];

                Tempmean(1)= mean(X1,1);% median or mean
                Tempmean(2)= std(X1,0,1);%
                A1 (q,p) = Tempmean(1);   
                A2 (q,p) = Tempmean(2); 
            end
        end            
    Powermean1{i,1} = A1; 
    Powerstd1{i,1} = A2;
end
clear A A1 A2 i p q  Tempmean X X1 Xoutlier Xfrac index
%=========================== Unsuc trials=================================
for i = 1:lenUS%unsuc trial       
    A = power2{2,i};
    [A1,A2] = deal(zeros(length(f),nch));          
        for p = 1:nch
            for q = 1:length(f)
                X = A(:,q,p);
                %==============Mean and Std====================
                Tempmean(1)= mean(X,1);
                Tempmean(2)= std(X,0,1);% caculating std
                Xoutlier = X-ones(length(X),1)*Tempmean(1)'...
                    -2.58.*ones(length(X),1)*Tempmean(2)'>0; 
                index = Xoutlier == 1;
                X1 = X;
                X1(index)=[]; 

                Xfrac = prctile(X1,90);
                X1 = X1.*(X1<Xfrac);
                X1 (X1 == 0) = [];

                Xfrac = prctile(X1,10);
                X1 = X1.*(X1>Xfrac);
                X1 (X1 == 0) = [];

                Tempmean(1)= mean(X1,1);% median or mean
                Tempmean(2)= std(X1,0,1);%
                A1 (q,p) = Tempmean(1);   
                A2 (q,p) = Tempmean(2); 
            end
        end            
    Powermean1{i,2} = A1; 
    Powerstd1{i,2} = A2;
end
clear A A1 A2 i p q  Tempmean X X1 Xoutlier Xfrac index
%%  Smooth 50 Hz in mean and std
disp ('knock ~50 Hz noise...')
Powermean50 = Powermean1;
Powerstd50 = Powerstd1;
fnoise = [47,54];%knock ~50 Hz noise 
[~,fnoiseloc] = min(abs(fnoise-f));
len = length(f(fnoiseloc(1)-1:fnoiseloc(2)+1));
num = max(lenS,lenUS);
for i = 1:num%recording days 
    for j = 1:2
        A0 = Powermean1{i,j};
        if ~isempty(A0)
            for h = 1:nch
                A = A0(:,h);        
                AM = linspace(A(fnoiseloc(1)-1),A(fnoiseloc(2)),len);            
                A1 = [A(1:fnoiseloc(1)-2);AM'; A(fnoiseloc(2)+2:end)];
                % smooth 50 Hz in mean

                B = Powerstd1{i,j}(:,h);
                BM = linspace(B(fnoiseloc(1)-1),B(fnoiseloc(2)),len);            
                B1 = [B(1:fnoiseloc(1)-2);BM'; B(fnoiseloc(2)+2:end)];
                % smooth 50 Hz in mean

                Powermean50{i,j}(:,h)= A1;
                Powerstd50{i,j}(:,h)= B1;
            end
        end
    end     
end
clear A A0 AM A1 i h len B B1 BM fnoise fnoiseloc j 
disp('done')
Powerall = Powermean50;
Powerstd = Powerstd50;
%%
disp('Calculation Part1 is finished')
save('..\..\results\Powerall.mat','Powerall','f','-v7.3');

%% ================================ Part2: whole freuqncy comparation ==============================
%% pick up 8 channles from origin 30 channels
clearvars -except Powerall f 
pickch = [3,5,9,13,23,22,26,30;...%ID 80
          3,5,8,13,23,21,26,30;...%ID 99
          3,5,8,13,23,21,26,30;...%ID 100
          3,5,12,13,24,23,27,30;... %ID 127
          3,5,11,12,20,18,26,30;... %ID 128
          3,5,14,10,23,22,26,28;... %ID 129
          3,5,11,12,20,18,26,30;];%ID 130
chname = { 'Middle MEC','Lateral MEC','Right HPC','rHPC2','Left HPC','lHPC2','S1','M1'};
nch = numel(chname);%recording days
sucID = [80,80,80,80,80,80,80,80,80,80,...
    80,80,80,80,80,80,80,80,100,100,...
    99,99,100,100,100,100,99,99,99,99,...
    99,100,100,100,...
    130,127,128,128,130,128,...
    129,130];
unsucID = [80,80,80,80,80,80,80,80,80,80,...
    80,80,80,80,80,99,99,99,100,100,100,100,...
    129,129,129,129,130,130,130,129,129,129,... 
    130,130,127,127,127,128,127,127,127,127,...
    127,128,129,129,129,130,130,129,129,129,...
    130,130,130,128,128,128,129,129,129,130,...
    130,130,130,128,128,128,129,129,129,129,...
    129,130,130,130,130,130];
A = unique(sucID);
for i = 1:length(A)
   sucID (sucID == A(i)) = i; 
   unsucID (unsucID == A(i)) = i;
end
T1 = length(sucID);%suc number
T2 = length(unsucID);%unsuc number
%% pick up channels
power1 = cell(T1,2);
for i = 1:T1    
    A0 = Powerall{i,1};
    if ~isempty(A0)
        power1{i,1} = Powerall{i,1}(:,pickch(sucID(i),:));
    end    
end
for i = 1:T2    
    A0 = Powerall{i,2};
    if ~isempty(A0)
        power1{i,2} = Powerall{i,2}(:,pickch(unsucID(i),:));
    end    
end
clear A0 i
%% put trials together
power2 = cell(1,2);
for i = 1:T1
    power2{1,1}(i,:,:) = power1{i,1}; %suc
end
for i = 1:T2
    power2{1,2}(i,:,:) = power1{i,2}; %unsuc
end
clear i 
%% Calculate mean and std of suc trials and unsuc trials 
[powermean,powerstd] = deal(cell(1,2));  
A1 = power2{1};% suc,win*f*channel
A2 = power2{2};% unsuc
for c = 1:nch
    for j = 1:length(f)
        X = A1(:,j,c);
            %==============stats====================
            Tempmean(1)= mean(X,1);
            Tempmean(2)= std(X,0,1);% caculating std
            Xoutlier = X-ones(length(X),1)*Tempmean(1)'...
                -2.58.*ones(length(X),1)*Tempmean(2)'>0; 
            index = Xoutlier == 1;
            X1 = X;
            X1(index)=[]; 

            Xfrac = prctile(X1,90);
            X1 = X1.*(X1<Xfrac);
            X1 (X1 == 0) = [];

            Xfrac = prctile(X1,10);
            X1 = X1.*(X1>Xfrac);
            X1 (X1 == 0) = [];

          X11 = X1;
          powermean{1}(j,c)= mean(X11);
          powerstd{1}(j,c) = std(X11,0,1);
          clear Tempmean X X1 Xoutlier Xfrac index
         %%
           X = A2(:,j,c);
            %==============stats====================
            Tempmean(1)= mean(X,1);
            Tempmean(2)= std(X,0,1);% caculating std
            Xoutlier = X-ones(length(X),1)*Tempmean(1)'...
                -2.58.*ones(length(X),1)*Tempmean(2)'>0; 
            index = Xoutlier == 1;
            X1 = X;
            X1(index)=[]; 

            Xfrac = prctile(X1,90);
            X1 = X1.*(X1<Xfrac);
            X1 (X1 == 0) = [];

            Xfrac = prctile(X1,10);
            X1 = X1.*(X1>Xfrac);
            X1 (X1 == 0) = [];

          X21 = X1;
          powermean{2}(j,c)= mean(X21);
          powerstd{2}(j,c) = std(X21,0,1);
          clear Tempmean X X1 Xoutlier Xfrac index

%         p = ttest2(X11,X21);
%         Stats{1}(j,c) = p;%f*channel
    end
end
clear A1 A2 p i j c X11 X21 A
save('Powerall.mat','power2','powermean','powerstd',...
    'chname','T1','T2','sucID','unsucID','-append')

%% =========================================== Part3: calculate bands =====================================
%% find band location
f1 = f;
band = [1,4;4,12;13,30;30,45;45,90];
[bandnum,n] = size(band);
bandloc = zeros(bandnum,n);
for i = 1:bandnum
    for j=1:n
        [~,bandloc(i,j)]= min(abs(band(i,j)-f1));
    end
end
clear n i j
%% mean bands
power3 = cell(1,2);
for j = 1:2%suc and unsuc
    A = power2{j};
    wnum = size(A,1);
    A11 = zeros(wnum,bandnum,nch);
    for b = 1:bandnum                    
        A11(:,b,:)= squeeze(mean(A(:,bandloc(b,1):bandloc(b,2),:),2));%win*band*channel
    end
    power3{j} = A11;%trials*band*channels
end
clear A11 A b wnum
%% Compare suc and unsuc
[Stats_p,Stats_stat,Stats_h] = deal(cell(1));   
[bandmean,bandstd] = deal(cell(1,2));  
A1 = power3{1};% suc,win*band*channel
A2 = power3{2};% unsuc
for c = 1:nch
    for j = 1:bandnum
        X = A1(:,j,c);
            %==============stats====================
            Tempmean(1)= mean(X,1);
            Tempmean(2)= std(X,0,1);% caculating std
            Xoutlier = X-ones(length(X),1)*Tempmean(1)'...
                -2.58.*ones(length(X),1)*Tempmean(2)'>0; 
            index = Xoutlier == 1;
            X1 = X;
            X1(index)=[]; 

            Xfrac = prctile(X1,90);
            X1 = X1.*(X1<Xfrac);
            X1 (X1 == 0) = [];

            Xfrac = prctile(X1,10);
            X1 = X1.*(X1>Xfrac);
            X1 (X1 == 0) = [];

          X11 = X1;
          bandmean{1}(j,c)= mean(X11);
          bandstd{1}(j,c) = std(X11,0,1);
          clear Tempmean X X1 Xoutlier Xfrac index
         %%
           X = A2(:,j,c);
            %==============stats====================
            Tempmean(1)= mean(X,1);
            Tempmean(2)= std(X,0,1);% caculating std
            Xoutlier = X-ones(length(X),1)*Tempmean(1)'...
                -2.58.*ones(length(X),1)*Tempmean(2)'>0; 
            index = Xoutlier == 1;
            X1 = X;
            X1(index)=[]; 

            Xfrac = prctile(X1,90);
            X1 = X1.*(X1<Xfrac);
            X1 (X1 == 0) = [];

            Xfrac = prctile(X1,10);
            X1 = X1.*(X1>Xfrac);
            X1 (X1 == 0) = [];

          X21 = X1;
          bandmean{2}(j,c)= mean(X21);
          bandstd{2}(j,c) = std(X21,0,1);
          clear Tempmean X X1 Xoutlier Xfrac inde
        [h,p,~,stat] = ttest2(X11,X21);
        Stats_p{1}(j,c) = p;%band*channel
        Stats_stat{1}{j,c} = stat;
        Stats_h{1}{j,c} = h;
    end
end
clear A1 A2 p i j c X11 X21 stat index f1 h 
%%
save('../results/Powerall.mat','Stats_p','Stats_stat','Stats_h','bandmean','bandstd','-append')


