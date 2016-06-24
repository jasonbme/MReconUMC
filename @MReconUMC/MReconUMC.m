classdef MReconUMC < MRecon
% 20160616 - Used to load UGN/EX parameters from the data (MR.FillParameters).

properties
    ParUMC=[];
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
        MR.ParUMC=UMCPars(MR);
        
        % Give parameters default values
        MR.FillParameters;
        
        % Fill in permant and temporary working directory
        MR.ParUMC.PWD=pwd;
        MR.ParUMC.Root=root;
        MR.ParUMC.TWD=[root,'Scan',num2str(scan)];
        
        % Notification
        fprintf('Finished [%.2f sec]\n',toc')
    end
end

% END
end
