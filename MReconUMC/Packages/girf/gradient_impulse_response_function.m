function gradient_impulse_response_function( MR )
%Load girfs if available for the specific scanner, extract nominal gradient
% waveforms from the PPE objects and correct them with the girfs. Then
% compute the trajectory (radial or epi) and iteratively estimate the dcf.
% Note that the iterative dcf estimation works differently for heavily
% undersampled cases.
%
% 20170717 - T.Bruijnen

%% Logic & display
if strcmpi(MR.UMCParameters.SystemCorrections.Girf,'no')
    return
end

% Notification
fprintf('\n     Include GIRFs ...............................  ');tic;

%% Load GIRF
% Load GIRF from precomputed .mat files.
cd(MR.UMCParameters.GeneralComputing.PermanentWorkingDirectory)

% Get 1th order GIRF from correct scanner 
if MR.Parameter.Scan.FieldStrength==1.5 
        % load
        load('/nfs/rtsan02/userdata/home/tbruijne/Documents/MATLAB/MReconUMC/MReconUMC/Packages/girf/GIRFs/MR21/GIRF.mat')
                
        % Temporarily fix 
        brodsky_girf(:,1)=-brodsky_girf(:,1);
        
        % Apply rotations to match current coordinate system, dspigirf is in
        % "RL PA HF". This girf is symmetric so no need to swap R+L Brodsky girf is in "LR AP FH"
        strlist=['R','A','F'];for ax=1:3;dspi_girf_rot(:,ax)=dspi_girf(:,interp1([1 4.5 8],[1 2 3],strfind(MR.Parameter.Scan.MPS,strlist(ax)),'nearest'));end
        strlist=['R','A','F'];for ax=1:3;brodsky_girf_rot(:,ax)=brodsky_girf(:,interp1([1 4.5 8],[1 2 3],strfind(MR.Parameter.Scan.MPS,strlist(ax)),'nearest'));end
        
        % Zeroth order girf
        MR.UMCParameters.SystemCorrections.GirfZeroth=brodsky_girf_rot;
        MR.UMCParameters.SystemCorrections.GirfZerothFrequency=brodsky_freq;        
        
        % First order girf
        MR.UMCParameters.SystemCorrections.GirfTransferFunction=dspi_girf_rot;
        MR.UMCParameters.SystemCorrections.GirfFrequency=dspi_freq;                
        
end

%% Apply girf
% Extract gradient waveform from object attributes
ppe_2_waveform(MR);

% Apply GIRF on gradient waveforms 
apply_zeroth_order_gradient_impulse_response(MR);
apply_first_order_gradient_impulse_response(MR);

%% Estimate dcf and trajectory
% Compute K-space coordinates per readout for radial
radial_compute_trajectory_2D(MR);
radial_compute_trajectory_3D(MR);

% Compute Density weights iteratively
estimate_density_arbitrary_trajectory_3D(MR);

if strcmpi(MR.Parameter.Scan.Technique,'FEEPI')
        % ONLY 2D or stack of EPIS
        % Compute k-space trajectory for single shot EPI only
        epi_compute_trajectory_2D(MR);
        estimate_density_arbitrary_trajectory_3D(MR);
end



%% Display
% Notification
fprintf('Finished [%.2f sec]\n',toc')

% END
end
