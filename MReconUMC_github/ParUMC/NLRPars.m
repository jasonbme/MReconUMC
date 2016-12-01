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
        NLR.CGLambda=0;
        NLR.CGIterations=3;
        NLR.CGBeta=0.4;
        NLR.CGTimes=1;
        NLR.CGCost=[0;0;0];
        NLR.TVTOperator={};
        NLR.NonlinearReconstruction='no';
    end
end

% END
end
