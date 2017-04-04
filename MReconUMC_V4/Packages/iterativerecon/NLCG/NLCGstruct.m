function NLCG = NLCGstruct(MR)

% Set default values to parameters for the iterative reconstruction
NLCG.beta=.4;
NLCG.stopcrit=0.01; % <1 and >0
NLCG.adjustlambda=0;
NLCG.quit=0;
NLCG.CGiterations=1; 

% END
end
