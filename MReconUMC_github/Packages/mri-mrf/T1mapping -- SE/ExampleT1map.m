%% Example of how the T1mapping functions work.
%
% Only works with my specific Spin-Echo examcard, where you save magnitude + phase
% data in DICOM format.
%
% Make sure the location in both the T1mapping functions are good. So they
% must end with DICOM/IM_'

%% Fitting Code 3 parameter model
ITlist=[100,200,300,400,600,800,1000,1500,2000,3000];
% IM = the actual images.
% vid = video format of the images, use implay(vid) to play it as a video.
% Amap and Cmap are the other 2 parameters of the fitting, these are needed
% to check the fitting.
IM2=zeros(64,64,20);
IM2(:,:,1:10)=T1_M;IM2(:,:,11:20)=T1_PH;

[SE_T1map,IM,Amap,Cmap]=T1mapping3(IM2,ITlist); % Fill in the location of the data from scan 11 (in this map).

%% Inspect your fit 3 parameter model
inspectFitT1_3par(SE_T1map,Amap,Cmap,IM,ITlist)

%% Fitting Code 2 parameter model
ITlist=[100,200,300,400,600,800,1000,1500,2000,3000];
% IM = the actual images.
% vid = video format of the images, use implay(vid) to play it as a video.
% Amap and Cmap are the other 2 parameters of the fitting, these are needed
% to check the fitting.
[SE_T1map,IM,Amap]=T1mapping2(IM2,ITlist); % Fill in the location of the data from scan 11 (in this map).

%% Inspect your fit 2 parameter model
inspectFitT1_2par(SE_T1map,Amap,IM,ITlist)


%% Find average value in a ROI
avgval(SE_T1map,8)

