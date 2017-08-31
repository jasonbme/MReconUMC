function ReadAndCorrect( MR )
%Perform the standard data correction functions. Note that ReadData is
% overloaded to differently handle the noise and phase correction
% calibration data.

%% Logic and display
% If simulation mode is activated this is not required
if strcmpi(MR.UMCParameters.Simulation.Simulation,'yes')
    MR=generate_simulation_data(MR);
    return;
end

% Notification
fprintf('Perform ReadAndCorrect ...........................  ');tic;

%% ReadAndCorrect
MR.ReadData;
MR.RandomPhaseCorrection;
MR.RemoveOversampling;
MR.PDACorrection;
MR.DcOffsetCorrection;
MR.MeasPhaseCorrection;

%% Display
% Notification
fprintf('Finished [%.2f sec]\n',toc')

% END
end