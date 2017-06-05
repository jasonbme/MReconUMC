classdef RFPars < dynamicprops & deepCopyable
% 20161206 - Introduce reconstruction flags

properties
    nufft_csmapping 
    girf_calculated
    Verbose
end
methods
    function RF = RFPars()   
        RF.nufft_csmapping=0;
        RF.Verbose=0;
        RF.girf_calculated=0;
    end
end

% END
end