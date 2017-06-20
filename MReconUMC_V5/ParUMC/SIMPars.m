classdef SIMPars < dynamicprops & deepCopyable
%Declare parameters that are related to the simulation mode. The general
% idea is to initialize a reconframe structure myself with for example a
% Shepp-logan phantom for prototyping. However this is not finished yet.
% 
% 20170717 - T.Bruijnen

%% Parameters that are adjustable at configuration
properties
        Simulation
        Phantom
end

%% Set default values
methods
    function SIM = SIMPars()   
        SIM.Simulation='no'; % yesno parameter
        SIM.Phantom='Shepp-logan'; % Or brain
    end
end

% END
end
