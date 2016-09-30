classdef NLRPars < dynamicprops & deepCopyable
%% NonLinear Reconstruction related parameters
properties
    CGBeta
    CGCost 
    CGIterations
    CGLambda
    CGTimes
    NonlinearReconstruction
    RawData
    TVTOperator
end
methods
    function NLR = NLRPars()   
        NLR.RawData=[];
        NLR.CGLambda=.0000015;
        NLR.CGIterations=25;
        NLR.CGBeta=0.02;
	NLR.CGTimes=3;
        NLR.CGCost=[0;0;0];
        NLR.TVTOperator={};
        NLR.NonlinearReconstruction='no';
    end
end

% END
end
