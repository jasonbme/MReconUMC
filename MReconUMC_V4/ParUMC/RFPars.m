classdef RFPars < dynamicprops & deepCopyable
% 20161206 - Introduce reconstruction flags

properties
    nufft_csmapping
    Verbose
end
methods
    function RF = RFPars()   
        RF.nufft_csmapping=0;
        RF.Verbose=0;
    end
end

% END
end