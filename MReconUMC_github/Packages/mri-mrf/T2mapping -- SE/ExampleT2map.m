%% Example T2mapping with Spin Echo
% Only works with my specific Spin-Echo examcard.
%
% Make sure the location in both the T1mapping functions are good. So they
% must end with DICOM/IM_'
%
% Note that the example dataset has a water bottle with a T2 of 2700 ms, so
% they agarose phantoms have around 80, very hard to see.
TElist=[50 100 150 200 250 300 35 70 105 140 175 210 20 40 60 80 100 120];
SE_T2map(SE_T2map>400)=400;
%loc='C:\Users\s116555\Documents\Tom bmt\Master\Stage\Matlab\T2mapping -- SE\T2dataset\DICOM\IM_';
[SE_T2map,IM,Amap]=T2mapping(T2imgs,TElist);

%% Inspect fit
inspectFitT2(SE_T2map,Amap,IM,TElist)

%% Average value of ROI
avgval(SE_T2map,8)