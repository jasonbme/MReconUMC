classdef IRPars < dynamicprops & deepCopyable
%Declare all parameters related to the iterative reconstructions (IR).
% Some extra eplanation about the TV operator. The parameters
% TVDimension and TVLambda govern the creation of the corresponding Total
% Variation operator. TVDimension is a cell with arrays for each data
% chunk. So if you have one data chunk it look like this ..={[1 3 0 0 2]},
% which means perform a first order finite difference on the x dimension, a
% linear combination of first and second order difference on the y
% dimension and a second order difference on the 5th dimensions (dynamics).
% The Lambda parameter has the same size and governs the weights for all
% the operations. Both parameters are eventually combined into one large
% sparse matrix to calculate the total TV.
% 
% 20170717 - T.Bruijnen

%% Parameters that are adjustable at configuration
properties
    IterativeReconstruction % |YesNo| for iterative reconstruction
    PotentialFunction % |Integer| 1=l1-norm (CS), 2=l2-norm (LSQR)
    SplitDimension % |Integer| Dimension where to split the reconstruction on. 3=per z, 5=per dynamics
    TVDimension % |Cell of arrays| Array with order of TV, so [1 1 1 0 0] = first order TV in first three dimensions.
    TVLambda % |Cell of arrays| Array with corresponding weights for each TV dimension
    WaveletDimension % |String| '2D' or '3D' Wavelet transform
    WaveletLambda % |Double| Corresponding Wavelet weight
    Residual % |Array| Residuel after lsqr reconstruction
end

%% Set default values
methods
    function IR = IRPars()   
        IR.TVDimension={[0 0 0 0 0],[0,0,0,0,0],[0,0,0,0,0]}; 
        IR.TVLambda={[1 0 0 0 0],[1 0 0 0 0],[1 0 0 0 0]};
        IR.PotentialFunction=2; 
        IR.SplitDimension=12; 
        IR.IterativeReconstruction='no';
        IR.Residual=[]; 
        IR.WaveletDimension='no';
        IR.WaveletLambda={0,0,0};
    end
end

% END
end
