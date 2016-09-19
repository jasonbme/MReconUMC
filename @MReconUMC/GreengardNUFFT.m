function GreengardNUFFT( MR )
%% Initialize the greengard nufft operator

% Dimensionality
Rdims=MR.UMCParameters.LinearReconstruction.IspaceSize;
Rdims(1:2)=MR.Parameter.Gridder.OutputMatrixSize;

% Make DCF operator
W=DCF(sqrt(MR.Parameter.Gridder.Weights));
MR.UMCParameters.LinearReconstruction.DensityOperator=W;

% Apply DCF
MR.Data=W*(W*MR.Data);

% Call gridder per coil per dynamic
G=GG(MR.Parameter.Gridder.Kpos,Rdims,MR.UMCParameters.GeneralComputing.NumberOfCPUs);
MR.UMCParameters.LinearReconstruction.NUFFTOperator=G;

% Do the gridding and convert to single for MRecon
MR.Data=single(G'*MR.Data);
MR.Parameter.ReconFlags.isimspace=[1 1 1];

% Combine coils etc.
MR.CombineCoils;
MR.GeometryCorrection;
MR=SetGriddingFlags(MR,1);
MR.Parameter.ReconFlags.isoversampled=[1,1,0];

% END
end