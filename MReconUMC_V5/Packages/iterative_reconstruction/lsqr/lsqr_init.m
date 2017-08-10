function lsqr_init(MR,n,p)
% Generate a structure to feed in the lsqr functions

% Logic
if ~(MR.UMCParameters.IterativeReconstruction.PotentialFunction==2)
    return;end

% Dimension to iterate over (partition dimension)
it_dim=MR.UMCParameters.IterativeReconstruction.SplitDimension; % Readabillity

% Store Id and Kd and change iteration dimensions to 1
MR.UMCParameters.Operators.Id=MR.Parameter.Gridder.OutputMatrixSize{n};
MR.UMCParameters.Operators.Id(it_dim)=1;
MR.UMCParameters.Operators.Kd=MR.UMCParameters.AdjointReconstruction.KspaceSize{n};
MR.UMCParameters.Operators.Kd(it_dim)=1;

% Create density operator
MR.UMCParameters.Operators.W=DCF({sqrt(dynamic_indexing(MR.Parameter.Gridder.Weights{n},it_dim,p))});

% Create nufft operator which can be 2D/3D and fessler or greengard code, hence the logic
if strcmpi(MR.UMCParameters.AdjointReconstruction.NufftSoftware,'greengard');
if strcmpi(MR.UMCParameters.AdjointReconstruction.NufftType,'2D')
    MR.UMCParameters.Operators.N=GG2D({dynamic_indexing(MR.Parameter.Gridder.Kpos{n},it_dim+1,p)},...
    	{MR.UMCParameters.Operators.Id},{MR.UMCParameters.Operators.Kd},0,MR.UMCParameters.GeneralComputing.ParallelComputing);
else
    MR.UMCParameters.Operators.N=GG3D({dynamic_indexing(MR.Parameter.Gridder.Kpos{n},it_dim+1,p)},...
    	{MR.UMCParameters.Operators.Id},{MR.UMCParameters.Operators.Kd},0,MR.UMCParameters.GeneralComputing.ParallelComputing);
end;end

if strcmpi(MR.UMCParameters.AdjointReconstruction.NufftSoftware,'fessler')
if strcmpi(MR.UMCParameters.AdjointReconstruction.NufftType,'2D')
    MR.UMCParameters.Operators.N=FG2D({dynamic_indexing(MR.Parameter.Gridder.Kpos{n},it_dim+1,p)},...
    	{MR.UMCParameters.Operators.Id},{MR.UMCParameters.Operators.Kd},0,MR.UMCParameters.GeneralComputing.ParallelComputing); 
else
    MR.UMCParameters.Operators.N=FG3D({dynamic_indexing(MR.Parameter.Gridder.Kpos{n},it_dim+1,p)},...
		{MR.UMCParameters.Operators.Id},{MR.UMCParameters.Operators.Kd},0,MR.UMCParameters.GeneralComputing.ParallelComputing); 
end;end

% Create sense operator
MR.UMCParameters.Operators.S=CC(dynamic_indexing(MR.Parameter.Recon.Sensitivities,it_dim,p));

% Create Total variation operator if enabled, else use identity for tikhonov (sparse matrix)
MR.UMCParameters.Operators.TV=unified_TV(MR.UMCParameters.Operators.Id,MR.UMCParameters.IterativeReconstruction.TVDimension{n},...
    MR.UMCParameters.IterativeReconstruction.TVLambda{n});

% Allocate raw k-space data
MR.UMCParameters.Operators.y=cell2mat(MR.UMCParameters.Operators.W*double(dynamic_indexing(MR.Data{n},it_dim,p)));

% Verbose option
MR.UMCParameters.Operators.Verbose=MR.UMCParameters.ReconFlags.Verbose;

% END
end