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

        % Get dimensions for data handling
        dims=MR.UMCParameters.AdjointReconstruction.KspaceSize;num_data=numel(MR.Data);
        necho=MR.UMCParameters.AdjointReconstruction.CoilMapEchoNumber;
          
        % Set different nufft settings
        MR.Parameter.Recon.CoilCombination='no';
        MR.Parameter.Encoding.NrDyn=1;
        for n=1:num_data;MR.Data{n}=permute(reshape(permute(MR.Data{n},[1 3 4 6:12 2 5]),[dims{n}(1) dims{n}(3) dims{n}(4) dims{n}(6:12) dims{n}(2)*dims{n}(5) 1]),...
                [1 11 2 3 4:10 12]);MR.UMCParameters.AdjointReconstruction.IspaceSize{n}(2)=[dims{n}(2)*dims{n}(5)];MR.UMCParameters.AdjointReconstruction.IspaceSize{n}(5)=1;end

        % Some exceptions for the 'mrecon' gridder
        if ~strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'mrecon')
            MR.Parameter.Gridder.Weights={permute(reshape(permute(MR.Parameter.Gridder.Weights{necho},[1 2 5 3 4]),[dims{necho}(1) dims{necho}(2)*dims{necho}(5) 1 1 1]),[1 2 4 3 5])};
            MR.Parameter.Gridder.Kpos={permute(reshape(permute(MR.Parameter.Gridder.Kpos{necho},[1 2 5 3 4]),[dims{necho}(1) dims{necho}(2)*dims{necho}(5) 1 1 1]),[1 2 4 3 5])};end
        if strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'mrecon');MR.Parameter.Scan.Samples=[dims{necho}(1) dims{necho}(2) dims{necho}(3)];end    

        % Do the NUFFT
        MR.UMCParameters.ReconFlags.nufft_csmapping=1; % Flag is for fprintf notifications
        AdjointReconstruction(MR); 
        MR.UMCParameters.ReconFlags.nufft_csmapping=0;

        % Get CSMs and create operator
        MR.Parameter.Recon.Sensitivities=single(espirit(MR.Data{necho}));
        MR.UMCParameters.AdjointReconstruction.CombineCoilsOperator=CC(MR.Parameter.Recon.Sensitivities,MR.UMCParameters.AdjointReconstruction.IspaceSize);

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
        
        % Get dimensions for data handling
        dims=MR.UMCParameters.AdjointReconstruction.KspaceSize;num_data=numel(MR.Data);
        necho=MR.UMCParameters.AdjointReconstruction.CoilMapEchoNumber;
          
        % Set different nufft settings
        MR.Parameter.Recon.CoilCombination='no';
        MR.Parameter.Encoding.NrDyn=1;
        for n=1:num_data;MR.Data{n}=permute(reshape(permute(MR.Data{n},[1 3 4 6:12 2 5]),[dims{n}(1) dims{n}(3) dims{n}(4) dims{n}(6:12) dims{n}(2)*dims{n}(5) 1]),...
                [1 11 2 3 4:10 12]);MR.UMCParameters.AdjointReconstruction.IspaceSize{n}(2)=[dims{n}(2)*dims{n}(5)];MR.UMCParameters.AdjointReconstruction.IspaceSize{n}(5)=1;end

        % Some exceptions for the 'mrecon' gridder
        if ~strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'mrecon')
            MR.Parameter.Gridder.Weights={permute(reshape(permute(MR.Parameter.Gridder.Weights{necho},[1 2 5 3 4]),[dims{necho}(1) dims{necho}(2)*dims{necho}(5) 1 1 1]),[1 2 4 3 5])};
            MR.Parameter.Gridder.Kpos={permute(reshape(permute(MR.Parameter.Gridder.Kpos{necho},[1 2 5 3 4]),[dims{necho}(1) dims{necho}(2)*dims{necho}(5) 1 1 1]),[1 2 4 3 5])};end
        if strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'mrecon');MR.Parameter.Scan.Samples=[dims{necho}(1) dims{necho}(2) dims{necho}(3)];end    

        % Do the NUFFT
        MR.UMCParameters.ReconFlags.nufft_csmapping=1; % Flag is for fprintf notifications
        AdjointReconstruction(MR); 
        MR.UMCParameters.ReconFlags.nufft_csmapping=0;

        % Get CSMs and create operator
        [~,MR.Parameter.Recon.Sensitivities]=openadapt(permute(MR.Data{necho},[4 1 2 3]));
        MR.Parameter.Recon.Sensitivities=single(permute(MR.Parameter.Recon.Sensitivities,[2 3 4 1]));
        MR.UMCParameters.AdjointReconstruction.CombineCoilsOperator=CC(MR.Parameter.Recon.Sensitivities,MR.UMCParameters.AdjointReconstruction.IspaceSize);

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
     MR.Parameter.Recon.Sensitivities=single(mrsense(MR));
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