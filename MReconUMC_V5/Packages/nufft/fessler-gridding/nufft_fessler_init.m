function nufft_fessler_init( MR )
%% Initialize the greengard nufft operator

% Logic
if ~strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'fessler')
	return;end

% Get dimensions for data handling
num_data=numel(MR.Data);
for n=1:num_data;MR.UMCParameters.AdjointReconstruction.IspaceSize{n}(1:3)=MR.Parameter.Gridder.OutputMatrixSize{n}(1:3);end

% If DCF is empty, fill with ones e.g. EPI
if isempty(MR.Parameter.Gridder.Weights)
    MR.Parameter.Gridder.Weights={ones(size(MR.Parameter.Gridder.Kpos))};
end

% Make DCF operator
W=DCF(cellfun(@sqrt,MR.Parameter.Gridder.Weights,'UniformOutput',false));
MR.UMCParameters.Operators.W=W;

% Make NUFFT operator
if strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTtype,'2D')
    MR.UMCParameters.Operators.N=FG2D(MR.Parameter.Gridder.Kpos,MR.UMCParameters.AdjointReconstruction.IspaceSize,MR.UMCParameters.AdjointReconstruction.KspaceSize,...
        MR.UMCParameters.ReconFlags.Verbose,MR.UMCParameters.GeneralComputing.ParallelComputing); 
elseif strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTtype,'3D')
    MR.UMCParameters.Operators.N=FG3D(MR.Parameter.Gridder.Kpos,MR.UMCParameters.AdjointReconstruction.IspaceSize,MR.UMCParameters.AdjointReconstruction.KspaceSize,...
        MR.UMCParameters.ReconFlags.Verbose,MR.UMCParameters.GeneralComputing.ParallelComputing); 
end

% END
end