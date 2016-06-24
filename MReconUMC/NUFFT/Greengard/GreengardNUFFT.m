function GreengardNUFFT( MR )
% 20160615 - GGNUFFT Non-uniform fourier transform 2D
% Different weights/kpos are computed to match the properties required for
% the Fessler gridding. Function calls the original Fortran code. 
% http://www.cims.nyu.edu/cmcl/nufft/nufft.html

% Dimensionality
dims=size(MR.Data);
Rdims=MR.Parameter.Gridder.OutputMatrixSize;
Kdims=[dims(1) dims(2)];

% Get own trajectory
MR.Parameter.Gridder.Kpos=-1*RadialTrajectory(MR)*MR.Parameter.Gridder.GridOvsFactor*(1/MR.ParUMC.ReconRatio);

% Get own dcf
MR.Parameter.Gridder.Weights=DensityCompensation(MR);

% Make DCF operator
W=WW(sqrt(MR.Parameter.Gridder.Weights));
MR.ParUMC.W=W;

% Apply DCF
MR.Data=W*(W*MR.Data);

% Make values a bit smaller to get normal cost functions
MR.Data=1000*MR.Data/norm(MR.Data(:),1);

% Save raw data for CS
if strcmp(MR.ParUMC.CS,'yes')
    MR.ParUMC.Rawdata=MR.Data;
end

% Call gridder per coil per dynamic
G=GG(MR.Parameter.Gridder.Kpos,Rdims,Kdims);
MR.ParUMC.NUFFT=G;

% Do the gridding and convert to single for MRecon
MR.Data=single(G'*MR.Data);
MR.Parameter.ReconFlags.isimspace=[1 1 1];

% Combine coils etc.
MR.CombineCoils;
MR.GeometryCorrection;
MR.RemoveOversampling;
MR=SetGriddingFlags(MR,1);

% END
end