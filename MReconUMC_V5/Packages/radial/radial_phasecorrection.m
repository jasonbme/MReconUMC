function radial_phasecorrection( MR )
% 20160616 - Linear phase correction by fitting a model through the k0
% phase to correct for angular dependance. Alternatively one could simply
% subtract the k0 phase from all spokes.

if ~strcmpi(MR.Parameter.Scan.AcqMode,'Radial') || strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'mrecon')...
        || strcmpi(MR.UMCParameters.SystemCorrections.PhaseCorrection,'no')
    return
end

% Notification
fprintf('     Perform radial phase correction..............  ');tic;

% Iterate over all the data chunks
for n=1:numel(MR.Data)
    
    if ~(strcmpi(MR.Parameter.Scan.UTE,'yes') && (n==1))
        % Model based phase error estimation, either nearest neighbour or
        % interpolation based.
        radial_model_based_phase_estimation(MR,n); % fast
        radial_model_based_phase_estimation_interpolation(MR,n); % slow
        
        % Apply phase correction, multiple methods
        % 1) Model-based
        % 2) Zero-based (phase destruction), NN or linear interpolation
        
        % Apply model based phase correction
        radial_model_based_phase_correction(MR,n);
        
        % Apply zero-based phase correction
        radial_zero_based_phase_correction(MR,n);
        radial_zero_based_phase_correction_interpolation(MR,n);
    end

end


% Notification
fprintf('Finished [%.2f sec]\n',toc')

% END
end
