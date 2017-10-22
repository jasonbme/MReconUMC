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

% Split reconstruction across dimension p
for n=1:numel(MR.Data)
res=zeros([MR.Parameter.Gridder.OutputMatrixSize{n}(1:3) MR.UMCParameters.AdjointReconstruction.IspaceSize{n}(4:end)]);
parfor_progress(MR.UMCParameters.AdjointReconstruction.KspaceSize{n}(MR.UMCParameters.IterativeReconstruction.SplitDimension));
for p=1:MR.UMCParameters.AdjointReconstruction.KspaceSize{n}(MR.UMCParameters.IterativeReconstruction.SplitDimension) % Loop over "partitions"
    
    % Initialize dcf operator
    MR.UMCParameters.Operators.W=DCF({sqrt(dynamic_indexing(MR.Parameter.Gridder.Weights{n},MR.UMCParameters.IterativeReconstruction.SplitDimension,p))});

    % Greengard nufft initialization
    nufft_greengard_init(MR,n,p);

    % Fessler nufft initialization
    nufft_fessler_init(MR,n,p);
    
    % Perform the adjoint-nufft + 2x DCF
    res_tmp=MR.UMCParameters.Operators.N'*(MR.UMCParameters.Operators.W*(MR.UMCParameters.Operators.W*dynamic_indexing(MR.Data{n},MR.UMCParameters.IterativeReconstruction.SplitDimension,p)));
    
    % Add to large matrix
    res=dynamic_indexing(res,MR.UMCParameters.IterativeReconstruction.SplitDimension,p,single(res_tmp{1}));

    % Track progress 
    parfor_progress;
end
MR.Data{n}=res;
end

%% Display and reconstruction flags
MR=set_gridding_flags(MR,1);
MR.Parameter.ReconFlags.isoversampled=[1,1,1];
if ~MR.UMCParameters.ReconFlags.NufftCsmMapping;fprintf('Finished [%.2f sec] \n',toc');end

% END
end