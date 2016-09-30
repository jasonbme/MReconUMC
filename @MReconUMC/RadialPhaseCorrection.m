function RadialPhaseCorrection( MR )
%% Radial phase correction and data conditioning

if ~strcmpi(MR.UMCParameters.LinearReconstruction.NUFFTMethod,'mrecon') && strcmpi(MR.Parameter.Scan.AcqMode,'radial')
    
	if ~strcmpi(MR.UMCParameters.LinearReconstruction.NUFFTMethod,'mrecon') && strcmpi(MR.Parameter.Scan.AcqMode,'radial')
	    % Do FFT over 3th dimension before corrections for stack-of-stars
	    if strcmpi(MR.Parameter.Scan.ScanMode,'3D')
		MR.Data=fft(MR.Data,[],3);
		MR.Parameter.ReconFlags.isimspace=[0,0,1];
	    end
	end

    % Subtract k0 phase from spokes
    linearphasecorrection( MR );
    
    % Save raw data for nonlinear reconstructions & scale 
    if strcmpi(MR.UMCParameters.NonlinearReconstruction.NonlinearReconstruction,'yes')
        MR.UMCParameters.NonlinearReconstruction.RawData=MR.Data;
    end
end

%END
end
