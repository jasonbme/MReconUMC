function CoilSensitivityMaps( MR )
% Estimate coil sensitivity maps 

% Check whether coils maps are available in the folder
cd(MR.UMCParameters.GeneralComputing.TemporateWorkingDirectory)

% If coil maps are in directory load them and return
if (strcmpi(MR.UMCParameters.AdjointReconstruction.LoadCoilSensitivityMaps,'yes') && exist('csm.mat')==2)
    
    % Notification
    fprintf('Load coil maps from directory ....................  ');tic;
    load('csm.mat');
    MR.Parameter.Recon.Sensitivities=csm;
    
    % Create coil combine operator
    MR.UMCParameters.AdjointReconstruction.CombineCoilsOperator=CC(MR.Parameter.Recon.Sensitivities);
    cd(MR.UMCParameters.GeneralComputing.PermanentWorkingDirectory)
    
    % Notification
    fprintf('Finished [%.2f sec]\n',toc')
    return
end

switch MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps
    case 'espirit'
        % Notification
        fprintf('Estimate coil maps (espirit)......................  ');tic;

        % Store raw data and nufft settings, because we need to reconstruct a single
        % dynamic to estimate the csms from, thus different gridding settings.
        store={MR.Data,MR.Parameter.Encoding.NrDyn,MR.UMCParameters.AdjointReconstruction.NUFFTMethod,...
            MR.Parameter.Recon.CoilCombination,MR.Parameter.Gridder.Weights...
            ,MR.Parameter.Gridder.Kpos,MR.UMCParameters.AdjointReconstruction.IspaceSize,MR.Parameter.Scan.Samples};

        % Set different nufft settings
        [ns,nl,nz,nc,ndyn]=size(MR.Data);
        MR.Parameter.Recon.CoilCombination='no';
        MR.Parameter.Encoding.NrDyn=1;
        MR.Data=permute(reshape(permute(MR.Data,[1 3 4 2 5]),[ns nz nc nl*ndyn 1]),[1 4 2 3 5]);
        MR.UMCParameters.AdjointReconstruction.IspaceSize(2)=[nl*ndyn];
        MR.UMCParameters.AdjointReconstruction.IspaceSize(5)=[1];
        
        % Some exceptions for the 'mrecon' gridder
        if ~strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'mrecon');MR.Parameter.Gridder.Weights=...
                permute(reshape(permute(MR.Parameter.Gridder.Weights,[1 2 5 3 4]),[ns nl*ndyn 1 1 1]),[1 2 4 3 5]);...
                MR.Parameter.Gridder.Kpos=permute(reshape(permute(MR.Parameter.Gridder.Kpos,[1 2 5 3 4]),...
                [ns nl*ndyn 1 1 1]),[1 2 4 3 5]);end
        if strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'mrecon');MR.Parameter.Scan.Samples=[ns nl nz];end    

        % Do the NUFFT
        MR=NUFFT(MR,'flag'); % Flag is for fprintf notifications

        % Get CSMs and create operator
        MR.Parameter.Recon.Sensitivities=espirit(MR.Data);
        MR.UMCParameters.AdjointReconstruction.CombineCoilsOperator=CC(MR.Parameter.Recon.Sensitivities);

        % Save coil maps to directory
        cd(MR.UMCParameters.GeneralComputing.TemporateWorkingDirectory)
        csm=MR.Parameter.Recon.Sensitivities;save csm csm
        cd(MR.UMCParameters.GeneralComputing.PermanentWorkingDirectory)

       % Restore settings
        [MR.Data,MR.Parameter.Encoding.NrDyn,MR.UMCParameters.AdjointReconstruction.NUFFTMethod,...
            MR.Parameter.Recon.CoilCombination,MR.Parameter.Gridder.Weights...
            ,MR.Parameter.Gridder.Kpos,MR.UMCParameters.AdjointReconstruction.IspaceSize,MR.Parameter.Scan.Samples]=store{:};
        MR=SetGriddingFlags(MR,0);

    case 'openadapt'
        % Notification
        fprintf('Estimate coil maps (openadapt)....................  ');tic;

        % Store raw data and nufft settings, because we need to reconstruct a single
        % dynamic to estimate the csms from, thus different gridding settings.
        store={MR.Data,MR.Parameter.Encoding.NrDyn,MR.UMCParameters.AdjointReconstruction.NUFFTMethod,...
            MR.Parameter.Recon.CoilCombination,MR.Parameter.Gridder.Weights...
            ,MR.Parameter.Gridder.Kpos,MR.UMCParameters.AdjointReconstruction.IspaceSize,MR.Parameter.Scan.Samples};

        % Set different nufft settings, do stuff slightly differently if
        % you want to grid with reconframe (mrecon).
        [ns,nl,nz,nc,ndyn]=size(MR.Data);
        MR.Parameter.Recon.CoilCombination='no';
        MR.Parameter.Encoding.NrDyn=1;
        MR.Data=permute(reshape(permute(MR.Data,[1 3 4 2 5]),[ns nz nc nl*ndyn 1]),[1 4 2 3 5]);
        MR.UMCParameters.AdjointReconstruction.IspaceSize(2)=[nl*ndyn];
        MR.UMCParameters.AdjointReconstruction.IspaceSize(5)=[1];
        
        % Some exceptions for the 'mrecon' gridder
        if ~strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'mrecon');MR.Parameter.Gridder.Weights=...
                permute(reshape(permute(MR.Parameter.Gridder.Weights,[1 2 5 3 4]),[ns nl*ndyn 1 1 1]),[1 2 4 3 5]);end
        if ~strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'mrecon');MR.Parameter.Gridder.Kpos=...
                permute(reshape(permute(MR.Parameter.Gridder.Kpos,[1 2 5 3 4]),[ns nl*ndyn 1 1 1]),[1 2 4 3 5]);end
        if strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'mrecon');MR.Parameter.Scan.Samples=[ns nl nz];end        
        
        % Do the NUFFT
        MR=NUFFT(MR,'flag');

        % Get CSMs and create operator
        [~,MR.Parameter.Recon.Sensitivities]=openadapt(permute(MR.Data,[4 1 2 3]));
        MR.Parameter.Recon.Sensitivities=permute(MR.Parameter.Recon.Sensitivities,[2 3 4 1]);
        MR.UMCParameters.AdjointReconstruction.CombineCoilsOperator=CC(MR.Parameter.Recon.Sensitivities);

        % Save coil maps to directory
        cd(MR.UMCParameters.GeneralComputing.TemporateWorkingDirectory)
        csm=MR.Parameter.Recon.Sensitivities;save csm csm
        cd(MR.UMCParameters.GeneralComputing.PermanentWorkingDirectory)

        % Restore settings
        [MR.Data,MR.Parameter.Encoding.NrDyn,MR.UMCParameters.AdjointReconstruction.NUFFTMethod,...
            MR.Parameter.Recon.CoilCombination,MR.Parameter.Gridder.Weights...
            ,MR.Parameter.Gridder.Kpos,MR.UMCParameters.AdjointReconstruction.IspaceSize,MR.Parameter.Scan.Samples]=store{:};
        MR=SetGriddingFlags(MR,0);

    case 'refscan'
     % Notification
     fprintf('Estimate coil maps (MRSense)......................  ');tic;

     % Get CSMs and create operator
     MR.Parameter.Recon.Sensitivities=mrsense(MR);
     MR.UMCParameters.AdjointReconstruction.CombineCoilsOperator=CC(MR.Parameter.Recon.Sensitivities);

     % Save coil maps to directory
     cd(MR.UMCParameters.GeneralComputing.TemporateWorkingDirectory)
     csm=MR.Parameter.Recon.Sensitivities;
     save csm csm
     
    case 'no'
     % Notification
     fprintf('No coil maps used ................................  ');tic;
end

% Return to main directory
cd(MR.UMCParameters.GeneralComputing.PermanentWorkingDirectory)

% Notification
fprintf('Finished [%.2f sec]\n',toc')

% END
end