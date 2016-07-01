function RadialPhaseCorrection( MR )
% 20160616 - Overviewing script of the initial corrections.
% Perform various phase/magnitude/shift corrections.



if strcmp(MR.ParUMC.CustomRec,'yes')
    
    % Do FFT over 3th dimension before corrections for SOS
    if strcmpi(MR.Parameter.Scan.ScanMode,'3D')
        MR.Data=fft(MR.Data,[],3);
        MR.Parameter.ReconFlags.isimspace=[0,0,1];
    end
    
    % Apply gradient-delay correction
    GradientDelayCorrection( MR );
    
    % Apply zeroth moment correction, default turned off
    ZerothMomentCorrection( MR );
    
    % Subtract k0 phase from spokes
    LinearPhaseCorrection( MR );
    
    % When using MRecon gridder, make sure it does not correct twice
    MR.Parameter.Gridder.RadialPhaseCorr='no'; % PC performed already
end

%END
end
