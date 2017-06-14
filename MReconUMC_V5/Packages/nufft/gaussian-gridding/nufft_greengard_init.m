function nufft_greengard_init( MR )
%% Initialize the greengard nufft operator

% Logic
if ~strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'greengard')
	return;end

% Get dimensions for data handling
num_data=numel(MR.Data);
for n=1:num_data;MR.UMCParameters.AdjointReconstruction.IspaceSize{n}(1:3)=MR.Parameter.Gridder.OutputMatrixSize{n}(1:3);end

% If DCF is empty, fill with ones
if isempty(MR.Parameter.Gridder.Weights)
    MR.Parameter.Gridder.Weights={ones(size(MR.Parameter.Gridder.Kpos))};
end

% Make DCF operator
W=DCF(cellfun(@sqrt,MR.Parameter.Gridder.Weights,'UniformOutput',false));
MR.UMCParameters.Operators.W=W;

% Decide which nufft class to call, 3D, 2D or 2D per slice
% Call gridder differently when parall computing is enabled
if strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTtype,'2D')
    MR.UMCParameters.Operators.N=GG2D(MR.Parameter.Gridder.Kpos,MR.UMCParameters.AdjointReconstruction.IspaceSize,...
        MR.UMCParameters.AdjointReconstruction.KspaceSize,MR.UMCParameters.ReconFlags.Verbose,MR.UMCParameters.GeneralComputing.ParallelComputing);
elseif strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTtype,'3D')
    MR.UMCParameters.Operators.N=GG3D(MR.Parameter.Gridder.Kpos,MR.UMCParameters.AdjointReconstruction.IspaceSize,...
        MR.UMCParameters.AdjointReconstruction.KspaceSize,MR.UMCParameters.ReconFlags.Verbose,MR.UMCParameters.GeneralComputing.ParallelComputing);
end

% END
end