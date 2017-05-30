function CoilSensitivityMaps( MR )
% Estimate coil sensitivity maps either from the refscan, espirit or the walsh method
% The latter two are autocalibrated methods and their its beneficial to combine reconstruct
% multiple dynamics together to enhance the quality of the maps. Therefore the structure labels 
% settings require some modifications.

% Logic
if strcmpi(MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps,'no')
     fprintf('No coil maps used ................................  ');tic;
     fprintf('Finished [%.2f sec]\n',toc');return;end

% Check whether coils maps are available in the folder
cd(MR.UMCParameters.GeneralComputing.TemporateWorkingDirectory)

% If coil maps are available load them and return
if (strcmpi(MR.UMCParameters.AdjointReconstruction.LoadCoilSensitivityMaps,'yes') && exist('csm.mat')==2)
    
    % Notification
    fprintf('Loading csm from previous reconstruction..........  ');tic;load('csm.mat');
    MR.Parameter.Recon.Sensitivities=csm;
    
    % Create coil combine operator
    MR.UMCParameters.Operators.S=CC(MR.Parameter.Recon.Sensitivities);
    cd(MR.UMCParameters.GeneralComputing.PermanentWorkingDirectory)
    
    % Notification
    fprintf('Finished [%.2f sec]\n',toc')
    return
end

% If they are not available calculate them, notification
fprintf(['Estimate coil maps (',MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps(1:5),')........................  ']');tic;

% Sense refscan method
mrsense(MR);

% Both the autocalibrated methods require some different labels & settings in the reconframe structure
store=csm_handle_labels_and_settings(MR); 

% Perform the reconstruction without coil combination
fprintf('\n     NUFFT on all the data without coil comb......  ');tic; 
AdjointReconstruction(MR); 
fprintf('Finished [%.2f sec]\n',toc')

% Notification        
fprintf('     Actual estimation of sensitivities...........  ');tic; 

% Estimate the coil sensitivities with the espirit method
espirit(MR);

% Estimate the coil sensitivities with the Walsh method
walsh(MR);

% Store maps in an operator - I believe this requires a copy of the csm. Not the most efficient method        
MR.UMCParameters.Operators.S=CC(MR.Parameter.Recon.Sensitivities);

% Save coil maps to directory & and remove from RAM (already inside operator)
cd(MR.UMCParameters.GeneralComputing.TemporateWorkingDirectory)
csm=MR.Parameter.Recon.Sensitivities;save csm csm
cd(MR.UMCParameters.GeneralComputing.PermanentWorkingDirectory)

% Reset the labels and settings change in store
store=csm_handle_labels_and_settings(MR,store);  % Store will be empty now

% Return to main directory
cd(MR.UMCParameters.GeneralComputing.PermanentWorkingDirectory)

% Notification
fprintf('Finished [%.2f sec]\n',toc')

% END
end