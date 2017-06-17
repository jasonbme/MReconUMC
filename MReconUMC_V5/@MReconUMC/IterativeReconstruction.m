function IterativeReconstruction( MR )
% Perform iterative reconstruction with either least square or conjugate gradient methods
% Strategy. MR.UMCParameters.Operators will be used to feed in the algorithms.
% 1) Loop over all data chunks
% 2) Determine how to split the reconstruction, e.g. per slice or per dynamic or jointly
% 3) Determine what kind of reconstruction to perform, e.g. select lsqr function handle
% 4) Loop over all partitions
% 5) Configure Operator struct for the current data chunk and partition
% 6) Feed data into LSQR
% 7) Provide feedback
% 8) Back to 1)

% logic
if strcmpi(MR.UMCParameters.IterativeReconstruction.IterativeReconstruction,'no')
    return;
end

% Perform iterative reconstruction
fprintf('Iterative reconstruction..........................  ');tic;

% Get dimensions for data handling
num_data=numel(MR.Data);
Kd=MR.UMCParameters.AdjointReconstruction.KspaceSize;
Id=MR.UMCParameters.AdjointReconstruction.IspaceSize;

% Iterate over all data chunks and partitions
for n=1:num_data % Loop over "data chunks"

    % Preallocate memory for res
    res=zeros([MR.Parameter.Gridder.OutputMatrixSize{n}(1:3) 1 Id{n}(5:12)]);
    
    % Track progress
    parfor_progress(Kd{n}(MR.UMCParameters.IterativeReconstruction.JointReconstruction));
    
    % Determine how to split the reconstructions, e.g. per slice or per dynamic
    %for p=1:Kd{n}(MR.UMCParameters.IterativeReconstruction.JointReconstruction) % Loop over "partitions"
    for p=20:20
        % Initialize lsqr/nlcg structure to send to the solver 
        lsqr_init(MR,n,p);
        nlcg_init(MR,n,p);

        % Feed structure to the lsqr solver if potential function is l1
        if MR.UMCParameters.IterativeReconstruction.Potential_function==1
            [res_tmp,MR.UMCParameters.Operators.Residual(:,n,p)]=configure_compressed_sensing(MR.UMCParameters.Operators);end
            
        % Feed structure to the lsqr solver if potential function is quadratic
        if MR.UMCParameters.IterativeReconstruction.Potential_function==2
            [res_tmp,MR.UMCParameters.Operators.Residual(:,n,p)]=configure_regularized_iterative_sense(MR.UMCParameters.Operators);end
            
        % Allocate to adequate part of the matrix
        res=dynamic_indexing(res,MR.UMCParameters.IterativeReconstruction.JointReconstruction,p,single(res_tmp));

        % Track progress 
        parfor_progress;
        
    end
    
    % Replace mr data with the result
    MR.Data{n}=res;clear res
    
end

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
