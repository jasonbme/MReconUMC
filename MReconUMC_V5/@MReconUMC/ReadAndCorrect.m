function ReadAndCorrect( MR )
% Perform the standard data correction functions

% If simulation mode is activated this is not required
if strcmpi(MR.UMCParameters.Simulation.Simulation,'yes')
    return;
end

% Notification
fprintf('Perform ReadAndCorrect ...........................  ');tic;

MR.ReadData;
MR.RandomPhaseCorrection;
MR.RemoveOversampling;
MR.PDACorrection;
MR.DcOffsetCorrection;
MR.MeasPhaseCorrection;

% Notification
fprintf('Finished [%.2f sec]\n',toc')

% END
end