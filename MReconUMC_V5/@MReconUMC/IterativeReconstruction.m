function IterativeReconstruction( MR )
%Perform iterative reconstruction with either the matlab (lsqr)
% or nonlinear conjugate gradient routine. Similar to the function from
% Miki Lustigs website. This routine creates a structure in MR.UMCParameters.
% Operators which includes the nufft, sensitivity, density and various
% sparsity transform operators. This structure is then fed to the iterative
% solvers.
%
% 20170717 - T.Bruijnen

%% Logic & display
if strcmpi(MR.UMCParameters.IterativeReconstruction.IterativeReconstruction,'no')
    return;
end

fprintf('Iterative reconstruction..........................  ');tic;

%% Iterative Reconstruction
% Get dimensions for data handling in short parameters
num_data=numel(MR.Data);
Kd=MR.UMCParameters.AdjointReconstruction.KspaceSize; 
Id=MR.Parameter.Gridder.OutputMatrixSize;

% Iterate over all data chunks and partitions
for n=1:num_data % Loop over "data chunks"
    
    % Preallocate memory for res
    res=zeros([Id{n}(1:3) 1 Id{n}(5:12)]);
    
    % Track progress
    parfor_progress(Kd{n}(MR.UMCParameters.IterativeReconstruction.SplitDimension));
    
    % Determine how to split the reconstructions, e.g. per slice or per dynamic
    for p=1:Kd{n}(MR.UMCParameters.IterativeReconstruction.SplitDimension) % Loop over "partitions"
        % Initialize lsqr/nlcg structure to send to the solver 
        lsqr_init(MR,n,p);
        nlcg_init(MR,n,p);

        % Feed structure to the lsqr solver if potential function is l1
        if MR.UMCParameters.IterativeReconstruction.PotentialFunction==1
            [res_tmp,MR.UMCParameters.Operators.Residual(:,n,p)]=configure_compressed_sensing(MR.UMCParameters.Operators);end
            
        % Feed structure to the lsqr solver if potential function is quadratic
        if MR.UMCParameters.IterativeReconstruction.PotentialFunction==2
            [res_tmp,MR.UMCParameters.Operators.Residual(:,n,p)]=configure_regularized_iterative_sense(MR.UMCParameters.Operators);end
            
        % Allocate to adequate part of the matrix
        res=dynamic_indexing(res,MR.UMCParameters.IterativeReconstruction.SplitDimension,p,single(res_tmp));

        % Track progress 
        parfor_progress;
        
    end
    
    % Replace mr data with the result
    MR.Data{n}=res;clear res
    
end

%% Display and reconstruction flags
% Reset progress tracker
parfor_progress(0);

% Correctly set reconstruction flags
MR.Parameter.ReconFlags.iscombined=1;
MR=set_gridding_flags(MR,1);
MR.Parameter.ReconFlags.isoversampled=[1,1,1];
    
% Notification
fprintf('Finished [%.2f sec] \n',toc')

% END
end
