function AdjointReconstruction( MR )
%Perform only the adjoint operation (i.e. non-iterative reconstruction)
% - Nufft structures and dcf operators are initialized and applied.
% - Different handling when reconframe native gridder is selected.
% - dcf operator is performed twice since it is common practice to define
% it as the sqrt(dcf) for iterative reconstructions.
%
% 20170717 - T.Bruijnen

%% Logic & display
% If nufft is already performed during csm generation for single dynamic
% reconstructions we dont need to do it a second time.
% Or if you want an iterative reconstruction skip the function completely.
if MR.Parameter.ReconFlags.isgridded==1 || strcmpi(MR.UMCParameters.IterativeReconstruction.IterativeReconstruction,'yes')
    return;end

% Notifcation for display
if ~MR.UMCParameters.ReconFlags.NufftCsmMapping;fprintf(['Initialize operators and do NUFFT (',MR.UMCParameters.AdjointReconstruction.NufftSoftware(1:7),').......  ']);tic;end

%% Adjoint-reconstruction
% Reconframe gridder, this function skips the initialization part and immediately does the nufft.
% It will terminate AdjointReconstruction after its done.
if strcmpi(MR.UMCParameters.AdjointReconstruction.NufftSoftware,'reconframe')
    nufft_reconframe_perform( MR ); if ~MR.UMCParameters.ReconFlags.NufftCsmMapping;fprintf('Finished [%.2f sec] \n',toc');end
    return;end

% Initialize dcf operator
MR.UMCParameters.Operators.W=DCF(cellfun(@sqrt,MR.Parameter.Gridder.Weights,'UniformOutput',false));

% Greengard nufft initialization
nufft_greengard_init(MR);

% Fessler nufft initialization
nufft_fessler_init(MR);

% Perform the density compensation (dcf) (twice)
MR.Data=MR.UMCParameters.Operators.W*(MR.UMCParameters.Operators.W*MR.Data);

% Perform the adjoint-nufft
MR.Data=MR.UMCParameters.Operators.N'*MR.Data;

%% Display and reconstruction flags
MR=set_gridding_flags(MR,1);
MR.Parameter.ReconFlags.isoversampled=[1,1,1];
if ~MR.UMCParameters.ReconFlags.NufftCsmMapping;fprintf('Finished [%.2f sec] \n',toc');end

% END
end