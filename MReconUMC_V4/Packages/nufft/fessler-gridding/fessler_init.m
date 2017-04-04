function MR = fessler_init( MR )
%% Initialize the greengard nufft operator

% Dimensionality
Rdims=MR.UMCParameters.AdjointReconstruction.IspaceSize;
Rdims(1:2)=MR.Parameter.Gridder.OutputMatrixSize(1:2);

% If DCF is empty, fill with ones e.g. EPI
if isempty(MR.Parameter.Gridder.Weights)
    MR.Parameter.Gridder.Weights=ones(size(MR.Parameter.Gridder.Kpos));
end

% Make DCF operator
W=DCF(sqrt(MR.Parameter.Gridder.Weights));
MR.UMCParameters.AdjointReconstruction.DensityOperator=W;

% Make NUFFT operator
G=FG(MR.Parameter.Gridder.Kpos, 1, 1, [0,0], Rdims(1:2), 2); % /2 to normalize to -.5 to .5.
MR.UMCParameters.AdjointReconstruction.NUFFTOperator=G;

% END
end