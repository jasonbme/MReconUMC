function MR = NUFFT(MR,varargin)
% Create operators and perform the NUFFT

switch lower(MR.UMCParameters.AdjointReconstruction.NUFFTMethod)
    case 'greengard'
        % Notifcation
        if nargin<2;fprintf('Initialize operators and do NUFFT (greengard) ....  ');tic;end
        MR=greengard_init(MR);
        
        % Do DCF
        MR.Data=MR.UMCParameters.AdjointReconstruction.DensityOperator*(...
            MR.UMCParameters.AdjointReconstruction.DensityOperator*MR.Data); % DCF is defined as square root for iterative recons
        
        % Do the gridding and set recon flags
        MR.Data=single(MR.UMCParameters.AdjointReconstruction.NUFFTOperator'*MR.Data);
        MR.Parameter.ReconFlags.isimspace=[1 1 1];
        MR=SetGriddingFlags(MR,1);
        MR.Parameter.ReconFlags.isoversampled=[1,1,0];
        
    case 'fessler'
        % Notifcation
        if nargin<2;fprintf('Initialize operators and do NUFFT (fessler) ......  ');tic;end
        MR=fessler_init(MR);
        
        % Do DCF
        MR.Data=MR.UMCParameters.AdjointReconstruction.DensityOperator*(...
            MR.UMCParameters.AdjointReconstruction.DensityOperator*MR.Data); % DCF is defined as square root for iterative recons
        
        % Do the gridding and set recon flags
        MR.Data=single(MR.UMCParameters.AdjointReconstruction.NUFFTOperator'*MR.Data);
        MR.Parameter.ReconFlags.isimspace=[1 1 1];
        MR=SetGriddingFlags(MR,1);
        MR.Parameter.ReconFlags.isoversampled=[1,1,0];

    case 'mrecon'
        % Notifcation
        if nargin<2;fprintf('Do NUFFT without operators (mrecon) ..............  ');tic;end
        
        % Perform different recon for uniform vs golden angle
        if MR.UMCParameters.AdjointReconstruction.Goldenangle==0
            MR.GridData;
            MR.RingingFilter;
            MR.ZeroFill;
            MR.K2I;
            MR.GridderNormalization;
        else
            MR=gaMRecon(MR);
        end
        
       if nargin<2;MR.Data=ifftshift(MR.Data,3);end % Temporarily fix, i dont know what goes wrong
        
end

% Notification
if nargin<2;fprintf('Finished [%.2f sec] \n',toc');end

% END
end