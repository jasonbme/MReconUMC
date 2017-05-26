classdef SIMPars < dynamicprops & deepCopyable
% 20161206 - Introduce all parameters that are related to simulating
% acquisitions

properties
        Simulation
        Phantom
end
methods
    function SIM = SIMPars()   
        SIM.Simulation='no'; % yesno parameter
        SIM.Phantom='Shepp-logan'; % Or brain
    end
end

% END
end
