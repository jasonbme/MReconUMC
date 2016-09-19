function NonLinearReconstruction( MR )
%% Perform nonlinear reconstructions

if strcmpi(MR.UMCParameters.NonlinearReconstruction,'yes') 
    fprintf('Non linear reconstruction.........................  ');tic;

    % Initiate operators
    NLR=NLRstruct();
    NLR.TVT=TV_Temp();
    NLR.NUFFT=MR.UMCParameters.LinearReconstruction.NUFFTOperator;
    NLR.S=MR.UMCParameters.LinearReconstruction.CombineCoilsOperator; 
    NLR.W=MR.UMCParameters.LinearReconstruction.DensityOperator;
    NLR.y=double(MR.UMCParameters.NonlinearReconstruction.RawData);
    NLR.nite=MR.UMCParameters.NonlinearReconstruction.CGIterations;
    NLR.beta=MR.UMCParameters.NonlinearReconstruction.CGBeta;   
    NLR.lambda=MR.UMCParameters.NonlinearReconstruction.lambda;

    % Do the nonlinear reconstruction
    MR.Data=CGsolve(MR.Data,NLR);

    % Notification
    fprintf('Finished [%.2f sec] \n',toc')
end

% END
end
