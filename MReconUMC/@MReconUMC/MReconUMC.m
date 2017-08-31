classdef MReconUMC < MRecon
%This function creates a superclass over thr MRecon class. This ensures
% that you can overload reconframe functions but still choose to apply the
% original reconframe one (e.g. MR@MRecon(...)). The function also saves
% the location of the data in a struct to save the reconstruction if
% required.
%
% 20170717 - T.Bruijnen

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
        
        % Initialize parameters
        MR.UMCParameters=UMCPars();
        
        % Fill in permant and temporary working directory
        MR.UMCParameters.GeneralComputing.PermanentWorkingDirectory=pwd;
        MR.UMCParameters.GeneralComputing.DataRoot=root;
        MR.UMCParameters.GeneralComputing.TemporateWorkingDirectory=[root,'Scan',num2str(scan)];
        
        % Supress reconframe warnings
        warning('off')

        % Notification
        fprintf('Finished [%.2f sec]\n',toc')
    end
end

% END
end
