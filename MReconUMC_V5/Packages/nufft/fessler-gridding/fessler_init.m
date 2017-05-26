function MR = fessler_init( MR )
%% Initialize the greengard nufft operator

% Get dimensions for data handling
num_data=numel(MR.Data);
for n=1:num_data;MR.UMCParameters.AdjointReconstruction.IspaceSize{n}(1:3)=MR.Parameter.Gridder.OutputMatrixSize{n}(1:3);end

% If DCF is empty, fill with ones e.g. EPI
if isempty(MR.Parameter.Gridder.Weights)
    MR.Parameter.Gridder.Weights={ones(size(MR.Parameter.Gridder.Kpos))};
end

% Make DCF operator
W=DCF(cellfun(@sqrt,MR.Parameter.Gridder.Weights,'UniformOutput',false));
MR.UMCParameters.AdjointReconstruction.DensityOperator=W;

% Make NUFFT operator
if strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTtype,'2D')
    MR.UMCParameters.AdjointReconstruction.NUFFTOperator=FG2D(MR.Parameter.Gridder.Kpos,MR.UMCParameters.AdjointReconstruction.IspaceSize,MR.UMCParameters.AdjointReconstruction.KspaceSize); % /2 to normalize to -.5 to .5.
elseif strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTtype,'3D')
    MR.UMCParameters.AdjointReconstruction.NUFFTOperator=FG3D(MR.Parameter.Gridder.Kpos,MR.UMCParameters.AdjointReconstruction.IspaceSize,MR.UMCParameters.AdjointReconstruction.KspaceSize); % /2 to normalize to -.5 to .5.
end

% END
end