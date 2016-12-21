function nlr = NLRstruct(MR)
% Set default values to parameters for the iterative reconstruction
nlr.nite=MR.UMCParameters.NonlinearReconstruction.CGTimes;
nlr.lambda=MR.UMCParameters.NonlinearReconstruction.CGLambda;
nlr.beta=MR.UMCParameters.NonlinearReconstruction.CGBeta;
nlr.stopcrit=MR.UMCParameters.NonlinearReconstruction.CGStopCriteria;
nlr.adjustlambda=0;
nlr.quit=0;
nlr.CGiterations=0;

% END
end
