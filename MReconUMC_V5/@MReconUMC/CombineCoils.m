function CombineCoils( MR )
% Performs SOS or Roemer coil combination

if ~strcmp(MR.Parameter.Recon.CoilCombination,'no')
    if isempty(MR.UMCParameters.Operators.S)

        % Notification
        fprintf('Combining receiver coils (sos) ...................  ');tic;

        CombineCoils@MRecon(MR);
        
    else
        % Notification
        fprintf('Combining receiver coils (Roemer) ................  ');tic;
        MR.Data=MR.UMCParameters.Operators.S*MR.Data;
        MR.Parameter.ReconFlags.iscombined=1;
    end
end

% Notification
fprintf('Finished [%.2f sec]\n',toc')

% END
end