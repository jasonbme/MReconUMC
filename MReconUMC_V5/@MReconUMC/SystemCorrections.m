function SystemCorrections( MR )
%System corrections such as noise prewhitening and phase corrections are
% adressed in this routine.
%
% 20170717 - T.Bruijnen

%% Logic & display 
% If simulation mode is activated this is not required
if strcmpi(MR.UMCParameters.Simulation.Simulation,'yes')
    return;
end

% Notification
fprintf('Applying system corrections ......................  \n');tic

%% Systemcorrections
% Perform noise prewhitening
noise_prewhitening(MR);

% Radial Phase correction on the most center point of k-space (0th order)
radial_phasecorrection(MR);

%END
end
