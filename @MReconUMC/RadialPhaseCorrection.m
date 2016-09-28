function RadialPhaseCorrection( MR )
%% Radial phase correction and data conditioning

if ~strcmpi(MR.UMCParameters.LinearReconstruction.NUFFTMethod,'mrecon') && strcmpi(MR.Parameter.Scan.AcqMode,'radial')
    
    % Subtract k0 phase from spokes
    linearphasecorrection( MR );
    
    % Save raw data for nonlinear reconstructions & scale 
    if strcmpi(MR.UMCParameters.NonlinearReconstruction.NonlinearReconstruction,'yes')
        MR.Data=numel(MR.Data)*MR.Data/norm(MR.Data(:),1);
        MR.UMCParameters.NonlinearReconstruction.RawData=MR.Data;
    end
end

%END
end
