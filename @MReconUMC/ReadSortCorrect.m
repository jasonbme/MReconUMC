function ReadSortCorrect( MR )
%% Perform standard data corrections

% Notification
fprintf('Perform ReadSortCorrect ..........................  ');tic;

MR.Parameter.Parameter2Read.typ=1;
MR.ReadData;
MR.DcOffsetCorrection;
MR.PDACorrection;
MR.RandomPhaseCorrection;
MR.MeasPhaseCorrection;
MR.RemoveOversampling;
MR.SortData; % Overloaded

% Notification
fprintf('Finished [%.2f sec]\n',toc')

% END
end