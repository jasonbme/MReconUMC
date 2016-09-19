classdef MReconUMC < MRecon
%% Initialize structures and load parameters

properties
    UMCParameters=[];
end

methods
    function MR = MReconUMC(root,scan)
        % Notification
        fprintf('\nLoading MR recon object ..........................  ');tic;
        
        % Get location of .lab
        list=dir([root,'Scan',num2str(scan),'/','*.lab']);
        loc=[root,'Scan',num2str(scan),'/',list.name];

        % Read in data 
        MR=MR@MRecon(loc);
        
        % Initiate parameters
        MR.UMCParameters=UMCPars();
        
        % Give parameters default values
        MR.FillParameters;
        
        % Fill in permant and temporary working directory
        MR.UMCParameters.GeneralComputing.PermanentWorkingDirectory=pwd;
        MR.UMCParameters.GeneralComputing.DataRoot=root;
        MR.UMCParameters.GeneralComputing.TemporateWorkingDirectory=[root,'Scan',num2str(scan)];
        
        % Notification
        fprintf('Finished [%.2f sec]\n',toc')
    end
end

% END
end
