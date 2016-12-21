function MR = fessler_init( MR )
%% Initialize the greengard nufft operator

% Dimensionality
Rdims=MR.UMCParameters.LinearReconstruction.IspaceSize;
Rdims(1:2)=round(MR.Parameter.Gridder.OutputMatrixSize(1:2));

% Make DCF operator
W=DCF(sqrt(MR.Parameter.Gridder.Weights));
MR.UMCParameters.LinearReconstruction.DensityOperator=W;

% Make NUFFT operator
G=FG(MR.Parameter.Gridder.Kpos, 1, 1, [0,0], Rdims(1:2), 2); % /2 to normalize to -.5 to .5.
MR.UMCParameters.LinearReconstruction.NUFFTOperator=G;

% END
end