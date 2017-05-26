classdef IRPars < dynamicprops & deepCopyable
% 20161206 - Declare all parameters related to the iterative reconstructions.

properties
    IterativeReconstruction
    Potential_function
    Regularization_parameter
    JointReconstruction
    Niter
    LSQR_resvec
    RawData
    TVtype
    TVorder
    Visualization
end
methods
    function IR = IRPars()   
        IR.RawData=[];
        IR.TVtype='none'; % 'none', 'temporal','spatial'
        IR.TVorder=2; % 1 or 2, first or second order 
        IR.Potential_function=2; % 1 or 2, i.e. compressed sensing or LSQR
        IR.Regularization_parameter=10; % Lambda
        IR.Niter=3; % Number of iterations for LSQR or NLCG
        IR.JointReconstruction='yes'; % Dynamic by dynamic = no, else is yes (needed for temporal TV for example)
        IR.IterativeReconstruction='no';
        IR.LSQR_resvec=[]; % Residue for each iteration
        IR.Visualization='no';
    end
end

% END
end
