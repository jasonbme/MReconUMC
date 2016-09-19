function MRSenseUMC( MR )
%% Estimate coil sensitivity maps from prescan
% Notification
fprintf('Estimate coil maps from prescan (MRsense).........  ');tic;

% Get locations of CSC/SRS 
listCSC=dir([MR.UMCParameters.TemporateWorkingDirectory,'/CSC/','*.lab']);
locCSC=[MR.UMCParameters.TemporateWorkingDirectory,'/CSC/',listCSC.name];
listSRS=dir([MR.UMCParameters.TemporateWorkingDirectory,'/SRS/','*.lab']);
locSRS=[MR.UMCParameters.TemporateWorkingDirectory,'/SRS/',listSRS.name];

% Load in the MRecon objects of them
srs=MRecon(locSRS);
csc=MRecon(locCSC);

% Reload original data, because MR doesnt work for some reason
list=dir([MR.UMCParameters.TemporateWorkingDirectory,'/','*.lab']);
T=MRecon([MR.UMCParameters.TemporateWorkingDirectory,'/',list.name]);

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

% Save maps and operator
MR.Parameter.Recon.Sensitivities=csm; 
MR.UMCParameters.LinearReconstruction.CombineCoilsOperator=CC(csm);

% Notification
fprintf('Finished [%.2f sec]\n',toc')

% END
end