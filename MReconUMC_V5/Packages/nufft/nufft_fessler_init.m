function nufft_fessler_init( MR )
%% Initialize the greengard nufft operator

% Logic
if ~strcmpi(MR.UMCParameters.AdjointReconstruction.NufftSoftware,'fessler')
	return;end

% Get dimensions for data handling
num_data=numel(MR.Data);

% If dcf is empty, fill with ones e.g. EPI
if isempty(MR.Parameter.Gridder.Weights)
    MR.Parameter.Gridder.Weights={ones(size(MR.Parameter.Gridder.Kpos))};
end

% Make DCF operator
W=DCF(cellfun(@sqrt,MR.Parameter.Gridder.Weights,'UniformOutput',false));
MR.UMCParameters.Operators.W=W;

% Make NUFFT operator
if strcmpi(MR.UMCParameters.AdjointReconstruction.NufftType,'2D')
    MR.UMCParameters.Operators.N=FG2D(MR.Parameter.Gridder.Kpos,MR.UMCParameters.AdjointReconstruction.IspaceSize,MR.UMCParameters.AdjointReconstruction.KspaceSize,...
        MR.UMCParameters.ReconFlags.Verbose,MR.UMCParameters.GeneralComputing.ParallelComputing); 
elseif strcmpi(MR.UMCParameters.AdjointReconstruction.NufftType,'3D')
    MR.UMCParameters.Operators.N=FG3D(MR.Parameter.Gridder.Kpos,MR.UMCParameters.AdjointReconstruction.IspaceSize,MR.UMCParameters.AdjointReconstruction.KspaceSize,...
        MR.UMCParameters.ReconFlags.Verbose,MR.UMCParameters.GeneralComputing.ParallelComputing); 
end

% END
end