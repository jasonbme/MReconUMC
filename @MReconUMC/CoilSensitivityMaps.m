function CoilSensitivityMaps( MR )
%% Estimate coil sensitivity maps 
% dynamics from all the data, for simplicity this is always done by the 
% mrecon gridder. Subsequentially applying ESPIRiT to acquire the coil
% maps. Alternatively estimate the maps via sense ref scans.

%% Autocalibrate
if strcmpi(MR.UMCParameters.LinearReconstruction.Autocalibrate,'yes')

    % Check whether coils maps are available in the folder
    cd(MR.UMCParameters.GeneralComputing.TemporateWorkingDirectory)
    
    if exist('csmac.mat')==2
        % Notification
        fprintf('Load coil maps from directory (autocalibrate).....  ');tic;
        load('csmac.mat')
        MR.Parameter.Recon.Sensitivities=csmac;
        MR.UMCParameters.LinearReconstruction.CombineCoilsOperator=CC(MR.Parameter.Recon.Sensitivities);
        cd(MR.UMCParameters.GeneralComputing.PermanentWorkingDirectory)
    else
        % Notification
        fprintf('Estimate coil maps (autocalibrate)................  ');tic;

        % Store raw data and nufft settings, because we need to reconstruct a single
        % dynamic to estimate the csms from, thus different gridding settings.
        store={MR.Data,MR.Parameter.Encoding.NrDyn,MR.UMCParameters.LinearReconstruction.NUFFTMethod,...
            MR.UMCParameters.LinearReconstruction.CombineCoils,MR.Parameter.Gridder.Weights...
            ,MR.Parameter.Gridder.Kpos,MR.UMCParameters.LinearReconstruction.IspaceSize};
        
        % Set different nufft settings
        [ns,nl,nz,nc,ndyn]=size(MR.Data);
        MR.Parameter.Encoding.NrDyn=1;
        MR.UMCParameters.LinearReconstruction.NUFFTMethod='greengard';
        MR.UMCParameters.LinearReconstruction.CombineCoils='no';
        MR.Data=permute(reshape(permute(MR.Data,[1 3 4 2 5]),[ns nz nc nl*ndyn 1]),[1 4 2 3 5]);
        MR.Parameter.Gridder.Weights=permute(reshape(permute(MR.Parameter.Gridder.Weights,[1 2 5 3 4]),[ns nl*ndyn 1 nz 1]),[1 2 4 3 5]);
        MR.Parameter.Gridder.Kpos=permute(reshape(permute(MR.Parameter.Gridder.Kpos,[1 2 5 3 4]),[ns nl*ndyn 1 nz 1]),[1 2 4 3 5]);
        MR.UMCParameters.LinearReconstruction.IspaceSize(2)=[nl*ndyn];
        MR.UMCParameters.LinearReconstruction.IspaceSize(5)=[1];
        
        % Perform NUFFT
        GreengardNUFFT(MR);
        
        % Get CSMs and create operator
        MR.Parameter.Recon.Sensitivities=autocalibrate(MR.Data);
        MR.UMCParameters.LinearReconstruction.CombineCoilsOperator=CC(MR.Parameter.Recon.Sensitivities);
        
        % Save coil maps to directory
        cd(MR.UMCParameters.GeneralComputing.TemporateWorkingDirectory)
        csmac=MR.Parameter.Recon.Sensitivities;
        save csmac csmac
        cd(MR.UMCParameters.GeneralComputing.PermanentWorkingDirectory)
        
        % Restore settings
        [MR.Data,MR.Parameter.Encoding.NrDyn,MR.UMCParameters.LinearReconstruction.NUFFTMethod,...
            MR.UMCParameters.LinearReconstruction.CombineCoils,MR.Parameter.Gridder.Weights...
            ,MR.Parameter.Gridder.Kpos,MR.UMCParameters.LinearReconstruction.IspaceSize]=store{:};
        MR=SetGriddingFlags(MR,0);
    end
    
    % Notification
    fprintf('Finished [%.2f sec] \n',toc')
end

%% Reference Scan
if strcmpi(MR.UMCParameters.LinearReconstruction.ReferenceScan,'yes')
    MRSenseUMC(MR);
    % Notification
    fprintf('Finished [%.2f sec] \n',toc')
end



% END
end