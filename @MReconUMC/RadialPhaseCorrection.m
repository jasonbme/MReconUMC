function RadialPhaseCorrection( MR )
% 20160616 - Overviewing script of the initial corrections.
% Perform various phase/magnitude/shift corrections.

% Check for conflicts
if (MR.ParUMC.Goldenangle > 1 && strcmpi(MR.ParUMC.GradDelayCorrMethod,'smagdc'))
    fprintf('\nWarning: smagdc does not work very will for tiny golden angle data.\n')
end

if strcmp(MR.ParUMC.CustomRec,'yes')
    % Apply gradient-delay correction
    MR.GradDelayCorr;
    
    % Apply zeroth moment correction, default turned off
    MR.ZerothMomentCorr;
    
    % Subtract k0 phase from spokes
    MR.LinPhaseCorr;
    
    % When using MRecon gridder, make sure it does not correct twice
    MR.Parameter.Gridder.RadialPhaseCorr='no'; % PC performed already
end

%END
end
