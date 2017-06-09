classdef Operators < dynamicprops & deepCopyable
% 20161206 - Declare all operators and parameters for iterative reconstructions
% This struct will be be passed along to all the solvers, e.g. lsqr and nlcg

properties
    W % Density operators
    S % Combine Coil Operator
    N % NUFFT operator
    TV % Total variation operator
    Id % Image space dimensions 
    Kd % K-space dimensions
    N_iter % Number of inner iterations
    N_rep % Number of outter algorithm iterations (only required for nonlinear methods)
    TV_lambda % Regularization parameter [array]
    Wavelet_lambda
    Beta % Step size for nlcg
    Residual % Residual for iterative reconstructions
    Verbose % 1 = yes, 0 = no
    Wavelet % Operator
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
        OP.TV_lambda=[];
        OP.Wavelet_lambda=[];
        OP.Beta=.4;
        OP.Residual=[];
        OP.Verbose=0;
        OP.Wavelet={};
        OP.y=[];
    end
end

% END
end
