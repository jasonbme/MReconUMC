function [T1map,IM,Amap]=T1mapping2(IM,ITlist)
%% Methodology
% This function does simple 2 parameter T1 mapping for IR-SE sequences.
% M = A(1 - 2 * exp(-t/T1))
% I assumed that you saved both the magnitude and the phase data.
% Also in this specific order 1)Magnitude 2)Phase.
% 
%
% INPUT:  
%           - loc : Location of the DICOM files. 
%                   Should be like: 'Tom/Documents/Tom_bmt/Stage/Scan
%                   results/20150808/Scan30/DICOM/IM_' % The IM_ at the end
%                   is crucial
%           - ITlist : List of inversion times.
%
% OUTPUT:   - T1map
%           - IM : Actual images.
%           - Amap : 3 parameter model used as in C+A*exp(-t/T1), where
%           Amap are the A values for all fits. Needed for the fit
%           inspection tool.
%           - Cmap : C used in 3 parameter model.
%           - vid : Images in implay compatible format.
%
% Requirements:
%           - parfor_progress.m creates a progress_bar for paralell
%           programming. This does not significantly slow down the process.
%
% Version 2015/08/17 || Tom Bruijnen @ King's college London.

%% Function
tic % Keep track of how long it takes.
% Use readDicom function to read in phase+magnitude information.
%[IM,vid]=readDicom(2*length(ITlist),loc);

T1map=zeros(numel(IM(:,:,1)),1);  % Allocate memory for T1map.
Amap=zeros(numel(IM(:,:,1)),1);   % Allocate memory for Amap.

ph_data=IM(:,:,11:20);  % Select the phase images.
IM=IM(:,:,1:10);    % Select the magnitude images.

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
MASK=zeros(size(IM,1),size(IM,1));
for x=1:size(IM,1);
    for y=1:size(IM,2);
        if sum_IM(x,y)>5000
            MASK(x,y)=1;
        end
    end
end
ph_data=ph_data.*repmat(MASK,[1 1 10]);
IM=IM.*repmat(MASK,[1 1 10]);

% 
% Define what pixel intensity correlates with 360 degrees.
max_ph=max(max(max(ph_data))); % 360 degrees
min_ph=min(min(min(ph_data))); % 0 degrees
border1=(max_ph-min_ph)/4;     % 90 degrees
border2=max_ph-border1;        % 270 degrees

% This loop inverts the polarity of the pixel's which intensity is actually
% still in the -z axis. So bascially it checks whether the phase is between
% [-90 90] or outside this region.
for j=1:size(IM,1)
    for k=1:size(IM,2)
        for l=1:length(ITlist)
            if ( ph_data(j,k,l) > .8)
                IM(j,k,l)=-IM(j,k,l);
            end
        end
    end
end

% Fitting settings
F = @(x,xdata)x(1)*(1-2*exp(-xdata/x(2))); % Model
x0 = [1 1000]; % Initial guess

% Use paralell programming to increase the speed.
% Using a single loop works better with parfor, hence the reshape
% operations.
reshape_IM=reshape(IM,[numel(IM(:,:,1)),length(ITlist)]);
reshape_sum_IM=reshape(sum_IM,[numel(IM(:,:,1)),1]);

% Initialise the number of cores available. Also checks whether a paralell
% pool is active already, if yes do not restart it.
% poolobj = gcp('nocreate'); 
% if isempty(poolobj)
%     poolsize = 0;
% else
%     import java.lang.*;
%     r=Runtime.getRuntime;           % These 3 lines determine the numbers of cores available.
%     ncpu=r.availableProcessors;
%     poolsize = ncpu;
% end
% 
% if poolsize<2
%     parpool(poolsize);         
% end

% Track progress in parfor with this parfor_progress function.
parfor_progress(numel(IM(:,:,1)));

% Loop over all pixels, check whether they are background or not.
% If not do the 3 parameter fitting.
for j=1:numel(IM(:,:,1))
    parfor_progress;
    if (reshape_sum_IM(j)<0.05*avgmax)  % If total pixel intensity is to low, its probably background.
        T1map(j)=0;
    else
        [fit,resnorm,~,exitflag,output] = lsqcurvefit(F,x0,ITlist,reshape_IM(j,:)); % The actual fitting
        if (fit(2)>3000)
            T1map(j)=3000;     % Everything above 3k is usually crap.
        else
            T1map(j)=fit(2);
            Amap(j)=fit(1);
        end
    end
end
parfor_progress(0); % Reset the text file used for the progress tracking.

% Reshape the 1D array's back to the actual 2D matrices.
T1map=reshape(T1map,[size(IM(:,:,1),1),size(IM(:,:,1),2)]);
Amap=reshape(Amap,[size(IM(:,:,1),1),size(IM(:,:,1),2)]);

% Display the duration of the fitting.
display('T1 fitting took: ') 
toc
end