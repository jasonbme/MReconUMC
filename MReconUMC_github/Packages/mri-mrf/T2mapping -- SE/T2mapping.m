function [T2map,IM,Amap]=T2mapping(IM,TElist)
%% Methodology
% This function does simple 3 parameter T2 mapping for SE sequences.
% M = A * exp(-t/T1)
% 
% INPUT:   
%           - loc : Location of the DICOM files. 
%                   Should be like: 'Tom/Documents/Tom_bmt/Stage/Scan results/20150808/Scan30/DICOM/IM_'
%           - TElist : List of echo times.
%
% OUTPUT:   - T2map
%           - vid : Images in implay compatible format.
%           - Amap : 3 parameter model used as in C+A*exp(-t/T2), where
%           Amap are the A values for all fits. Needed for the fit
%           inspection tool.
%           - Cmap : C used in 3 parameter model.
%
% Requirements:
%           - parfor_progress.m creates a progress_bar for paralell
%           programming. This does not significantly slow down the process.
%
% Version 2015/08/08 || Tom Bruijnen @ King's college London.

%% Function
tic % Keep track of how long it takes.
%[IM,vid]=readDicom(length(TElist),loc);  % Read DICOM files
T2map=zeros(numel(IM(:,:,1)),1);  % Allocate memory
Amap=zeros(numel(IM(:,:,1)),1);   % Allocate memory (A parameter from model)

% Calculate sum of intensities over all the images.
% This is used to create a simple mask. Actually masking is done in the
% fitting loop.
sum_IM=zeros(size(IM(:,:,1)));
for j=1:size(IM,1)
    for k=1:size(IM,2)
        sum_IM(j,k)=sum(IM(j,k,:));
    end
end

% Find the average maximum of these sums. Take the sum of the 10 maxima and
% divide it by 10.
sort_sum=sort(reshape(sum_IM,[numel(sum_IM),1]));
avgmax=sum(sort_sum(end-9:end))/10;

% Fitting settings
F = @(x,xdata)x(1)*exp(-xdata/x(2)); % Model
x0 = [1 150]; % Initial guess

% Use paralell programming to increase the speed.
% Using a single loop works better with parfor, hence the reshape
% operations.
reshape_IM=reshape(IM,[numel(IM(:,:,1)),length(TElist)]);
reshape_sum_IM=reshape(sum_IM,[numel(IM(:,:,1)),1]);

% Initialise the number of cores available. Also checks whether a paralell
% pool is active already, if yes do not restart it.
% poolobj = gcp('nocreate'); 
% if isempty(poolobj)
%     poolsize = 0;
% else
%     poolsize = 8;
% end
% 
% if poolsize<5
%     parpool(8);
% end

% Track progress in parfor with this parfor_progress function.
parfor_progress(numel(IM(:,:,1)));

% Loop over all pixels, check whether they are background or not.
% If not do the 3 parameter fitting.
for j=1:numel(IM(:,:,1))
    parfor_progress;
    if (reshape_sum_IM(j)<0.05*avgmax) % If total pixel intensity is to low, its probably background.
        T2map(j)=0;
    else
        [fit,resnorm,~,exitflag,output] = lsqcurvefit(F,x0,TElist,reshape_IM(j,:)); % The actual curve fitting.
        if (fit(2)>3000 || fit(2)<0)       % Filter out outliers
            T2map(j)=0;   
        else
            T2map(j)=fit(2);
            Amap(j)=fit(1);
        end
    end
end
parfor_progress(0); % Reset the text file used for the progress tracking.

% Reshape the 1D array's back to the actual 2D matrices.
T2map=reshape(T2map,[size(IM(:,:,1),1),size(IM(:,:,1),2)]);
Amap=reshape(Amap,[size(IM(:,:,1),1),size(IM(:,:,1),2)]);

% Display the duration of the fitting.
display('T2 fitting took: ') 
toc
end