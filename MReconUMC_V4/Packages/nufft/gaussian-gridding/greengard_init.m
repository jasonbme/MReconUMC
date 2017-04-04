function MR = greengard_init( MR )
%% Initialize the greengard nufft operator

% Dimensionality
Rdims=MR.UMCParameters.AdjointReconstruction.IspaceSize;
Rdims(1:2)=MR.Parameter.Gridder.OutputMatrixSize(1:2);

% If DCF is empty, fill with ones
if isempty(MR.Parameter.Gridder.Weights)
    MR.Parameter.Gridder.Weights=ones(size(MR.Parameter.Gridder.Kpos));
end

% Make DCF operator
W=DCF(sqrt(MR.Parameter.Gridder.Weights));
MR.UMCParameters.AdjointReconstruction.DensityOperator=W;

% Call gridder differently when parall computing is enabled
if strcmpi(MR.UMCParameters.GeneralComputing.ParallelComputing,'no')
    G=GG(MR.Parameter.Gridder.Kpos,Rdims,0);
else
    G=GG(MR.Parameter.Gridder.Kpos,Rdims,MR.UMCParameters.GeneralComputing.NumberOfCPUs);
end

% Assign operator
MR.UMCParameters.AdjointReconstruction.NUFFTOperator=G;

% END
end