function CombineCoils( MR )
%Performs sum of squares (reconframe) or Roemer coil combination based on
% the coil sensitivity maps. Reconframe expects the input to be singles so
% thats why the transformation to singles takes place.
%
% 20170717 - T.Bruijnen

%% Logic and display
if strcmp(MR.Parameter.Recon.CoilCombination,'no') || MR.Parameter.ReconFlags.iscombined;
    return;end

%% CombineCoils
if isempty(MR.UMCParameters.Operators.S)

    % Notification
    fprintf('Combining receiver coils (sos) ...................  ');tic;

    % If data is not single make single
    MR.Data=cellfun(@(x) single(x),MR.Data,'UniformOutput',false);
    CombineCoils@MRecon(MR);

else
    % Notification
    fprintf('Combining receiver coils (Roemer) ................  ');tic;
    MR.Data=MR.UMCParameters.Operators.S*MR.Data;
end

%% Display and reconstruction flags
% Notification
fprintf('Finished [%.2f sec]\n',toc')
MR.Parameter.ReconFlags.iscombined=1;

% END
end