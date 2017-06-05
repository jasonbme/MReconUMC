function csm = mrsense( MR )
% Estimate coil sensitivity maps from prescan

% Logic
if ~strcmpi(MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps,'refscan')
	return;end

% Get locations of CSC/SRS 
listCSC=dir([MR.UMCParameters.GeneralComputing.DataRoot,'/CSC/','*.lab']);
locCSC=[MR.UMCParameters.GeneralComputing.DataRoot,'/CSC/',listCSC.name];
listSRS=dir([MR.UMCParameters.GeneralComputing.DataRoot,'/SRS/','*.lab']);
locSRS=[MR.UMCParameters.GeneralComputing.DataRoot,'/SRS/',listSRS.name];

% Load in the MRecon objects of them
srs=MRecon(locSRS);
csc=MRecon(locCSC);

% Reload original data, because MR doesnt work for some reason
list=dir([MR.UMCParameters.GeneralComputing.TemporateWorkingDirectory,'/','*.lab']);
T=MRecon([MR.UMCParameters.GeneralComputing.TemporateWorkingDirectory,'/',list.name]);

% Perform the regular MRsense stuff
S=MRsense(srs,T,csc);
%clear srs T csc
S.Mask=1;
S.Smooth=1;
S.Extrapolate=1;
S.MatchTargetSize=1;
S.OutputSizeSensitivity=[round(MR.Parameter.Gridder.OutputMatrixSize),1];
S.OutputSizeReformated=[round(MR.Parameter.Gridder.OutputMatrixSize),1];
S.Perform;

% Save the coil maps after they are normalized
csm=flipud(S.Sensitivity);
if size(csm) > 3
    csm=flip(csm,3);
end
csm=csm/max(abs(csm(:)));

% Add noise to coil maps 0 points
b=rand(size(csm));
csm(~logical(abs(csm)))=single(b(~logical(abs(csm))));

% END
end