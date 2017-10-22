classdef Operators < dynamicprops & deepCopyable
%This class contains all the operators and information that is send to the
% solvers for the iterative reconstruction. Also contains operator like
% nufft and dcf for the adjoint reconstructions. All these parameters are
% not set from the configuration file but are composed from all the other
% functions. So no need to set any of these parameters.
% 
% 20170717 - T.Bruijnen

properties
    W % |Operator| Density compensation
    S % |Operator| Sensitivities
    N % |Operator| Nufft
    TV % |Operator| Total variation 
    Wavelet % |Operator| Wavelet transform
    Id % |Array| Image space dimensions 
    Kd % |Array| K-space dimensions
    Niter % |Integer| Number of inner iterations
    Nrep % |Integer| Number of outter algorithm iterations (only required for nonlinear methods)
    WaveletLambda % |Double| Regularization parameter 
    Beta % |Double| Step size for nlcg
    Residual % |Array| Residual for iterative reconstructions
    Verbose % |Integer| 1 = yes, 0 = no
    y % |Matrix| k-space data raw
end

methods
    function OP = Operators()   
        OP.W={};
        OP.N={};
        OP.S={};
        OP.TV={};
        OP.Id=[];
        OP.Kd=[];
        OP.Niter=25;
        OP.Nrep=1;
        OP.WaveletLambda=[];
        OP.Beta=.4;
        OP.Residual=[];
        OP.Verbose=0;
        OP.Wavelet={};
        OP.y=[];
    end
end

% END
end
