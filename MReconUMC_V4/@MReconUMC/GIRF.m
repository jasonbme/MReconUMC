function GIRF( MR )
% Process saved GIRFs, reconstruct suspected input gradient waveforms to
% corrected k-space trajectories

if strcmpi(MR.UMCParameters.SystemCorrections.GIRF,'no')
    return
end

% Notification
fprintf('\n              Include GIRFs ......................  ');tic;

% Load GIRF from precomputed .mat files.
% Note that GIRF 1 = Z, 2 = X and 3 = Y/ supine --> FH / AP / RL
cd(MR.UMCParameters.GeneralComputing.PermanentWorkingDirectory)

% Get GIRF from correct scanner 
if MR.Parameter.Scan.FieldStrength==1.5
        load('/Packages/girf/GIRF_MR21.mat')
        MR.UMCParameters.SystemCorrections.GIRF_transfer_function=GIRF_MR21;
        MR.UMCParameters.SystemCorrections.GIRF_frequencies=freq;
end

% Extract gradient waveform from object attributes
[MR.UMCParameters.SystemCorrections.GIRF_time,MR.UMCParameters.SystemCorrections.GIRF_input_waveforms,...
    MR.UMCParameters.SystemCorrections.GIRF_ADC_time]=PPE2WaveForm_proto(MR);

%% Temporarily %% 
MR.UMCParameters.SystemCorrections.GIRF_ADC_time=MR.UMCParameters.SystemCorrections.GIRF_ADC_time+MR.UMCParameters.SystemCorrections.GIRF_delaytime*10^-6;
%% END %%

% Apply GIRF & include preemp if activeted in PPE
MR.UMCParameters.SystemCorrections.GIRF_output_waveforms=applyGIRF(MR.UMCParameters.SystemCorrections.GIRF_time,MR.UMCParameters.SystemCorrections.GIRF_input_waveforms,...
            MR.UMCParameters.SystemCorrections.GIRF_frequencies,MR.UMCParameters.SystemCorrections.GIRF_transfer_function,MR.UMCParameters.SystemCorrections.GIRF_ADC_time,...
            MR.UMCParameters.SystemCorrections.GIRF_preemphasis,MR.UMCParameters.SystemCorrections.GIRF_preemphasis_bw,MR.UMCParameters.ReconFlags.Verbose);

if strcmpi(MR.Parameter.Scan.AcqMode,'Radial')
        % Compute K-space coordinates per readout for radial
        MR.Parameter.Gridder.Kpos=ComputeTrajectoryRadial(MR.Parameter.Gridder.RadialAngles,MR.UMCParameters.SystemCorrections.GIRF_input_waveforms,MR.UMCParameters.SystemCorrections.GIRF_output_waveforms,...
            MR.UMCParameters.SystemCorrections.GIRF_time,MR.UMCParameters.SystemCorrections.GIRF_ADC_time,MR.Parameter.Scan.REC,MR.UMCParameters.SystemCorrections.GIRF_nominaltraj,MR.UMCParameters.ReconFlags.Verbose);
        
        % Recompute density function
        tmp=zeros([3 size(MR.Parameter.Gridder.Kpos)]);
        tmp(1,:,:)=real(MR.Parameter.Gridder.Kpos);tmp(2,:,:)=imag(MR.Parameter.Gridder.Kpos);
        MR.Parameter.Gridder.Weights=sdc3_MAT(tmp,10,max(MR.Parameter.Gridder.OutputMatrixSize),0,2);clear tmp
        
        % Take resolution settings into account
        MR.Parameter.Gridder.Kpos=MR.Parameter.Gridder.Kpos*MR.UMCParameters.AdjointReconstruction.SpatialResolutionRatio;
end
if strcmpi(MR.Parameter.Scan.Technique,'FEEPI')
        % ONLY 2D or stack of EPIS
        % Compute k-space trajectory for single shot EPI only
        MR.Parameter.Gridder.Kpos=ComputeTrajectory2DEPI(size(MR.Data),MR.UMCParameters.SystemCorrections.GIRF_input_waveforms,MR.UMCParameters.SystemCorrections.GIRF_output_waveforms,...
            MR.UMCParameters.SystemCorrections.GIRF_time,MR.UMCParameters.SystemCorrections.GIRF_ADC_time,MR.Parameter.Scan.REC,MR.UMCParameters.SystemCorrections.GIRF_nominaltraj,MR.UMCParameters.ReconFlags.Verbose);
end

% Notification
fprintf('Finished [%.2f sec]\n',toc')

% END
end