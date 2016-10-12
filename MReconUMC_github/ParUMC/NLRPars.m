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
        NLR.CGLambda=10;
        NLR.CGIterations=25;
        NLR.CGBeta=0.0005;
	NLR.CGTimes=5;
        NLR.CGCost=[0;0;0];
        NLR.TVTOperator={};
        NLR.NonlinearReconstruction='no';
    end
end

% END
end
