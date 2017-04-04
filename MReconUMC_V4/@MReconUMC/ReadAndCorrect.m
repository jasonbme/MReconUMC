function ReadAndCorrect( MR )
% Perform the standard data correction functions

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