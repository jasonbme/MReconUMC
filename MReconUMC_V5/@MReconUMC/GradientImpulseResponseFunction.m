function GradientImpulseResponseFunction( MR )
% Process saved GIRFs, reconstruct suspected input gradient waveforms to
% corrected k-space trajectories

if strcmpi(MR.UMCParameters.SystemCorrections.GIRF,'no')
    return
end

% Notification
fprintf('     Include GIRFs ...............................  ');tic;

% Load GIRF from precomputed .mat files.
% Note that GIRF 1 = Z, 2 = X and 3 = Y/ supine --> FH / AP / RL
cd(MR.UMCParameters.GeneralComputing.PermanentWorkingDirectory)

% Get GIRF from correct scanner 
if MR.Parameter.Scan.FieldStrength==1.5 ||MR.Parameter.Scan.FieldStrength==3.0
        load('/Packages/girf/GIRFs/GIRF_MR21.mat')
        MR.UMCParameters.SystemCorrections.GIRF_transfer_function=GIRF_MR21;
        MR.UMCParameters.SystemCorrections.GIRF_frequencies=freq;
end

% Extract gradient waveform from object attributes
ppe_2_waveform(MR);

% Apply GIRF on gradient waveforms 
apply_gradient_impulse_response(MR);

if strcmpi(MR.Parameter.Scan.AcqMode,'Radial')
        % Compute K-space coordinates per readout for radial
        radial_compute_trajectory_2D(MR); % Include 2Dp
        radial_compute_trajectory_3D(MR);
        
        % Compute Density weights iteratively
        estimate_density_arbitrary_trajectory_ND(MR);
end

if strcmpi(MR.Parameter.Scan.Technique,'FEEPI')
        % ONLY 2D or stack of EPIS
        % Compute k-space trajectory for single shot EPI only
        MR.Parameter.Gridder.Kpos=epi_compute_trajectory_2D(size(MR.Data),MR.UMCParameters.SystemCorrections.GIRF_input_waveforms,MR.UMCParameters.SystemCorrections.GIRF_output_waveforms,...
            MR.UMCParameters.SystemCorrections.GIRF_time,MR.UMCParameters.SystemCorrections.GIRF_ADC_time,MR.Parameter.Scan.REC,MR.UMCParameters.SystemCorrections.GIRF_nominaltraj,MR.UMCParameters.ReconFlags.Verbose);
end

% Notification
fprintf('Finished [%.2f sec]\n',toc')

% END
end