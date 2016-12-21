function NonLinearReconstruction( MR )


if strcmpi(MR.UMCParameters.NonlinearReconstruction.NonlinearReconstruction,'no');
    return
end

% Perform nonlinear reconstructions
fprintf('Non linear reconstruction.........................  \n');tic;

% Initialize dedicated struct
NLR=NLRstruct(MR);

% If compressed sensing
if NLR.lambda>0
    if strcmpi(MR.UMCParameters.NonlinearReconstruction.TVtype,'temporal');NLR.TV=TV_Temp();end
    if strcmpi(MR.UMCParameters.NonlinearReconstruction.TVtype,'spatial');NLR.TV=TV_Space();end
end

% Fill in operators
NLR.NUFFT=MR.UMCParameters.LinearReconstruction.NUFFTOperator;
NLR.S=MR.UMCParameters.LinearReconstruction.CombineCoilsOperator; 
NLR.W=MR.UMCParameters.LinearReconstruction.DensityOperator;
NLR.y=double(NLR.W*MR.UMCParameters.NonlinearReconstruction.RawData);MR.UMCParameters.NonlinearReconstruction.RawData=[];

% Do the nonlinear reconstruction
NUFFTiter=0; % Count number of nufft operations
while NLR.CGiterations<MR.UMCParameters.NonlinearReconstruction.CGTimes && NLR.quit==0
    [MR.Data,NUFFTi,NLR]=CGsolve(MR.Data,NLR);
    NUFFTiter=NUFFTiter+NUFFTi;
    NLR.CGiterations=NLR.CGiterations+1;
end

clear NLR

% Notification
fprintf([num2str(NUFFTiter),' nufft steps performed. Finished [%.2f sec] \n'],toc')

% END
end
