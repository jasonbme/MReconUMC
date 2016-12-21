function MR = greengard_init( MR )
%% Initialize the greengard nufft operator

% Dimensionality
Rdims=MR.UMCParameters.LinearReconstruction.IspaceSize;
Rdims(1:2)=round(MR.Parameter.Gridder.OutputMatrixSize(1:2));

% Make DCF operator
W=DCF(sqrt(MR.Parameter.Gridder.Weights));
MR.UMCParameters.LinearReconstruction.DensityOperator=W;

% Call gridder, parallize differently when you have just 1 dynamic
if size(MR.Data,5)>1
    G=GG(MR.Parameter.Gridder.Kpos,Rdims,MR.UMCParameters.GeneralComputing.NumberOfCPUs);
else
    G=GG(MR.Parameter.Gridder.Kpos,Rdims,0);
end
MR.UMCParameters.LinearReconstruction.NUFFTOperator=G;

% END
end