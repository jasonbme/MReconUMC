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

% Iterate over all data chunks and partitions
for n=1:num_data % Loop over "data chunks"

    % Determine how to split the reconstructions, e.g. per slice or per dynamic
    for p=1:Kd{n}(MR.UMCParameters.IterativeReconstruction.JointReconstruction) % Loop over "partitions"

        % Initialize structure to send to the solver (MR.UMCParameters.Operators)
        lsqr_init(MR,n,p);

        % Feed structure to the solver
        MR.Data{n}=dynamic_indexing(MR.Data{n},MR.UMCParameters.IterativeReconstruction.JointReconstruction,...
            p,single(configure_regularized_iterative_sense(MR.UMCParameters.Operators)));

    end

end
    
% Notification
fprintf('Finished [%.2f sec] \n',toc')

% END
end
