classdef NLRPars < dynamicprops & deepCopyable
% 20161206 - Declare all parameters related to the iterative reconstructions.

properties
    CGBeta
    CGCost 
    CGIterations
    CGLambda
    CGTimes
    CGStopCriteria
    NonlinearReconstruction
    RawData
    TVtype
end
methods
    function NLR = NLRPars()   
        NLR.RawData=[];
        NLR.CGLambda=0;
        NLR.CGIterations=1;
        NLR.CGBeta=0.4;
        NLR.CGTimes=3;
        NLR.CGCost=[0;0;0];
        NLR.CGStopCriteria=0.05; % < 1 and > 0
        NLR.TVtype='none'; % 'none', 'temporal','spatial'
        NLR.NonlinearReconstruction='no';
    end
end

% END
end
