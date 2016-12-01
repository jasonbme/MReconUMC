function nlr = NLRstruct()
% Set default values to parameters for the iterative reconstruction
nlr.nite=5;
nlr.adjustT=0;
nlr.adjustS1=0;
nlr.adjustS2=0;
nlr.lambdaT=0;
nlr.lambdaS1=0;
nlr.lambdaS2=0;
nlr.beta=.1;
nlr.stopcrit=0.05;
nlr.quit=0;
nlr.n=0;

% END
end
