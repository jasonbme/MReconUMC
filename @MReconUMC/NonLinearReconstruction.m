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
    %NLR.lambdaT=0.35*max(abs(MR.Data(:)));
    
    % Do the nonlinear reconstruction
    tcn=0;
    for ntimes=1:MR.UMCParameters.NonlinearReconstruction.CGTimes
        [MR.Data,cn]=CGsolve(MR.Data,NLR);
        tcn=tcn+cn;
    end

    % Notification
    fprintf([num2str(tcn),' nufft steps performed. Finished [%.2f sec] \n'],toc')
end

% END
end
