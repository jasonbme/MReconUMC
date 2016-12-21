function ParallelComputing( MR )

% Startup parallel pool and check memory requirements
if strcmpi(MR.UMCParameters.GeneralComputing.ParallelComputing,'yes')

    p=gcp('nocreate');
    if isempty(p)
        % Notification
        fprintf('Starting up parallel pool ........................  ');tic;

        evalc('parpool(MR.UMCParameters.GeneralComputing.NumberOfCPUs)');
    else
        % Notification
        fprintf('Parallel pool already up .........................  ');tic;
    end
    pctRunOnAll warning off
else % Delete parpool if active and you dont want one

    % Notification
    fprintf('No parallel computing  ...........................  ');tic;

    poolobj = gcp('nocreate');
    delete(poolobj);
    MR.UMCParameters.GeneralComputing.NumberOfCPUs=0;
end

% Notification
fprintf('Finished [%.2f sec]\n',toc')

%END
end
