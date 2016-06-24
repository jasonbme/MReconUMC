function ReadSortCorrect( MR )
% 20160616 - Perform all the initial corrections.
% Only SortData is different then the original functions.

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