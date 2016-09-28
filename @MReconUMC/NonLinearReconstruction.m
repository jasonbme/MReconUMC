function NonLinearReconstruction( MR )
%% Perform nonlinear reconstructions

if strcmpi(MR.UMCParameters.NonlinearReconstruction.NonlinearReconstruction,'yes') 
    fprintf('Non linear reconstruction.........................  \n');tic;

    % Initiate operators
    NLR=NLRstruct();
    NLR.TVT=TV_Temp();
    NLR.NUFFT=MR.UMCParameters.LinearReconstruction.NUFFTOperator;
    NLR.S=MR.UMCParameters.LinearReconstruction.CombineCoilsOperator; 
    NLR.W=MR.UMCParameters.LinearReconstruction.DensityOperator;
    NLR.y=double(NLR.W*MR.UMCParameters.NonlinearReconstruction.RawData);
    NLR.nite=MR.UMCParameters.NonlinearReconstruction.CGIterations;
    NLR.beta=MR.UMCParameters.NonlinearReconstruction.CGBeta;   
    NLR.lambdaT=MR.UMCParameters.NonlinearReconstruction.CGLambda;

    % Do the nonlinear reconstruction
    MR.Data=CGsolve(MR.Data,NLR);

    % Notification
    fprintf('Finished [%.2f sec] \n',toc')
end

% END
end
