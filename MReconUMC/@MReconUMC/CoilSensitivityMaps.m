function CoilSensitivityMaps( MR )
%Estimate coil sensitivity maps either from the refscan, espirit or the
% walsh method. Espirit only works for (m)2D and not for 3D.
% Espirit and Walsh are autocalibrated methods and their its beneficial to
% combine reconstruct multiple dynamics together to enhance the quality of 
% the coil maps. Therefore the data is differently organized to perform the 
% gridding step needed for the csm mapping. This is regulated in the
% function csm_handle_labels_and_settings which temporary adjust the data
% dimensions. No option is available at the moment to estimate csm maps for
% multiple dynamics. The parameter AdjointReconstruction.LoadCoilSensitivityMaps
% allows the use of the coil maps from the previous reconstruction.
%
% 20170717 - T.Bruijnen

%% Logic & display
if strcmpi(MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps,'no')
     fprintf('No coil maps used ................................  ');tic;
     fprintf('Finished [%.2f sec]\n',toc');return;end

% If coil maps are available load and the user specified to use them, load them and return
cd(MR.UMCParameters.GeneralComputing.TemporateWorkingDirectory)
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

%% CoilSensitivityMaps
% Sense refscan method, creates sensitivity operator internaly and returns function afterwards.
if strcmpi(MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps,'refscan');reconframe_sensitivity_mapping(MR);return;end

% Both the autocalibrated methods require some different labels & settings in the reconframe structure
store=csm_handle_labels_and_settings(MR); 

% Perform the reconstruction without coil combination
fprintf('\n     nufft on all the data without coil comb......  ');tic; 
AdjointReconstruction(MR); 
fprintf('Finished [%.2f sec]\n',toc')

% Notification        
fprintf('     Estimation of sensitivities..................  ');tic; 

% Estimate the coil sensitivities with the espirit method
espirit(MR);

% Estimate the coil sensitivities with the Walsh method
walsh(MR);

% Store maps in an operator - I believe this requires a copy of the csm. Not the most efficient method        
MR.UMCParameters.Operators.S=CC(MR.Parameter.Recon.Sensitivities);

% Save coil maps to directory 
cd(MR.UMCParameters.GeneralComputing.TemporateWorkingDirectory)
csm=MR.Parameter.Recon.Sensitivities;save('csm.mat','csm')
cd(MR.UMCParameters.GeneralComputing.PermanentWorkingDirectory)

% Reset the labels and settings change in store
store=csm_handle_labels_and_settings(MR,store);  % Store will be empty now

% Return to main directory
cd(MR.UMCParameters.GeneralComputing.PermanentWorkingDirectory)

%% Display
% Notification
fprintf('Finished [%.2f sec]\n',toc')

% END
end