classdef Operators < dynamicprops & deepCopyable
% 20161206 - Declare all operators and parameters for iterative reconstructions

properties
    W % Density operators
    S % Combine Coil Operator
    N % NUFFT operator
    TV % Total variation operator
    Id % Image space dimensions 
    Kd % K-space dimensions
    N_iter % Number of inner iterations
    N_rep % Number of outter algorithm iterations (only required for nonlinear methods)
    Lambda % Regularization parameter [array]
    Verbose % 1 = yes, 0 = no
    y % k-space data raw
end
methods
    function OP = Operators()   
        OP.W={};
        OP.N={};
        OP.S={};
        OP.TV={};
        OP.Id=[];
        OP.Kd=[];
        OP.N_iter=8;
        OP.N_rep=1;
        OP.Lambda=[];
        OP.Verbose=0;
        OP.y=[];
    end
end

% END
end