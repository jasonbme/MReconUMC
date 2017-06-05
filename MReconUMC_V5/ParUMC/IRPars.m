classdef IRPars < dynamicprops & deepCopyable
% 20161206 - Declare all parameters related to the iterative reconstructions.

properties
    IterativeReconstruction % YesNO for iterative reconstruction
    Potential_function % L2 or L1 penalty
    JointReconstruction % 0 = joint reconstruction, 3 = reconstruct per dimensions(3), so for z. 5 is per dynamic
    Lambda  % Regularization parameter
    LSQR_resvec % Residuel after lsqr
    TVtype % 'no', 'temporal','spatial'
    TVorder % 1 or 2, first or second order 
end

methods
    function IR = IRPars()   
        IR.TVtype='no'; 
        IR.TVorder=2;  
        IR.Lambda={1};
        IR.Potential_function=2; 
        IR.JointReconstruction=12; 
        IR.IterativeReconstruction='no';
        IR.LSQR_resvec=[]; 
    end
end

% END
end
