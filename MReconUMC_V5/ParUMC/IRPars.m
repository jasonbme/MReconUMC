classdef IRPars < dynamicprops & deepCopyable
% 20161206 - Declare all parameters related to the iterative reconstructions.

properties
    IterativeReconstruction % YesNO for iterative reconstruction
    Potential_function % L2 or L1 penalty
    JointReconstruction % 0 = joint reconstruction, 3 = reconstruct per dimensions(3), so for z. 5 is per dynamic
    LSQR_resvec % Residuel after lsqr
    TVdimension % Array with order of TV, so [1 1 1 0 0] = first order TV in first three dimensions.
    TV_lambda
    Wavelet % 0/2/3 no wavelet, 2D wavelet or 3D wavelet
    Wavelet_lambda
end

methods
    function IR = IRPars()   
        IR.TVdimension=[0 0 0]; 
        IR.TV_lambda={1};
        IR.Potential_function=2; 
        IR.JointReconstruction=12; 
        IR.IterativeReconstruction='no';
        IR.LSQR_resvec=[]; 
        IR.Wavelet=0;
        IR.Wavelet_lambda={1};
    end
end

% END
end
