function MRSenseUMC( MR )
% 20160616 - Module to load sense maps from Sense Ref Scan + Coil
% Survey Scan.

% Notification
fprintf('Estimate coil maps from data (MRsense)............  ');tic;

% Get locations of CSC/SRS 
listCSC=dir([MR.ParUMC.TWD,'/CSC/','*.lab']);
locCSC=[MR.ParUMC.TWD,'/CSC/',listCSC.name];
listSRS=dir([MR.ParUMC.TWD,'/SRS/','*.lab']);
locSRS=[MR.ParUMC.TWD,'/SRS/',listSRS.name];

% Load in the MRecon objects of them
srs=MRecon(locSRS);
csc=MRecon(locCSC);

% Reload original data, because MR doesnt work for some reason
list=dir([MR.ParUMC.TWD,'/','*.lab']);
T=MRecon([MR.ParUMC.TWD,'/',list.name]);

% Perform the regular MRsense stuff
S=MRsense(srs,T,csc);
%clear srs T csc
S.Mask=0;
S.Smooth=1;
S.Extrapolate=1;
S.MatchTargetSize=1;
S.OutputSizeSensitivity=round(MR.Parameter.Gridder.OutputMatrixSize);
S.OutputSizeReformated=round(MR.Parameter.Gridder.OutputMatrixSize);
S.Perform;

% Save the coil maps after they are normalized
csm=flipud(S.Sensitivity);
if size(csm) > 3
    csm=flip(csm,3);
end
csm=csm/max(abs(csm(:)));

% Add noise to coil maps 0 points
b=rand(size(csm));
csm(~logical(abs(csm)))=b(~logical(abs(csm)));



MR.Parameter.Recon.Sensitivities=csm; % The actual sense maps
MR.ParUMC.Sense=SENSE(csm);

% Notification
fprintf('Finished [%.2f sec]\n',toc')

% END
end