function nufft_greengard_init( MR,n,p )
%% Initialize the greengard nufft operator

% Logic
if ~strcmpi(MR.UMCParameters.AdjointReconstruction.NufftSoftware,'greengard')
	return;end

% Dimension to iterate over (partition dimension)
it_dim=MR.UMCParameters.IterativeReconstruction.SplitDimension; % Readabillity

% Store Id and Kd and change iteration dimensions to 1
Id=MR.Parameter.Gridder.OutputMatrixSize{n};
Id(it_dim)=1;
Kd=MR.UMCParameters.AdjointReconstruction.KspaceSize{n};
Kd(it_dim)=1;

% Decide which nufft class to call, 3D, 2D or 2D per slice
% Call gridder differently when parall computing is enabled
if strcmpi(MR.UMCParameters.AdjointReconstruction.NufftType,'2D')
    MR.UMCParameters.Operators.N=GG2D({dynamic_indexing(MR.Parameter.Gridder.Kpos{n},it_dim+1,p)},...
    	{Id},{Kd},0,MR.UMCParameters.GeneralComputing.ParallelComputing);
elseif strcmpi(MR.UMCParameters.AdjointReconstruction.NufftType,'3D')
    MR.UMCParameters.Operators.N=GG3D({dynamic_indexing(MR.Parameter.Gridder.Kpos{n},it_dim+1,p)},...
    	{Id},{Kd},0,MR.UMCParameters.GeneralComputing.ParallelComputing);
end

% END
end