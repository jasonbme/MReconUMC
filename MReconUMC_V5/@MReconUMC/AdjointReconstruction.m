function AdjointReconstruction( MR )
% Create operators and perform the NUFFT

% Logic if nufft is already performed during csm generation for single dynamic reconstructions
if MR.Parameter.ReconFlags.isgridded==1 || strcmpi(MR.UMCParameters.IterativeReconstruction.IterativeReconstruction,'yes')
    return;end

% Notifcation
if ~MR.UMCParameters.ReconFlags.nufft_csmapping;fprintf(['Initialize operators and do NUFFT (',MR.UMCParameters.AdjointReconstruction.NUFFTMethod,') ....  ']);tic;end

% MRecon nufft, only tested for 2D sofar
if strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'mrecon')
    mrecon_nufft(MR); if ~MR.UMCParameters.ReconFlags.nufft_csmapping;fprintf('Finished [%.2f sec] \n',toc');end
    return;end

% Greengard nufft initialization
nufft_greengard_init(MR);

% Fessler nufft initialization
nufft_fessler_init(MR);

% Do DCF
MR.Data=MR.UMCParameters.Operators.W*(...
    MR.UMCParameters.Operators.W*MR.Data); % DCF is defined as square root for iterative recons, thats why I do it twice

% Do the gridding and set recon flags
MR.Data=MR.UMCParameters.Operators.N'*MR.Data;
MR=set_gridding_flags(MR,1);
MR.Parameter.ReconFlags.isoversampled=[1,1,1];

% Notification only important for fprintf statements
if ~MR.UMCParameters.ReconFlags.nufft_csmapping;fprintf('Finished [%.2f sec] \n',toc');end

% END
end